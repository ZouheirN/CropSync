import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cropsync/json/device.dart';
import 'package:cropsync/json/soil_data.dart';
import 'package:cropsync/main.dart';
import 'package:cropsync/models/devices_model.dart';
import 'package:cropsync/models/latest_soil_data_model.dart';
import 'package:cropsync/services/device_api.dart';
import 'package:cropsync/utils/other_variables.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:cropsync/widgets/cards.dart';
import 'package:cropsync/widgets/dialogs.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:watch_it/watch_it.dart';

class CropsScreen extends WatchingStatefulWidget {
  const CropsScreen({super.key});

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends State<CropsScreen> {
  Timer? timer;

  Future refresh() async {
    final devices = await DeviceApi.getDevices();
    if (devices.runtimeType == List<Device>) {
      di<DevicesModel>().devices = devices;
      logger.d('Fetched Devices by Refresh');
    }
  }

  @override
  void initState() {
    super.initState();

    // get each device id in a list
    final deviceIds =
        di<DevicesModel>().devices.map((e) => e.deviceId).toList();

    // get the latest soil data for each device
    for (var deviceId in deviceIds) {
      DeviceApi.getLatestSoilData(deviceId!).then((soilData) {
        if (soilData.runtimeType == SoilData) {
          di<LatestSoilDataModel>().setSoilData(soilData);
          logger.d('Fetched Soil Data');
        }
      });
    }

    timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      if (!OtherVars().autoRefresh) return;

      // get each device id in a list
      final deviceIds =
          di<DevicesModel>().devices.map((e) => e.deviceId).toList();

      // get the latest soil data for each device
      for (var deviceId in deviceIds) {
        DeviceApi.getLatestSoilData(deviceId!).then((soilData) {
          if (soilData.runtimeType == SoilData) {
            di<LatestSoilDataModel>().setSoilData(soilData);
            logger.d('Fetched Soil Data');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  SoilData fetchSoilDataForSpecificDevice(String deviceId, soilData) {
    final index =
        soilData.indexWhere((element) => element.keys.first == deviceId);

    if (index != -1) {
      return soilData[index].values.first;
    }

    return SoilData();
  }

  @override
  Widget build(BuildContext context) {
    final devices = watchPropertyValue((DevicesModel d) => d.devices.toList());
    final soilData =
        watchPropertyValue((LatestSoilDataModel s) => s.soilData.toList());

    List<String?> cropNames =
        devices.map((device) => device.crop?.name).toList();

    // Remove null values
    final cropNamesLength = [
      for (var i in cropNames)
        if (i != null) i
    ].length;

    return Visibility(
      visible: devices.isNotEmpty,
      replacement: noDeviceAdded(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Total Crops: $cropNamesLength'),
          centerTitle: false,
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
                        child:
                            buildListTile(devices, cropNames, index, soilData),
                      ),
                    ),
                  );
                },
                itemCount: cropNames.length,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildListTile(devices, cropNames, index, soilData) {
    return Column(
      children: [
        ExpansionTileCard(
          leading: cropNames[index] != null &&
                  devices[index].crop.profile != null
              ? CachedNetworkImage(
                  imageUrl: devices[index].crop.profile,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  imageBuilder: (context, imageProvider) => Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error_rounded),
                )
              : null,
          title: cropNames[index] != null
              ? Text(cropNames[index]!)
              : const Text(
                  'Unassigned Crop',
                  style: TextStyle(color: Colors.red),
                ),
          subtitle: cropNames[index] != null
              ? Text('Connected to ${devices[index].name}')
              : Text('${devices[index].name} is not assigned to a crop'),
          children: [
            if (cropNames[index] == null)
              OverflowBar(
                alignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/set-crop', arguments: {
                        'device': devices[index],
                      });
                    },
                    child: const Column(
                      children: <Widget>[
                        Icon(Icons.grass_rounded),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0),
                        ),
                        Text('Assign Crop'),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Column(
                      children: <Widget>[
                        Icon(Icons.recommend_rounded),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0),
                        ),
                        Text('Recommend Crop'),
                      ],
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  ListTile(
                    title: fetchSoilDataForSpecificDevice(
                                    devices[index].deviceId, soilData)
                                .nitrogen ==
                            null
                        ? const Row(
                            children: [
                              Text('Nitrogen: '),
                              Gap(5),
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(),
                              ),
                            ],
                          )
                        : Text(
                            'Nitrogen: ${formatFloat(fetchSoilDataForSpecificDevice(devices[index].deviceId, soilData).nitrogen!)} mg/kg'),
                    leading: SizedBox(
                      height: 30,
                      child: Image.asset(
                        'assets/icon/nitrogen.png',
                        color: MyApp.themeNotifier.value == ThemeMode.light
                            ? const Color(0xFF3F4642)
                            : const Color(0xFFBEC6BF),
                      ),
                    ),
                  ),
                  ListTile(
                    title: fetchSoilDataForSpecificDevice(
                                    devices[index].deviceId, soilData)
                                .phosphorus ==
                            null
                        ? const Row(
                            children: [
                              Text('Phosphorus: '),
                              Gap(5),
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(),
                              ),
                            ],
                          )
                        : Text(
                            'Phosphorus: ${formatFloat(fetchSoilDataForSpecificDevice(devices[index].deviceId, soilData).phosphorus!)} mg/kg'),
                    leading: SizedBox(
                      height: 30,
                      child: Image.asset(
                        'assets/icon/phosphorus.png',
                        color: MyApp.themeNotifier.value == ThemeMode.light
                            ? const Color(0xFF3F4642)
                            : const Color(0xFFBEC6BF),
                      ),
                    ),
                  ),
                  ListTile(
                    title: fetchSoilDataForSpecificDevice(
                                    devices[index].deviceId, soilData)
                                .potassium ==
                            null
                        ? const Row(
                            children: [
                              Text('Potassium: '),
                              Gap(5),
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(),
                              ),
                            ],
                          )
                        : Text(
                            'Potassium: ${formatFloat(fetchSoilDataForSpecificDevice(devices[index].deviceId, soilData).potassium!)} mg/kg'),
                    leading: SizedBox(
                      height: 30,
                      child: Image.asset(
                        'assets/icon/potassium.png',
                        color: MyApp.themeNotifier.value == ThemeMode.light
                            ? const Color(0xFF3F4642)
                            : const Color(0xFFBEC6BF),
                      ),
                    ),
                  ),
                  ListTile(
                    title: fetchSoilDataForSpecificDevice(
                                    devices[index].deviceId, soilData)
                                .temperature ==
                            null
                        ? const Row(
                            children: [
                              Text('Temperature: '),
                              Gap(5),
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(),
                              ),
                            ],
                          )
                        : Text(
                            'Temperature: ${formatFloat(fetchSoilDataForSpecificDevice(devices[index].deviceId, soilData).temperature!)}°C'),
                    leading: SizedBox(
                      height: 30,
                      child: Image.asset(
                        'assets/icon/temperature.png',
                        color: MyApp.themeNotifier.value == ThemeMode.light
                            ? const Color(0xFF3F4642)
                            : const Color(0xFFBEC6BF),
                      ),
                    ),
                  ),
                  ListTile(
                    title: fetchSoilDataForSpecificDevice(
                                    devices[index].deviceId, soilData)
                                .ph ==
                            null
                        ? const Row(
                            children: [
                              Text('pH: '),
                              Gap(5),
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(),
                              ),
                            ],
                          )
                        : Text(
                            'pH: ${formatFloat(fetchSoilDataForSpecificDevice(devices[index].deviceId, soilData).ph!)}'),
                    leading: SizedBox(
                      height: 30,
                      child: Image.asset(
                        'assets/icon/ph.png',
                        color: MyApp.themeNotifier.value == ThemeMode.light
                            ? const Color(0xFF3F4642)
                            : const Color(0xFFBEC6BF),
                      ),
                    ),
                  ),
                  ListTile(
                    title: fetchSoilDataForSpecificDevice(
                                    devices[index].deviceId, soilData)
                                .humidity ==
                            null
                        ? const Row(
                            children: [
                              Text('Moisture: '),
                              Gap(5),
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(),
                              ),
                            ],
                          )
                        : Text(
                            'Moisture: ${formatFloat(fetchSoilDataForSpecificDevice(devices[index].deviceId, soilData).humidity!)}%'),
                    leading: SizedBox(
                      height: 30,
                      child: Image.asset(
                        'assets/icon/moisture.png',
                        color: MyApp.themeNotifier.value == ThemeMode.light
                            ? const Color(0xFF3F4642)
                            : const Color(0xFFBEC6BF),
                      ),
                    ),
                  ),
                  ListTile(
                    title: fetchSoilDataForSpecificDevice(
                        devices[index].deviceId, soilData)
                        .rainfall ==
                        null
                        ? const Row(
                      children: [
                        Text('Rainfall: '),
                        Gap(5),
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    )
                        : Text(
                        'Rainfall: ${formatFloat(fetchSoilDataForSpecificDevice(devices[index].deviceId, soilData).rainfall!)}mm'),
                    leading: SizedBox(
                      height: 30,
                      child: Image.asset(
                        'assets/icon/rainfall.png',
                        color: MyApp.themeNotifier.value == ThemeMode.light
                            ? const Color(0xFF3F4642)
                            : const Color(0xFFBEC6BF),
                      ),
                    ),
                  ),
                  Text(
                    fetchSoilDataForSpecificDevice(
                                    devices[index].deviceId, soilData)
                                .sensorCollectionDate ==
                            null
                        ? ''
                        : 'Date Collected: ${convertDateFormat(fetchSoilDataForSpecificDevice(devices[index].deviceId, soilData).sensorCollectionDate!.toString(), withTime: true)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  OverflowBar(
                    alignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed('/set-crop', arguments: {
                            'device': devices[index],
                          });
                        },
                        child: const Column(
                          children: <Widget>[
                            Icon(Icons.edit_rounded),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.0),
                            ),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Dialogs.showInformationDialog(
                              'Information',
                              'Nitrogen is used for plant growth and good green color.\nPhosphorus is used for root growth and flower and fruit development.\nPotassium is used for strong stem growth and movement of water in plants and food production.\nTemperature is the degree of hotness or coldness of a body or environment.\npH is a measure of how acidic/basic water is.\nMoisture is the presence of water in the soil.',
                              context);
                        },
                        child: const Column(
                          children: <Widget>[
                            Icon(Icons.info_rounded),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.0),
                            ),
                            Text('Info'),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              )
          ],
        ),
      ],
    );
  }

  // No Device Added
  Widget noDeviceAdded() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You cannot add crops before adding a device. Please add a device.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            const Gap(16),
            CommonButton(
              text: 'Add a Device',
              backgroundColor: Theme.of(context).primaryColor,
              textColor: Colors.white,
              onPressed: () async {
                Navigator.of(context).pushNamed('/add-device');
              },
            ),
          ],
        ),
      ),
    );
  }
}
