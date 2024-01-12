import 'package:cropsync/models/user_model.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
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
    final devices = watchPropertyValue((UserModel m) => m.user.devices);

    return Scaffold(
      appBar: AppBar(
        title: Text('Total Devices: ${devices!.length}'),
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
                    child: ExpansionTileCard(
                      title: Text(devices[index].name!),
                      subtitle: Text("ID: ${devices[index].id}"),
                      children: [
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
                              onPressed: () {},
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
