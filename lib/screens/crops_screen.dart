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
    final microId = watchPropertyValue((UserModel m) => m.user.microId);

    if (microId.isEmpty) return noDeviceAdded();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Crops: .'),
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
                      title: Text('Crop ${index + 1}'),
                    ),
                  ),
                ),
              );
            },
            itemCount: 1,
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
