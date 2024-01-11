import 'package:cached_network_image/cached_network_image.dart';
import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/widgets/buttons.dart';
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

    List<String> cropNames = devices.map((device) => device.crop.name).toList();

    if (devices.isEmpty) return noDeviceAdded();

    return Scaffold(
      appBar: AppBar(
        title: Text('Total Crops: ${cropNames.length}'),
        centerTitle: false,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
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
                    child: ListTile(
                      leading: CachedNetworkImage(
                        imageUrl:
                            "https://s.yimg.com/os/creatr-uploaded-images/2021-02/76161010-77b7-11eb-a9ff-e5c3108c9869",
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                                    value: downloadProgress.progress,
                                    color: Colors.white),
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
                            const Icon(Icons.error),
                      ),
                      title: Text(cropNames[index]),
                      subtitle: Text('Connected to ${devices[index].name}'),
                    ),
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
