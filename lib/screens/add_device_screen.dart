import 'package:cropsync/models/devices_model.dart';
import 'package:cropsync/services/device_api.dart';
import 'package:cropsync/services/local_device_api.dart';
import 'package:cropsync/utils/api_utils.dart';
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

  Future<void> confirm() async {
    if (formKey.currentState!.validate()) {
      if (isLoading) return;

      setState(() {
        isLoading = true;
      });

      // check if device is already configured
      final isDeviceAlreadyConfigured =
          await LocalDeviceApi.isDeviceAlreadyConfigured(
              deviceCodeController.text.trim());

      if (!mounted) return;
      if (isDeviceAlreadyConfigured == ReturnTypes.fail) {
        setState(() {
          isLoading = false;
        });
        Dialogs.showErrorDialog(
            'Error', 'Configuration failed, try again', context);
        return;
      } else if (isDeviceAlreadyConfigured == ReturnTypes.error) {
        setState(() {
          isLoading = false;
        });
        Dialogs.showErrorDialog(
            'Error', 'An error occurred, try again', context);
        return;
      } else if (isDeviceAlreadyConfigured) {
        setState(() {
          isLoading = false;
        });
        Dialogs.showErrorDialog(
            'Error', 'Device is already configured', context);
        return;
      }

      Logger().d('Device is not configured');

      // add device to server and get activation key
      final globalResult = await DeviceApi.addDevice(
        name: deviceNameController.text.trim(),
        location: deviceLocationController.text.trim(),
        code: deviceCodeController.text.trim(),
      );

      if (!mounted) return;
      if (globalResult == ReturnTypes.fail) {
        setState(() {
          isLoading = false;
        });
        Dialogs.showErrorDialog(
            'Error', 'Adding device failed, try again', context);
        return;
      } else if (globalResult == ReturnTypes.error) {
        setState(() {
          isLoading = false;
        });
        Dialogs.showErrorDialog(
            'Error', 'An error occurred, try again', context);
        return;
      }

      Logger().d('Device added to server');

      // configure local device using activation key
      final localResult = await LocalDeviceApi.addDeviceConfiguration(
        deviceCode: deviceCodeController.text.trim(),
        activationKey: globalResult["deviceId"],
      );

      if (!mounted) return;
      if (localResult == ReturnTypes.fail) {
        setState(() {
          isLoading = false;
        });
        Dialogs.showErrorDialog(
            'Error', 'Configuration failed, try again', context);
        return;
      } else if (localResult == ReturnTypes.error) {
        setState(() {
          isLoading = false;
        });
        Dialogs.showErrorDialog(
            'Error', 'An error occurred, try again', context);
        return;
      }

      Logger().d('Device configured locally');

      di<DevicesModel>().addDevice(
        id: globalResult["deviceId"],
        name: deviceNameController.text.trim(),
        isConnected: globalResult["isConnected"],
        location: deviceLocationController.text.trim(),
        code: deviceCodeController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);
      Dialogs.showSuccessDialog(
          'Success',
          '${deviceNameController.text.trim()} has been configured and added!',
          context);
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
          ],
        ),
      ),
    );
  }

  // Device Name Field
  Widget buildDeviceNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                onPressed: () {
                  Dialogs.showInformationDialog(
                      'Device Configuarion',
                      'This is the code that you will find on your device\'s package, or you can check it from the device\'s hotspot name.\n\nMake sure you are connected to the same network as your device.',
                      context);
                },
                icon: const Icon(Icons.info_rounded))
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
