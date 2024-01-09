import 'package:cropsync/services/user_model.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:watch_it/watch_it.dart';

import '../widgets/overview_card.dart';

class HomeScreen extends WatchingStatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final microId = watchPropertyValue((UserModel m) => m.user.microId);

    if (microId.isEmpty) {
      return noDeviceAdded();
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Overview',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Gap(16),
              overviewCard(),
            ],
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
                'You do not have any devices added. Please add a device.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20)),
            const Gap(16),
            PrimaryButton(text: 'Add a Device', onPressed: () {})
          ],
        ),
      ),
    );
  }
}
