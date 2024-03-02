import 'dart:async';
import 'dart:convert';

import 'package:arrow_pad/arrow_pad.dart';
import 'package:cropsync/json/device.dart';
import 'package:cropsync/services/local_device_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CameraControlScreen extends StatefulWidget {
  const CameraControlScreen({super.key});

  @override
  State<CameraControlScreen> createState() => _CameraControlScreenState();
}

class _CameraControlScreenState extends State<CameraControlScreen> {
  dynamic _device;
  String ip = 'Connecting...';
  bool isConnectedToSocket = false;
  WebSocketChannel? channel;

  // void startTimer() async {
  //   while (mounted) {
  //     channel?.sink.add('camera');
  //     await Future.delayed(const Duration(seconds: 8));
  //   }
  // }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      setState(() {
        _device = args['device'] as Device;
      });
      LocalDeviceApi.getDeviceIp(_device.code!).then((value) {
        final channel = WebSocketChannel.connect(
          Uri.parse('ws://$value:65432'),
        );

        setState(() {
          if (value == '') {
            ip = 'Failed to connect';
          } else {
            // startTimer();
            ip = 'Connected to $value';
            isConnectedToSocket = true;
            this.channel = channel;
            channel.sink.add('camera');
          }
        });
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    channel?.sink.close();
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
          if (channel != null)
            StreamBuilder(
              stream: channel!.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data.startsWith("IMAGE:") ) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    color: Colors.black,
                    child: Image.memory(
                      base64Decode(snapshot.data.substring(6)),
                      fit: BoxFit.cover,
                    ),
                  );
                }

                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      Text('Getting Image...')
                    ],
                  ),
                );
              },
            )
          else if (ip == 'Failed to connect')
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: const Column(
                children: [
                  Icon(
                    Icons.error_rounded,
                    color: Colors.red,
                  ),
                  Text(
                    'Failed to connect to device',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                ],
              ),
            ),
          if (_device != null)
            Text(
              'Device: ${_device.name}',
              style: const TextStyle(fontSize: 20),
            ),
          Text(
            ip,
            style: const TextStyle(fontSize: 16),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: ArrowPad(
                padding: const EdgeInsets.all(80),
                onPressed: (direction) {
                  if (isConnectedToSocket) {
                    channel?.sink.add(direction.toString());
                    channel?.sink.add('camera');
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
