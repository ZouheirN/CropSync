import 'package:cropsync/services/user_info.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            child: const Text('Change microId'),
            onPressed: () {
              di<UserInfoModel>().microId = ['1234567890'];
            },
          ),
          ElevatedButton(
            child: const Text('remove microId'),
            onPressed: () {
              di<UserInfoModel>().microId = [];
            },
          ),
        ],
      ),
    );
  }
}
