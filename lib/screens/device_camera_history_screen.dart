import 'dart:convert';

import 'package:cropsync/json/device_camera.dart';
import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class DeviceCameraHistoryScreen extends StatefulWidget {
  const DeviceCameraHistoryScreen({super.key});

  @override
  State<DeviceCameraHistoryScreen> createState() =>
      _DeviceCameraHistoryScreenState();
}

class _DeviceCameraHistoryScreenState extends State<DeviceCameraHistoryScreen> {
  var items = <String>[];
  var isLoading = false;

  void fetchData() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      isLoading = false;
      items = List.generate(items.length + 10, (i) => 'Item $i');
    });
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as Map;
    final DeviceCamera deviceCamera = arg['deviceCamera'];

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
            child: Text('${deviceCamera.deviceName!} Camera History')),
      ),
      body: InfiniteList(
        itemCount: items.length,
        isLoading: isLoading,
        centerLoading: true,
        onFetchData: fetchData,
        loadingBuilder: (context) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        itemBuilder: (context, index) {
          return StickyHeader(
            header: Container(
              height: 50.0,
              color: Colors.blueGrey[700],
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: Text(
                items[index],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            content: Image.memory(
              base64Decode(deviceCamera.image!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200.0,
            ),
          );
        },
      ),
    );
  }
}
