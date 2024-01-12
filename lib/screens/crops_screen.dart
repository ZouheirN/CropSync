import 'package:cached_network_image/cached_network_image.dart';
import 'package:cropsync/main.dart';
import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/widgets/buttons.dart';
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
  @override
  Widget build(BuildContext context) {
    final devices = watchPropertyValue((UserModel m) => m.user.devices);

    List<String?> cropNames =
        devices!.map((device) => device.crop!.name).toList();

    // Remove null values
    final cropNamesLength = [
      for (var i in cropNames)
        if (i != null) i
    ].length;

    if (devices.isEmpty) return noDeviceAdded();

    return Scaffold(
      appBar: AppBar(
        title: Text('Total Crops: $cropNamesLength'),
        centerTitle: false,
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
                    child: _buildListTile(devices, cropNames, index),
                  ),
                ),
              );
            },
            itemCount: cropNames.length,
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(devices, cropNames, index) {
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
                  errorWidget: (context, url, error) => const Icon(Icons.error),
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
                ],
              )
            else
              const ListTile(
                title: Text('Status'),
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
              onPressed: () {
                Navigator.of(context).pushNamed('/add-device');
              },
            )
          ],
        ),
      ),
    );
  }
}
