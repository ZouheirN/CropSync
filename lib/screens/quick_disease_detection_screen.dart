import 'dart:convert';

import 'package:cropsync/models/image_model.dart';
import 'package:cropsync/services/disease_api.dart';
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
  bool isLocal = true;

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
                onPressed: () => ResNetModelHelper().pickImage(
                  ImageSource.gallery,
                  isLocal: isLocal,
                ),
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
                onPressed: () => ResNetModelHelper().pickImage(
                  ImageSource.camera,
                  isLocal: isLocal,
                ),
                icon: Icons.camera_alt_outlined,
                text: 'Open Camera',
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
            onPressed: () => ResNetModelHelper().loadModel(context),
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
                child: !isLocal
                    ? Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Start by taking pictures of leaves to detect diseases using the Google Generative AI model.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 20),
                              ),
                              const Gap(20),
                              CommonButton(
                                text: 'Choose Picture',
                                textColor: Colors.white,
                                backgroundColor: Theme.of(context).primaryColor,
                                onPressed: () =>
                                    showSelectPhotoOptions(context),
                              ),
                            ],
                          ),
                          Positioned(
                            child: Align(
                              alignment: FractionalOffset.bottomCenter,
                              child: buildSwitch(),
                            ),
                          ),
                        ],
                      )
                    : resNetFilePath == ''
                        ? Stack(
                            children: [
                              Column(
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
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    onPressed: () =>
                                        ResNetModelHelper().loadModel(context),
                                  ),
                                ],
                              ),
                              Positioned(
                                child: Align(
                                  alignment: FractionalOffset.bottomCenter,
                                  child: buildSwitch(),
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
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
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    onPressed: () {
                                      showSelectPhotoOptions(context);
                                    },
                                  ),
                                ],
                              ),
                              Positioned(
                                child: Align(
                                  alignment: FractionalOffset.bottomCenter,
                                  child: buildSwitch(),
                                ),
                              ),
                            ],
                          ),
              )
            : Column(
                children: [
                  buildGrid(images),
                  buildSwitch(),
                ],
              ),
      ),
    );
  }

  Widget buildSwitch() {
    return Row(
      children: [
        const Expanded(
          child: Text('Gemini AI', textAlign: TextAlign.right),
        ),
        Expanded(
          child: Switch(
            value: isLocal,
            onChanged: (value) {
              setState(() {
                isLocal = value;
              });
            },
          ),
        ),
        const Expanded(
          child: Text('Local Model', textAlign: TextAlign.left),
        ),
      ],
    );
  }

  // Build the grid of images
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
                            if (isLocal) {
                              ResNetModelHelper().predict(
                                base64image: base64Encode(images[index].image),
                                index: index,
                              );
                            } else {
                              DiseaseApi.getDiseaseDataFromGemini(
                                images[index].image,
                                index,
                              );
                            }
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
                            ScaffoldMessenger.of(context).clearSnackBars();
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
