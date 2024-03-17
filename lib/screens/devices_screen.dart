import 'package:cropsync/json/device.dart';
import 'package:cropsync/main.dart';
import 'package:cropsync/models/devices_model.dart';
import 'package:cropsync/services/device_api.dart';
import 'package:cropsync/services/local_device_api.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:cropsync/widgets/dialogs.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:icons_plus/icons_plus.dart';
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
            'Error', 'Could not connect to ${device.name}.', context);
        return;
      } else if (result == ReturnTypes.error) {
        Navigator.pop(context);
        Dialogs.showErrorDialog(
            'Error', 'An error occurred, try again.', context);
        return;
      } else if (result == ReturnTypes.hasNotBeenConfigured) {
        Navigator.pop(context);
        Dialogs.showErrorDialog(
            'Error', 'Device has not been configured.', context);
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
            'Error', 'An error occurred, try again.', context);
        return;
      } else if (globalResult == ReturnTypes.error) {
        Navigator.pop(context);
        Dialogs.showErrorDialog(
            'Error', 'An error occurred, try again.', context);
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
      logger.d('Fetched Devices by Refresh');
    }
  }

  void setFrequency(BuildContext context, Device device, int oldSoilFrequency,
      int oldImageFrequency) {
    final Map<String, int> soilItems = {
      'Every ${secondsToReadableText(300)}': 300,
      'Every ${secondsToReadableText(600)}': 600,
      'Every ${secondsToReadableText(900)}': 900,
      'Every ${secondsToReadableText(1800)}': 1800,
      'Every ${secondsToReadableText(3600)}': 3600,
      'Every ${secondsToReadableText(7200)}': 7200,
      'Every ${secondsToReadableText(14400)}': 14400,
    };

    final Map<String, int> imageItems = {
      'Every ${secondsToReadableText(600)}': 600,
      'Every ${secondsToReadableText(1200)}': 1200,
      'Every ${secondsToReadableText(1800)}': 1800,
      'Every ${secondsToReadableText(3600)}': 3600,
      'Every ${secondsToReadableText(7200)}': 7200,
      'Every ${secondsToReadableText(14400)}': 14400,
      'Every ${secondsToReadableText(21600)}': 21600,
    };

    var selectedSoilFrequency = soilItems.keys.firstWhere(
        (key) => soilItems[key] == oldSoilFrequency,
        orElse: () => 'Every 5 minutes');

    var selectedImageFrequency = imageItems.keys.firstWhere(
        (key) => imageItems[key] == oldImageFrequency,
        orElse: () => 'Every 20 minutes');

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
                const ListTile(
                  title: Text(
                    'Set Data Collection Frequency',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
                ListTile(
                  title: const Text('Soil Data'),
                  trailing: DropdownButton(
                    items: soilItems.keys.map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    value: selectedSoilFrequency,
                    onChanged: (value) {
                      setState(() {
                        selectedSoilFrequency = value!;
                      });
                    },
                  ),
                ),
                const Gap(10),
                ListTile(
                  title: const Text('Images'),
                  trailing: DropdownButton(
                    items: imageItems.keys.map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    value: selectedImageFrequency,
                    onChanged: (value) {
                      setState(() {
                        selectedImageFrequency = value!;
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

                    logger.d(
                        'Soil Frequency: ${soilItems[selectedSoilFrequency]}');
                    logger.d(
                        'Image Frequency: ${imageItems[selectedImageFrequency]}');

                    // set frequency on local device
                    final response = await LocalDeviceApi.setFrequencies(
                      deviceCode: device.code!,
                      soilFrequency: soilItems[selectedSoilFrequency]!,
                      imageFrequency: imageItems[selectedImageFrequency]!,
                    );
                    if (response == ReturnTypes.fail) {
                      if (!context.mounted) return;
                      setState(() {
                        isLoading = false;
                      });
                      Dialogs.showErrorDialog('Error',
                          'Could not connect to ${device.name}.', context);
                      return;
                    } else if (response == ReturnTypes.error) {
                      if (!context.mounted) return;
                      setState(() {
                        isLoading = false;
                      });
                      Dialogs.showErrorDialog(
                          'Error', 'An error occurred, try again', context);
                      return;
                    }

                    // todo set on server

                    // update in local state
                    di<DevicesModel>().setFrequencies(
                      id: device.deviceId!,
                      soilFrequency: soilItems[selectedSoilFrequency]!,
                      imageFrequency: imageItems[selectedImageFrequency]!,
                    );

                    setState(() {
                      isLoading = false;
                    });

                    if (!context.mounted) return;
                    Navigator.pop(context);
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

    // showMaterialScrollPicker(
    //   context: context,
    //   showDivider: false,
    //   title: 'Set Soil Data Collection Frequency',
    //   confirmText: 'Set',
    //   items: items.keys.toList(),
    //   selectedItem: selectedSoilFrequency,
    //   onChanged: (value) async {
    //     selectedSoilFrequency = value;
    //
    //     final response = await LocalDeviceApi.setSoilFrequency(
    //         deviceCode: device.code!, soilFrequency: items[value]!);
    //
    //     if (!mounted) return;
    //     if (response == ReturnTypes.fail || response == ReturnTypes.error) {
    //       Dialogs.showErrorDialog(
    //           'Error', 'An error occurred, try again', context);
    //       return;
    //     }
    //
    //     // todo update on server
    //
    //     // di<DevicesModel>()
    //     //     .setSoilTime(id: device.deviceId!, soilTime: items[value]!);
    //   },
    // );
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
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
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
                          ListTile(
                            leading: const Icon(Icons.camera_rounded),
                            title: const Text(
                              'Control Camera',
                            ),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed('/camera-control', arguments: {
                                'device': devices[index],
                              });
                            },
                          ),
                          ListTile(
                            leading: const Icon(Bootstrap.database_fill_up),
                            // leading: const Icon(Icons.cloud_upload_rounded),
                            title: const Text(
                              'Data Collection Frequency',
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Soil Data: Every ${secondsToReadableText(devices[index].soilFrequency ?? 1)}'),
                                Text(
                                    'Images: Every ${secondsToReadableText(devices[index].imageFrequency ?? 1200)}'),
                              ],
                            ),
                            onTap: () {
                              setFrequency(
                                  context,
                                  devices[index],
                                  devices[index].soilFrequency ?? 300,
                                  devices[index].imageFrequency ?? 1200);
                            }
                            // trailing: IconButton(
                            //   onPressed: () {
                            //
                            //   },
                            //   icon: const Icon(Icons.edit_rounded),
                            // ),
                          ),
                          ButtonBar(
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
                                onPressed: () {},
                                child: const Column(
                                  children: <Widget>[
                                    Icon(Icons.recommend_rounded),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.0),
                                    ),
                                    Text('Recommend Crop'),
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

String secondsToReadableText(int seconds) {
  if (seconds < 60) {
    return '$seconds ${_pluralize(seconds, "second")}';
  } else if (seconds < 3600) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = seconds % 60;
    if (remainingSeconds == 0) {
      return '$minutes ${_pluralize(minutes, "minute")}';
    } else {
      return '$minutes ${_pluralize(minutes, "minute")} $remainingSeconds ${_pluralize(remainingSeconds, "second")}';
    }
  } else if (seconds < 86400) {
    int hours = (seconds / 3600).floor();
    int remainingSeconds = seconds % 3600;
    int minutes = (remainingSeconds / 60).floor();
    if (minutes == 0) {
      return '$hours ${_pluralize(hours, "hour")}';
    } else {
      return '$hours ${_pluralize(hours, "hour")} $minutes ${_pluralize(minutes, "minute")}';
    }
  } else {
    int days = (seconds / 86400).floor();
    int remainingSeconds = seconds % 86400;
    int hours = (remainingSeconds / 3600).floor();
    if (hours == 0) {
      return '$days ${_pluralize(days, "day")}';
    } else {
      return '$days ${_pluralize(days, "day")} $hours ${_pluralize(hours, "hour")}';
    }
  }
}

String _pluralize(int count, String noun) {
  if (count == 1) {
    return noun;
  } else {
    return '${noun}s';
  }
}
