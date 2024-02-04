import 'dart:convert';

import 'package:cropsync/json/devices.dart';
import 'package:cropsync/models/devices_model.dart';
import 'package:cropsync/services/device_api.dart';
import 'package:cropsync/services/local_device_api.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:cropsync/widgets/dialogs.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:logger/logger.dart';
import 'package:photo_view/photo_view.dart';
import 'package:watch_it/watch_it.dart';

class DevicesScreen extends WatchingStatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  void addDevice(BuildContext context) {
    Navigator.of(context).pushNamed('/add-device');
  }

  Future<void> deleteDevice(Devices device, BuildContext context) async {
    final confirmDelete = await Dialogs.showConfirmationDialog(
        'Confirm Deletion',
        'Are you sure you want to delete ${device.name}',
        context);

    if (confirmDelete) {
      // delete from local device
      if (!mounted) return;
      Dialogs.showLoadingDialog('Deleting Device', context);
      final result = await LocalDeviceApi.deleteDeviceConfiguration(
          deviceCode: device.code!);

      if (!mounted) return;
      if (result == ReturnTypes.fail) {
        Navigator.pop(context);
        Dialogs.showErrorDialog(
            'Error', 'An error occurred, try again', context);
        return;
      } else if (result == ReturnTypes.error) {
        Navigator.pop(context);
        Dialogs.showErrorDialog(
            'Error', 'An error occurred, try again', context);
        return;
      } else if (result == ReturnTypes.hasNotBeenConfigured) {
        Navigator.pop(context);
        Dialogs.showErrorDialog(
            'Error', 'Device has not been configured', context);
        return;
      }

      Logger().d('Local configuration deleted');

      // delete from server
      final globalResult = await DeviceApi.deleteDevice(deviceId: device.id!);

      if (!mounted) return;
      if (globalResult == ReturnTypes.fail) {
        Navigator.pop(context);
        Dialogs.showErrorDialog(
            'Error', 'An error occurred, try again', context);
        return;
      } else if (globalResult == ReturnTypes.error) {
        Navigator.pop(context);
        Dialogs.showErrorDialog(
            'Error', 'An error occurred, try again', context);
        return;
      } else if (globalResult == ReturnTypes.invalidToken) {
        Navigator.pop(context);
        invalidTokenResponse(context);
        return;
      }

      Logger().d('Device deleted from server');

      di<DevicesModel>().deleteDevice(device.id!);

      Navigator.pop(context);

      Dialogs.showSuccessDialog(
          'Success', 'Device deleted successfully', context);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final devices = watchPropertyValue((DevicesModel d) => d.devices.toList());

    return Scaffold(
      appBar: AppBar(
        title: Text('Total Devices: ${devices.length}'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => addDevice(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: AnimationLimiter(
          child: ListView.builder(
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  child: FadeInAnimation(
                    child: ExpansionTileCard(
                      title: Text(devices[index].name!),
                      subtitle: Text("ID: ${devices[index].id}"),
                      children: [
                        ListTile(
                          leading: const Icon(Icons.image_rounded),
                          title: const Text('View Latest Camera Image'),
                          onTap: () async {
                            try {
                              final image =
                                  await LocalDeviceApi.getLatestLocalCamera(
                                      deviceCode: devices[index].code!);

                              if (!mounted) return;
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    constraints: BoxConstraints.expand(
                                      height:
                                          MediaQuery.of(context).size.height,
                                    ),
                                    child: PhotoView(
                                      imageProvider: MemoryImage(
                                        base64Decode(image),
                                      ),
                                    ),
                                  );
                                },
                              );
                            } catch (e) {
                              return;
                            }
                          },
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            TextButton(
                              onPressed: () {},
                              child: const Column(
                                children: <Widget>[
                                  Icon(Icons.edit_rounded),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 2.0),
                                  ),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Column(
                                children: <Widget>[
                                  Icon(Icons.recommend_rounded),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 2.0),
                                  ),
                                  Text('Recommend Best Crop'),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  deleteDevice(devices[index], context),
                              child: const Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.delete_rounded,
                                    color: Colors.red,
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 2.0),
                                  ),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                        // const ListTile(
                        //   leading: Icon(Icons.edit),
                        //   title: Text('Edit Device'),
                        // ),
                        // const ListTile(
                        //   leading: Icon(Icons.recommend_rounded),
                        //   title: Text('Recommend Best Crop'),
                        // ),
                        // // ListTile(
                        // //   leading: const Icon(Icons.location_on),
                        // //   title: Text(devices[index].location),
                        // // ),
                        // // ListTile(
                        // //   leading: const Icon(Icons.calendar_today),
                        // //   title: Text(devices[index].dateAdded),
                        // // ),
                        // ListTile(
                        //   leading: const Icon(Icons.delete),
                        //   title: const Text('Delete'),
                        //   onTap: () {},
                        // ),
                      ],
                    ),
                  ),
                ),
              );
            },
            itemCount: devices.length,
          ),
        ),
      ),
    );
  }
}
