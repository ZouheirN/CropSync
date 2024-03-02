import 'package:cached_network_image/cached_network_image.dart';
import 'package:cropsync/json/device.dart';
import 'package:cropsync/main.dart';
import 'package:cropsync/models/devices_model.dart';
import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/services/device_api.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:logger/logger.dart';
import 'package:watch_it/watch_it.dart';

class CropsScreen extends WatchingStatefulWidget {
  const CropsScreen({super.key});

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends State<CropsScreen> {
  Future refresh() async {
    final devices = await DeviceApi.getDevices();
    if (devices.runtimeType == List<Device>) {
      di<DevicesModel>().devices = devices;
      logger.d('Fetched Devices by Refresh');
    }
  }

  @override
  Widget build(BuildContext context) {
    final devices = watchPropertyValue((DevicesModel d) => d.devices.toList());

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
                        child: buildListTile(devices, cropNames, index),
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

  Widget buildListTile(devices, cropNames, index) {
    return Column(
      children: [
        ExpansionTileCard(
          leading: cropNames[index] != null
              ? CachedNetworkImage(
                  imageUrl:
                      "https://www.tasteofhome.com/wp-content/uploads/2019/10/shutterstock_346577078.jpg?fit=700",
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                    value: downloadProgress.progress,
                    color: MyApp.themeNotifier.value == ThemeMode.light
                        ? Colors.black
                        : Colors.white,
                  ),
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
                  errorWidget: (context, url, error) => const Icon(Icons.error_rounded),
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
              ButtonBar(
                alignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  TextButton(
                    onPressed: () {},
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
                  const ListTile(
                    title: Text('Status'),
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
                              padding: EdgeInsets.symmetric(vertical: 2.0),
                            ),
                            Text('Edit'),
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
