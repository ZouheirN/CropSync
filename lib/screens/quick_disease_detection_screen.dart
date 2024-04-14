import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cropsync/json/image.dart';
import 'package:cropsync/main.dart';
import 'package:cropsync/models/image_model.dart';
import 'package:cropsync/services/resnet_model_helper.dart';
import 'package:cropsync/utils/other_variables.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:cropsync/widgets/disease_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:gal/gal.dart';
import 'package:gap/gap.dart';
import 'package:icons_plus/icons_plus.dart';
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

    // DiseaseApi.getDiseaseData(
    //   img.readAsBytesSync(),
    //   di<ImageModel>().images.length - 1,
    // );

    // predict
    final base64Image = base64Encode(img.readAsBytesSync());
    ResnetModelHelper().predict(
      base64Image,
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
    final resNetFilePath =
        watchPropertyValue((OtherVars o) => o.resNetFilePath);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Disease Detection'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: resNetFilePath != '' ? 'Model Loaded' : 'Model Not Loaded',
            onPressed: () => ResnetModelHelper().loadModel(context),
            icon: Brand(
              Brands.tensorflow,
              size: 30,
              colorFilter: ColorFilter.mode(
                resNetFilePath == '' ? Colors.red : Colors.green,
                BlendMode.srcIn,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Choose Picture',
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
            ? Center(
                child: resNetFilePath == ''
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'You need to load a model file to start predicting.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                          ),
                          const Gap(20),
                          CommonButton(
                            text: 'Load Model File',
                            textColor: Colors.white,
                            backgroundColor: Theme.of(context).primaryColor,
                            onPressed: () =>
                                ResnetModelHelper().loadModel(context),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Model loaded.\nStart by taking pictures of leaves to detect diseases.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                          ),
                          const Gap(20),
                          CommonButton(
                            text: 'Choose Picture',
                            textColor: Colors.white,
                            backgroundColor: Theme.of(context).primaryColor,
                            onPressed: () {
                              showSelectPhotoOptions(context);
                            },
                          ),
                        ],
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
                          title: const Text(
                            'Retry',
                            // images[index].result == 'Upload Failed' ||
                            //         images[index].result == 'Uploading...'
                            //     ? 'Retry Upload'
                            //     : 'Re-Upload',
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () {
                            ResnetModelHelper().predict(
                              base64Encode(images[index].image),
                              index,
                            );

                            // DiseaseApi.getDiseaseData(
                            //   images[index].image,
                            //   di<ImageModel>().images.length - 1,
                            // );

                            // DiseaseApi.uploadDiseaseImage(
                            //   image: base64Encode(images[index].image),
                            //   index: index,
                            // );
                          },
                          backgroundColor: Colors.white,
                          trailingIcon: const Icon(
                            FontAwesome.rotate_solid,
                            color: Colors.black,
                          ),
                        ),
                        FocusedMenuItem(
                          title: const Text(
                            'Save to Gallery',
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () async {
                            // Check for access permission
                            final hasAccess = await Gal.hasAccess();

                            if (!hasAccess) {
                              await Gal.requestAccess();
                            }

                            await Gal.putImageBytes(
                              images[index].image,
                              name:
                                  'disease_detection_${DateTime.now().millisecondsSinceEpoch}',
                            );

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Image saved to gallery'),
                              ),
                            );
                          },
                          backgroundColor: Colors.white,
                          trailingIcon: const Icon(Icons.save_rounded,
                              color: Colors.black),
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
                      animateMenuItems: false,
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
