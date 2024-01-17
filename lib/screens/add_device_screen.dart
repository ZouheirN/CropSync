import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/services/api_service.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:cropsync/widgets/dialogs.dart';
import 'package:cropsync/widgets/textfields.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:logger/logger.dart';
import 'package:watch_it/watch_it.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final formKey = GlobalKey<FormState>();

  final deviceNameController = TextEditingController();
  final deviceLocationController = TextEditingController();
  final deviceCodeController = TextEditingController();

  bool isLoading = false;
  Text status = const Text("");

  Future<void> confirm() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final result = await ApiRequests.deviceConfiguration(
        deviceCodeController.text.trim(),
      );

      if (result == ReturnTypes.fail) {
        setState(() {
          isLoading = false;
          status = const Text(
            "Configuration failed, try again",
            style: TextStyle(color: Colors.red),
          );
        });
        return;
      } else if (result == ReturnTypes.error) {
        setState(() {
          isLoading = false;
          status = const Text(
            "An error occurred, try again",
            style: TextStyle(color: Colors.red),
          );
        });
        return;
      } else if (result == ReturnTypes.alreadyConfigured) {
        setState(() {
          isLoading = false;
          status = const Text(
            "Device is already configured",
            style: TextStyle(color: Colors.red),
          );
        });
        return;
      }

      Logger().d('Device Name: ${deviceNameController.text}');
      Logger().d('Device Location: ${deviceLocationController.text}');

      // todo add device and get id
      const id = 10;
      di<UserModel>().addDevice(id, deviceNameController.text);

      if (!mounted) return;
      Navigator.pop(context);
      Dialogs.showSuccessDialog('Success', '${deviceNameController.text.trim()} was configured and added!', context);
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
            buildDeviceNameField(),
            const Gap(20),
            buildDeviceLocationField(),
            const Gap(20),
            buildDeviceConfigField(),
            const Gap(20),
            CommonButton(
              text: 'Confirm',
              textColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              isLoading: isLoading,
              onPressed: confirm,
            ),
            const Gap(20),
            Center(child: status),
          ],
        ),
      ),
    );
  }

  // Device Name Field
  Widget buildDeviceNameField() {
    return Column(
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
      ],
    );
  }

  // Device Location Field
  Widget buildDeviceLocationField() {
    return Column(
      children: [
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
                  final location =
                      await Navigator.of(context).pushNamed('/add-device-map');

                  if (location.toString() != "null") {
                    setState(() {
                      deviceLocationController.text = location.toString();
                    });
                  }
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
      ],
    );
  }

  Widget buildDeviceConfigField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Device Configuration',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
                onPressed: () async {}, icon: const Icon(Icons.info_rounded))
          ],
        ),
        const Gap(10),
        PrimaryTextField(
          hintText: 'Device Code',
          textController: deviceCodeController,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your device\'s code';
            }

            return null;
          },
        ),
      ],
    );
  }
}
