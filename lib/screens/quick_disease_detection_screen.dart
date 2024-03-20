import 'dart:io';

import 'package:cropsync/json/image.dart';
import 'package:cropsync/main.dart';
import 'package:cropsync/models/image_model.dart';
import 'package:cropsync/services/disease_api.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:cropsync/widgets/disease_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:gap/gap.dart';
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
  void pickImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;

    File? img = File(image.path);
    img = await cropImage(imageFile: img);

    if (img == null) return;

    di<ImageModel>().addImage(ImageObject(
      image: img.readAsBytesSync(),
      result: '',
      uploadProgress: 0,
      info: '',
    ));

//todo send to server
// final response = DiseaseApi.uploadDiseaseImage(
//   image: base64Encode(img.readAsBytesSync()),
//   index: di<ImageModel>().images.length - 1,
// );

    DiseaseApi.getDiseaseData(
      img.readAsBytesSync(),
      di<ImageModel>().images.length - 1,
    );
  }

  Future<File?> cropImage({required File imageFile}) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: const [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
      compressQuality: 100,
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

  void showSelectPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      // isScrollControlled: fa,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.drag_handle_rounded,
                color: Colors.grey,
              ),
              SecondaryButton(
                onPressed: () => pickImage(ImageSource.gallery),
                icon: Icons.image_rounded,
                text: 'Browse Gallery',
              ),
              const Gap(10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 5, right: 15),
                      child: const Divider(
                        color: Colors.white,
                        height: 10,
                      ),
                    ),
                  ),
                  const Text(
                    'or',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 15, right: 5),
                      child: const Divider(
                        color: Colors.white,
                        height: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              SecondaryButton(
                onPressed: () => pickImage(ImageSource.camera),
                icon: Icons.camera_alt_outlined,
                text: 'Use a Camera',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dynamic images =
        watchPropertyValue((ImageModel m) => m.images.toList());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Disease Detection'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_rounded),
            onPressed: () {
              showSelectPhotoOptions(context);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: images.isEmpty
            ? const Center(
                child: Text(
                  'Start by taking pictures of leaves to detect diseases.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
              )
            : Column(
                children: [
                  buildGrid(images),
                ],
              ),
      ),
    );
  }

  Widget buildGrid(images) {
    int columnCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;

    return Expanded(
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
                            'More Information',
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('More Information'),
                                  content: Text(images[index].info ?? ''),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          backgroundColor: Colors.white,
                          trailingIcon: const Icon(
                            Icons.info_rounded,
                            color: Colors.black,
                          ),
                        ),
                        FocusedMenuItem(
                          title: Text(
                            images[index].result == 'Upload Failed' ||
                                    images[index].result == 'Uploading...'
                                ? 'Retry Upload'
                                : 'Re-Upload',
                            style: const TextStyle(color: Colors.black),
                          ),
                          onPressed: () {
                            DiseaseApi.getDiseaseData(
                              images[index].image,
                              di<ImageModel>().images.length - 1,
                            );
// DiseaseApi.uploadDiseaseImage(
//   image: base64Encode(images[index].image),
//   index: index,
// );
                          },
                          backgroundColor: Colors.white,
                          trailingIcon: const Icon(
                            Icons.file_upload_rounded,
                            color: Colors.black,
                          ),
                        ),
                        FocusedMenuItem(
                          title: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            di<ImageModel>().deleteImage(index);
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
