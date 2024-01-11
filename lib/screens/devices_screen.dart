import 'package:cropsync/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:watch_it/watch_it.dart';

class DevicesScreen extends WatchingStatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  void _addDevice(BuildContext context) {
    Navigator.of(context).pushNamed('/add-device');
  }

  @override
  Widget build(BuildContext context) {
    final microId = watchPropertyValue((UserModel m) => m.user.microId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Total Devices: ${microId.length}'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => _addDevice(context),
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
                    child: ListTile(
                      title: Text('Device ${index + 1}'),
                      subtitle: Text(microId[index]),
                    ),
                  ),
                ),
              );
            },
            itemCount: microId.length,
          ),
        ),
      ),
    );
  }
}
