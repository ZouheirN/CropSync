import 'package:cropsync/main.dart';
import 'package:cropsync/utils/user_prefs.dart';
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
  final listPages = [
    'Home',
    'Crops',
    'Camera',
    'Devices',
    'Profile',
  ];

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
      case 'Statistics':
        return const Icon(
          Icons.bar_chart_rounded,
          color: Colors.orange,
        );
      default:
        return const Icon(Icons.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listItems = watchPropertyValue((UserPrefs u) => u.homeListItems);

    final startPage = watchPropertyValue((UserPrefs u) => u.startPage);

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
          ListTile(
            title: const Text('Start Page'),
            trailing: DropdownButton(
              items: listPages
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              value: startPage,
              onChanged: (value) {
                di<UserPrefs>().startPage = value!;
              },
            ),
          ),
          ListTile(
            title: const Text('Home Items Order'),
            subtitle: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                di<UserPrefs>().homeListItems = listItems;
              },
              itemCount: listItems.length,
            ),
          ),
          const Gap(20),
          Text(
            'Personalization',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: MyApp.themeNotifier.value == ThemeMode.dark,
            onChanged: (value) async {
              di<UserPrefs>().darkModeEnabled = value;

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
