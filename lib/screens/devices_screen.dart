import 'package:cropsync/json/device.dart';
import 'package:cropsync/main.dart';
import 'package:cropsync/models/devices_model.dart';
import 'package:cropsync/screens/camera_control_screen.dart';
import 'package:cropsync/services/device_api.dart';
import 'package:cropsync/services/local_device_api.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:cropsync/utils/other_variables.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:cropsync/widgets/dialogs.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:gap/gap.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:watch_it/watch_it.dart';

class DevicesScreen extends WatchingStatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final VlcPlayerController videoPlayerController = VlcPlayerController.network(
    'udp://@:8888',
    options: VlcPlayerOptions(
      extras: [
        '--demux=h264',
      ],
    ),
  );

  void addDevice(BuildContext context) {
    Navigator.of(context).pushNamed('/add-device');
  }

  void editDevice(BuildContext context, Device device) {
    Navigator.of(context).pushNamed('/edit-device', arguments: {
      'device': device,
    });
  }

  Future<void> deleteDevice(Device device, BuildContext context) async {
    final confirmDelete = await Dialogs.showConfirmationDialog(
        'Confirm Deletion',
        'Are you sure you want to delete ${device.name}?',
        context);

    if (confirmDelete) {
      // delete from local device
      if (!context.mounted) return;
      Dialogs.showLoadingDialog('Deleting Device...', context);
      final result = await LocalDeviceApi.deleteDeviceConfiguration(
          deviceCode: device.code!);

      if (!context.mounted) return;
      if (result == ReturnTypes.fail) {
        Navigator.pop(context);
        Dialogs.showErrorDialog(
            'Error', 'Could not connect to ${device.name}', context);
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

      logger.d('Local configuration deleted');

      // delete from server
      final globalResult =
          await DeviceApi.deleteDevice(deviceId: device.deviceId!);

      if (!context.mounted) return;
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

      logger.d('Device deleted from server');

      di<DevicesModel>().deleteDevice(device.deviceId!);

      if (!context.mounted) return;
      Navigator.pop(context);

      Dialogs.showSuccessDialog(
          'Success', 'Device deleted successfully.', context);
      return;
    }
  }

  Future refresh() async {
    final devices = await DeviceApi.getDevices();
    if (devices.runtimeType == List<Device>) {
      di<DevicesModel>().devices = devices;
      logger.t('Fetched Devices by Refresh');
    }
  }

  void setFrequency(BuildContext context, Device device, int oldSoilFrequency,
      int oldImageFrequency) {
    final List<Map<String, dynamic>> frequency = OtherVars().frequency;

    var selectedSoilFrequency = frequency.firstWhere(
        (element) => element['id'] == oldSoilFrequency,
        orElse: () => frequency[0]);

    var selectedImageFrequency = frequency.firstWhere(
        (element) => element['id'] == oldImageFrequency,
        orElse: () => frequency[0]);

    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.drag_handle_rounded,
                  color: Colors.grey,
                ),
                const Text(
                  'Set Data Collection Frequency',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                ListTile(
                  title: const Text('Soil Data'),
                  trailing: DropdownButton(
                    items: frequency.map((value) {
                      return DropdownMenuItem(
                        value: value['id'],
                        child: Text(value['label']),
                      );
                    }).toList(),
                    value: selectedSoilFrequency['id'],
                    onChanged: (value) {
                      setState(() {
                        selectedSoilFrequency = frequency
                            .firstWhere((element) => element['id'] == value);
                      });
                    },
                  ),
                ),
                const Gap(10),
                ListTile(
                  title: const Text('Images'),
                  trailing: DropdownButton(
                    items: frequency.map((value) {
                      return DropdownMenuItem(
                        value: value['id'],
                        child: Text(value['label']),
                      );
                    }).toList(),
                    value: selectedImageFrequency['id'],
                    onChanged: (value) {
                      setState(() {
                        selectedImageFrequency = frequency
                            .firstWhere((element) => element['id'] == value);
                      });
                    },
                  ),
                ),
                const Gap(10),
                SecondaryButton(
                  onPressed: () async {
                    if (isLoading) return;

                    setState(() {
                      isLoading = true;
                    });

                    logger.d('Soil Frequency: ${selectedSoilFrequency['id']}');
                    logger
                        .d('Image Frequency: ${selectedImageFrequency['id']}');

                    // set on server
                    final response = await DeviceApi.setDeviceFrequency(
                      deviceId: device.deviceId!,
                      soilFrequency: selectedSoilFrequency['id'],
                      imageFrequency: selectedImageFrequency['id'],
                    );

                    if (!context.mounted) return;
                    if (response == ReturnTypes.fail) {
                      setState(() {
                        isLoading = false;
                      });
                      Dialogs.showErrorDialog(
                          'Error', 'An error occurred, try again', context);
                      return;
                    } else if (response == ReturnTypes.error) {
                      setState(() {
                        isLoading = false;
                      });
                      Dialogs.showErrorDialog(
                          'Error', 'An error occurred, try again', context);
                      return;
                    } else if (response == ReturnTypes.invalidToken) {
                      setState(() {
                        isLoading = false;
                      });
                      invalidTokenResponse(context);
                      return;
                    }

                    // update in local state
                    di<DevicesModel>().setFrequencies(
                      id: device.deviceId!,
                      soilFrequency: selectedSoilFrequency['id'],
                      imageFrequency: selectedImageFrequency['id'],
                    );

                    setState(() {
                      isLoading = false;
                    });

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    // Dialogs.showSuccessDialog(
                    //     'Success',
                    //     'Frequencies have been set for ${device.name}!',
                    //     context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Frequencies have been set for ${device.name}'),
                      ),
                    );
                  },
                  icon: Icons.save_rounded,
                  text: 'Set Frequencies',
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        );
      },
    );
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
            tooltip: 'Add Device',
            onPressed: () => addDevice(context),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AnimationLimiter(
          child: RefreshIndicator(
            onRefresh: refresh,
            child: ListView.builder(
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    child: FadeInAnimation(
                      child: ExpansionTileCard(
                        leading: devices[index].isConnected == true
                            ? const Icon(
                                Icons.wifi_rounded,
                                color: Colors.green,
                              )
                            : const Icon(
                                Icons.wifi_off_rounded,
                                color: Colors.red,
                              ),
                        title: Text(devices[index].name!),
                        subtitle: Text(devices[index].location!),
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.grass_rounded,
                              color: devices[index].crop?.name == null
                                  ? Colors.red
                                  : null,
                            ),
                            title: Text(
                              devices[index].crop?.name ?? 'No Crop Assigned',
                              style: TextStyle(
                                  color: devices[index].crop?.name == null
                                      ? Colors.red
                                      : null),
                            ),
                            trailing: devices[index].crop?.name == null
                                ? IconButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushNamed('/set-crop', arguments: {
                                        'device': devices[index],
                                      });
                                    },
                                    icon: const Icon(Icons.add_rounded),
                                  )
                                : null,
                          ),
                          Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              leading: const Icon(Icons.camera_rounded),
                              title: const Text(
                                'View Camera',
                              ),
                              children: [
                                CameraControlScreen(device: devices[index])
                              ],
                            ),
                          ),
                          // ListTile(
                          //   leading: const Icon(Icons.camera_rounded),
                          //   title: const Text(
                          //     'View Camera',
                          //   ),
                          //   onTap: () {
                          //     showModalBottomSheet(
                          //       context: context,
                          //       builder: (context) {
                          //         return CameraControlScreen(
                          //             device: devices[index]);
                          //       },
                          //     );
                          //   },
                          // ),
                          ListTile(
                            leading: const Icon(Bootstrap.database_fill_up),
                            title: const Text(
                              'Data Collection Frequency',
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Soil Data: ${getLabelForId(devices[index].soilFrequency!)}'),
                                Text(
                                    'Images: ${getLabelForId(devices[index].imageFrequency!)}'),
                              ],
                            ),
                            onTap: () {
                              setFrequency(
                                context,
                                devices[index],
                                devices[index].soilFrequency!,
                                devices[index].imageFrequency!,
                              );
                            },
                          ),
                          // ListTile(
                          //   leading: const Icon(Icons.water_drop_rounded),
                          //   title: const Text(
                          //     'Water Crop',
                          //   ),
                          //
                          //   // subtitle: Text(
                          //   //     '${getLabelForId(devices[index].wateringFrequency!)}'),
                          //   // onTap: () {
                          //   //   setWateringFrequency(
                          //   //     context,
                          //   //     devices[index],
                          //   //     devices[index].wateringFrequency!,
                          //   //   );
                          //   // },
                          // ),
                          OverflowBar(
                            alignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              TextButton(
                                onPressed: () {
                                  editDevice(context, devices[index]);
                                },
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
      ),
    );
  }
}
