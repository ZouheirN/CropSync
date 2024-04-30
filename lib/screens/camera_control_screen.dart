import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cropsync/json/device.dart';
import 'package:cropsync/services/local_device_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class CameraControlScreen extends StatefulWidget {
  final Device device;

  const CameraControlScreen({super.key, required this.device});

  @override
  State<CameraControlScreen> createState() => _CameraControlScreenState();
}

class _CameraControlScreenState extends State<CameraControlScreen> {
  VlcPlayerController? videoPlayerController;

  @override
  void initState() {
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

      LocalDeviceApi.startStreaming(widget.device.code!, value);
    });
    super.initState();
  }

  @override
  Future<void> dispose() async {
    LocalDeviceApi.stopStreaming(widget.device.code!);
    videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
      ],
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
