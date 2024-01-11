import 'dart:io';

import 'package:cropsync/json/image.dart';
import 'package:cropsync/main.dart';
import 'package:cropsync/models/image_model.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:watch_it/watch_it.dart';

class QuickDiseaseDetectionScreen extends WatchingStatefulWidget {
  const QuickDiseaseDetectionScreen({super.key});

  @override
  State<QuickDiseaseDetectionScreen> createState() =>
      _QuickDiseaseDetectionScreenState();
}

class _QuickDiseaseDetectionScreenState
    extends State<QuickDiseaseDetectionScreen> {
  void _pickImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;

    File? img = File(image.path);
    img = await _cropImage(imageFile: img);

    if (img == null) return;

    setState(() {
      di<ImageModel>().addImage(ImageObject(
        image: img!.readAsBytesSync(),
        status: 'pending',
        result: '',
      ));
    });
  }

  Future<File?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: const [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: MyApp.themeNotifier.value == ThemeMode.light
              ? Colors.white
              : const Color(0xFF191C1B),
          toolbarWidgetColor: MyApp.themeNotifier.value == ThemeMode.light
              ? Colors.black
              : Colors.white,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          rotateButtonsHidden: true,
          rotateClockwiseButtonHidden: true,
          aspectRatioLockEnabled: false,
        ),
      ],
    );
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  @override
  Widget build(BuildContext context) {
    final images = watchPropertyValue((ImageModel m) => m.images);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Disease Detection'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              width: double.infinity,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: MemoryImage(images[index].image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded),
                ),
                IconButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.image),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
