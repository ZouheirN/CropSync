import 'dart:convert';

import 'package:cropsync/json/device_camera.dart';
import 'package:flutter/material.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class DeviceCameraScreen extends StatefulWidget {
  const DeviceCameraScreen({super.key});

  @override
  State<DeviceCameraScreen> createState() => _DeviceCameraScreenState();
}

class _DeviceCameraScreenState extends State<DeviceCameraScreen> {
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
        title: FittedBox(child: Text('${deviceCamera.deviceName!} Camera History')),
      ),
      body: InfiniteList(
        itemCount: items.length,
        isLoading: isLoading,
        onFetchData: fetchData,
        separatorBuilder: (context, index) => const Divider(),
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return ListTile(
            title: Image.memory(
              base64Decode(deviceCamera.image!),
              fit: BoxFit.cover,
              height: 200,
              width: 200,
            ),
            subtitle: Text(
              items[index],
            ),
          );
        },
      ),
    );
  }
}
