import 'package:cropsync/models/devices_model.dart';
import 'package:cropsync/services/device_api.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:cropsync/widgets/dialogs.dart';
import 'package:cropsync/widgets/textfields.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:logger/logger.dart';
import 'package:watch_it/watch_it.dart';

class EditDeviceScreen extends StatefulWidget {
  const EditDeviceScreen({super.key});

  @override
  State<EditDeviceScreen> createState() => _EditDeviceScreenState();
}

class _EditDeviceScreenState extends State<EditDeviceScreen> {
  final formKey = GlobalKey<FormState>();

  final deviceNameController = TextEditingController();
  final deviceLocationController = TextEditingController();
  final deviceCodeController = TextEditingController();

  bool isLoading = false;

  Future<void> confirmEdit() async {
    if (formKey.currentState!.validate()) {
      if (isLoading) return;

      setState(() {
        isLoading = true;
      });

      final arg = ModalRoute.of(context)!.settings.arguments as Map;
      final device = arg['device'];

      // edit device on server
      final globalResult = await DeviceApi.editDevice(
        deviceId: device.deviceId,
        name: deviceNameController.text.trim(),
        location: deviceLocationController.text.trim(),
      );

      if (!mounted) return;
      if (globalResult == ReturnTypes.fail) {
        setState(() {
          isLoading = false;
        });
        Dialogs.showErrorDialog(
            'Error', 'Editing device failed, try again', context);
        return;
      } else if (globalResult == ReturnTypes.error) {
        setState(() {
          isLoading = false;
        });
        Dialogs.showErrorDialog(
            'Error', 'An error occurred, try again', context);
        return;
      }

      Logger().d('Device edited on server');

      di<DevicesModel>().editDevice(
        id: device.deviceId,
        name: deviceNameController.text.trim(),
        location: deviceLocationController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);
      Dialogs.showSuccessDialog('Success',
          '${deviceNameController.text.trim()} has been edited!', context);
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final arg = ModalRoute.of(context)!.settings.arguments as Map;
      final device = arg['device'];
      deviceNameController.text = device.name;
      deviceLocationController.text = device.location;
      deviceCodeController.text = device.code;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Device')),
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
              text: 'Edit',
              textColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              isLoading: isLoading,
              onPressed: confirmEdit,
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
          hintText: 'Enter Device Name',
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
                icon: const Icon(Icons.edit_location_rounded))
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
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Device Configuration',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Gap(10),
        PrimaryTextField(
          enabled: false,
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
