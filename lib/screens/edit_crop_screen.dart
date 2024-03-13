import 'package:cropsync/json/device.dart';
import 'package:cropsync/main.dart';
import 'package:cropsync/models/devices_model.dart';
import 'package:cropsync/services/device_api.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:cropsync/widgets/dialogs.dart';
import 'package:cropsync/widgets/textfields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gap/gap.dart';
import 'package:watch_it/watch_it.dart';

class EditCropScreen extends StatefulWidget {
  const EditCropScreen({super.key});

  @override
  State<EditCropScreen> createState() => _EditCropScreenState();
}

class _EditCropScreenState extends State<EditCropScreen> {
  Device? device;
  final formKey = GlobalKey<FormState>();

  final deviceNameController = TextEditingController();
  final deviceLocationController = TextEditingController();
  final deviceCodeController = TextEditingController();
  final deviceCropController = TextEditingController();

  bool isLoading = false;

  Future<void> confirmEdit() async {
    if (formKey.currentState!.validate()) {
      if (isLoading) return;

      setState(() {
        isLoading = true;
      });

      final response = await DeviceApi.setDeviceCrop(
        deviceId: device!.deviceId!,
        name: deviceCropController.text.trim(),
      );

      if (!mounted) return;
      if (response == ReturnTypes.fail) {
        setState(() {
          isLoading = false;
        });
        Dialogs.showErrorDialog(
            'Error', 'Assigning crop failed, try again', context);
        return;
      } else if (response == ReturnTypes.error) {
        setState(() {
          isLoading = false;
        });
        Dialogs.showErrorDialog(
            'Error', 'An error occurred, try again', context);
        return;
      }

      logger.d('Crop added on server');

      di<DevicesModel>().assignCrop(
        id: device!.deviceId!,
        name: deviceCropController.text.trim(),
        profile: response['profile'],
      );

      if (!mounted) return;
      Navigator.pop(context);
      Dialogs.showSuccessDialog('Success',
          '${deviceNameController.text.trim()} has been edited!', context);
    }
  }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      device = args['device'] as Device;
      deviceNameController.text = device!.name ?? '';
      deviceLocationController.text = device!.location ?? '';
      deviceCodeController.text = device!.code ?? '';
      deviceCropController.text = device!.crop?.name ?? '';
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Crop')),
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
            buildDeviceCropField(),
            const Gap(20),
            CommonButton(
              text: 'Confirm',
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
          textController: deviceNameController,
          enabled: false,
        ),
      ],
    );
  }

  // Device Location Field
  Widget buildDeviceLocationField() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Device Location',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.location_on_rounded)
          ],
        ),
        const Gap(10),
        PrimaryTextField(
          enabled: false,
          textController: deviceLocationController,
        ),
      ],
    );
  }

  // Device Config Field
  Widget buildDeviceConfigField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Device Code',
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
          textController: deviceCodeController,
        ),
      ],
    );
  }

  // Device Crop Field
  Widget buildDeviceCropField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Crop',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Gap(10),
        PrimaryTextField(
          hintText: 'Enter Crop Name',
          textController: deviceCropController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your device\'s crop';
            }

            return null;
          },
        ),
      ],
    );
  }
}
