import 'dart:io';

import 'package:cropsync/json/image.dart';
import 'package:cropsync/main.dart';
import 'package:cropsync/models/image_model.dart';
import 'package:cropsync/widgets/disease_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
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
        result: '',
      ));
    });

    //todo send to server
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
            _buildGrid(images),
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

  Widget _buildGrid(images) {
    int columnCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: AnimationLimiter(
        child: GridView.count(
          crossAxisCount: columnCount,
          children: List.generate(
            images.length,
            (index) {
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 375),
                columnCount: columnCount,
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: FocusedMenuHolder(
                      menuItems: [
                        FocusedMenuItem(
                          title: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              di<ImageModel>().deleteImage(index);
                            });
                          },
                          backgroundColor: Colors.red,
                          trailingIcon:
                              const Icon(Icons.delete_forever_rounded),
                        ),
                      ],
                      menuWidth: MediaQuery.of(context).size.width * 0.5,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HeroPhotoViewRouteWrapper(
                              imageProvider: MemoryImage(
                                images[index].image,
                              ),
                            ),
                          ),
                        );
                      },
                      child: DiseasePicture(index: index),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
