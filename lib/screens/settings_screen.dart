import 'package:cropsync/main.dart';
import 'package:cropsync/models/home_list_items_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:watch_it/watch_it.dart';

class SettingsScreen extends WatchingStatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final userPrefsBox = Hive.box('userPrefs');
  String version = '';

  @override
  void initState() {
    PackageInfo.fromPlatform()
        .then((value) => setState(() => version = value.version));
    super.initState();
  }

  Widget checkIndex(String name) {
    switch (name) {
      case 'Weather':
        return const Icon(
          Icons.wb_cloudy_rounded,
          color: Colors.blue,
        );
      case 'Alerts':
        return const Icon(
          Icons.notifications_rounded,
          color: Colors.red,
        );
      case 'Device Camera':
        return const Icon(
          Icons.camera_alt_rounded,
          color: Colors.green,
        );
      default:
        return const Icon(Icons.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> listItems =
        watchPropertyValue((HomeListItemsModel h) => h.listItems);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        children: [
          Text(
            'General',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(10),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            header: const Text(
              'Home Items Order',
              style: TextStyle(fontSize: 18),
            ),
            itemBuilder: (context, index) {
              return ListTile(
                leading: checkIndex(listItems[index]),
                key: ValueKey(index),
                title: Text(listItems[index]),
                trailing: const Icon(Icons.drag_handle_rounded),
              );
            },
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final item = listItems.removeAt(oldIndex);
              listItems.insert(newIndex, item);
              di<HomeListItemsModel>().homeListItems = listItems;
            },
            itemCount: listItems.length,
          ),
          const Gap(20),
          Text(
            'Personalization',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SwitchListTile(
            title: const Text('Dark Theme'),
            value: MyApp.themeNotifier.value == ThemeMode.dark,
            onChanged: (value) async {
              userPrefsBox.put(
                'darkModeEnabled',
                MyApp.themeNotifier.value == ThemeMode.light ? true : false,
              );

              setState(() {
                MyApp.themeNotifier.value =
                    value ? ThemeMode.dark : ThemeMode.light;
              });
            },
          ),
          const Gap(20),
          Text(
            'About',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          AboutListTile(
            icon: const Icon(Icons.info),
            applicationName: 'CropSync',
            applicationVersion: version,
            aboutBoxChildren: const [
              Text('CropSync is a project made by:\n'
                  '• Zouheir Nakouzi\n'
                  '• Ibrahim Mneimneh\n'
                  '• Samer Damaj\n'
                  '• Hamza Mrad\n'
                  '• Noor Al Khatib\n'
                  '• Jamal Chabaan'),
            ],
          ),
        ],
      ),
    );
  }
}
