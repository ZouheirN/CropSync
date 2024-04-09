import 'dart:async';
import 'dart:io';

import 'package:cropsync/json/device.dart';
import 'package:cropsync/services/local_device_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:gap/gap.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CameraControlScreen extends StatefulWidget {
  const CameraControlScreen({super.key});

  @override
  State<CameraControlScreen> createState() => _CameraControlScreenState();
}

class _CameraControlScreenState extends State<CameraControlScreen> {
  dynamic device;
  String status = 'Waiting for connection...';

  VlcPlayerController? videoPlayerController;

  WebSocketChannel? channel;

  final textEditingController = TextEditingController();
  final espTextEditingController = TextEditingController();

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      setState(() {
        device = args['device'] as Device;
      });

      videoPlayerController = VlcPlayerController.network(
        'udp://@:8888',
        options: VlcPlayerOptions(
          extras: [
            '--demux=h264',
          ],
        ),
      );

      getLocalIpAddress().then((value) {
        if (value == null) return;

        textEditingController.text = value;

        LocalDeviceApi.startStreaming(device.code!, value);
      });
    });
    super.initState();
  }

  @override
  Future<void> dispose() async {
    LocalDeviceApi.stopStreaming(device.code!);
    videoPlayerController?.dispose();
    textEditingController.dispose();
    channel?.sink.close();
    espTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Camera'),
      ),
      body: Column(
        children: [
            ListTile(
              title: TextField(
                controller: textEditingController,
                decoration: const InputDecoration(
                  labelText: 'Your IP Address',
                ),
                enabled: false,
              ),
            ),
          if (videoPlayerController != null)
            Center(
              child: VlcPlayer(
                controller: videoPlayerController!,
                aspectRatio: 16 / 9,
                placeholder: const Center(child: CircularProgressIndicator()),
              ),
            )
          else
            const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ListTile(
            title: TextField(
              controller: espTextEditingController,
              decoration: const InputDecoration(
                labelText: 'Enter ESP IP',
              ),
              keyboardType: TextInputType.number,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.check_rounded),
              onPressed: () async {
                setState(() {
                  channel = WebSocketChannel.connect(
                    Uri.parse('ws://${espTextEditingController.text}:81'),
                  );
                  status = 'Connected to ${espTextEditingController.text}';
                });
              },
            ),
          ),
          Text(
            status,
            style: const TextStyle(fontSize: 16),
          ),
          StreamBuilder(
            stream: channel?.stream,
            builder: (context, snapshot) {
              return Text(snapshot.hasData ? 'Message From ESP: ${snapshot.data}' : '');
            },
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    channel?.sink.add('left');
                  },
                  icon: const Icon(
                    Icons.arrow_circle_left_rounded,
                    size: 100,
                  ),
                ),
                const Gap(10),
                IconButton(
                  onPressed: () {
                    channel?.sink.add('right');
                  },
                  icon: const Icon(
                    Icons.arrow_circle_right_rounded,
                    size: 100,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> getLocalIpAddress() async {
    final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4, includeLinkLocal: true);

    try {
      // Try VPN connection first
      NetworkInterface vpnInterface =
          interfaces.firstWhere((element) => element.name == "tun0");
      return vpnInterface.addresses.first.address;
    } on StateError {
      // Try wlan connection next
      try {
        NetworkInterface interface =
            interfaces.firstWhere((element) => element.name == "wlan0");
        return interface.addresses.first.address;
      } catch (ex) {
        // Try any other connection next
        try {
          NetworkInterface interface = interfaces.firstWhere((element) =>
              !(element.name == "tun0" || element.name == "wlan0"));
          return interface.addresses.first.address;
        } catch (ex) {
          return null;
        }
      }
    }
  }
}
