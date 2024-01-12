import 'package:cropsync/widgets/buttons.dart';
import 'package:cropsync/widgets/textfields.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final formKey = GlobalKey<FormState>();

  final deviceNameController = TextEditingController();
  final deviceLocationController = TextEditingController();

  bool isLoading = false;

  void confirm() {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      debugPrint('Device Name ${deviceNameController.text}');
      debugPrint('Device Location ${deviceLocationController.text}');

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Device')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Device Name',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(10),
            PrimaryTextField(
              hintText: 'Enter device name',
              textController: deviceNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a device name';
                }

                return null;
              },
            ),
            const Gap(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Device Location',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      final location = await Navigator.of(context)
                          .pushNamed('/add-device-map');
                      setState(() {
                        deviceLocationController.text = location.toString();
                      });
                    },
                    icon: const Icon(Icons.add_location_rounded))
              ],
            ),
            const Gap(10),
            PrimaryTextField(
              hintText: 'Choose Location',
              enabled: false,
              textController: deviceLocationController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please choose your device\'s location';
                }

                return null;
              },
            ),
            const Gap(20),
            CommonButton(
              text: 'Confirm',
              textColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              isLoading: isLoading,
              onPressed: confirm,
            ),
          ],
        ),
      ),
    );
  }
}
