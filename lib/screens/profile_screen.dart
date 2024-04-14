import 'dart:convert';
import 'dart:io';

import 'package:cropsync/main.dart';
import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/services/user_api.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:cropsync/widgets/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:watch_it/watch_it.dart';

class ProfileScreen extends WatchingStatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> logout(BuildContext context) async {
    if (await Dialogs.showConfirmationDialog(
            'Logout', 'Are you sure you want to logout?', context) ==
        false) return;

    di<UserModel>().logout();

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
  }

  Future<void> pickImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;

    File? img = File(image.path);
    img = await cropImage(imageFile: img);

    if (img == null) return;

    final base64Image = base64Encode(img.readAsBytesSync());

    di<UserModel>().setImage(img.readAsBytesSync());

    final result =
        await UserApi.updateProfilePicture(base64Image: base64Image);

    if (!mounted) return;
    if (result == ReturnTypes.fail) {
      Dialogs.showErrorDialog('Error', 'An error occurred, try again', context);
      return;
    } else if (result == ReturnTypes.error) {
      Dialogs.showErrorDialog('Error', 'An error occurred, try again', context);
      return;
    } else if (result == ReturnTypes.invalidToken) {
      invalidTokenResponse(context);
      return;
    }
  }

  Future<File?> cropImage({required File imageFile}) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: const [
        CropAspectRatioPreset.square,
      ],
      compressQuality: 60,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: MyApp.themeNotifier.value == ThemeMode.light
              ? Colors.white
              : const Color(0xFF191C1B),
          toolbarWidgetColor: MyApp.themeNotifier.value == ThemeMode.light
              ? Colors.black
              : Colors.white,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          rotateButtonsHidden: true,
          rotateClockwiseButtonHidden: true,
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  Future<void> removeProfilePicture() async {
    final result = await UserApi.removeProfilePicture();

    if (!mounted) return;
    if (result == ReturnTypes.fail) {
      Dialogs.showErrorDialog('Error', 'An error occurred, try again', context);
      return;
    } else if (result == ReturnTypes.error) {
      Dialogs.showErrorDialog('Error', 'An error occurred, try again', context);
      return;
    } else if (result == ReturnTypes.invalidToken) {
      invalidTokenResponse(context);
      return;
    }

    di<UserModel>().removeImage();
  }

  void showSelectPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      // isScrollControlled: true,
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
                onPressed: removeProfilePicture,
                icon: Icons.delete_rounded,
                text: 'Remove Profile Picture',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = watch(di<UserModel>()).user;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: SingleChildScrollView(
          child: AnimationLimiter(
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  Stack(
                    children: [
                      if (user.profilePicture == null)
                        GestureDetector(
                          onTap: () => showSelectPhotoOptions(context),
                          child: const CircleAvatar(
                            radius: 50,
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () => showSelectPhotoOptions(context),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: MemoryImage(user.profilePicture!),
                          ),
                        ),
                      if (user.uploadProgress != 1 && user.uploadProgress != null)
                        Positioned.fill(
                          child: Center(
                            child: CircularProgressIndicator(
                                value: user.uploadProgress),
                          ),
                        ),
                    ],
                  ),
                  const Gap(20),
                  Text(user.fullName!, style: const TextStyle(fontSize: 24)),
                  const Gap(100),
                  ListTile(
                    leading: const Icon(Icons.person_rounded),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    title: const Text('Account Information'),
                    onTap: () {
                      Navigator.of(context).pushNamed('/account-information');
                    },
                  ),
                  const Divider(
                    height: 10,
                    endIndent: 16,
                    indent: 16,
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_rounded),
                    title: const Text('Settings'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).pushNamed('/settings');
                    },
                  ),
                  // ListTile(
                  //   leading: const Icon(Icons.dark_mode_rounded),
                  //   title: const Text('Dark Theme'),
                  //   trailing: Switch(
                  //     value: MyApp.themeNotifier.value == ThemeMode.dark,
                  //     onChanged: (value) async {
                  //       final userPrefsBox = Hive.box('userPrefs');
                  //
                  //       userPrefsBox.put(
                  //         'darkModeEnabled',
                  //         MyApp.themeNotifier.value == ThemeMode.light
                  //             ? true
                  //             : false,
                  //       );
                  //
                  //       setState(() {
                  //         MyApp.themeNotifier.value =
                  //             MyApp.themeNotifier.value == ThemeMode.light
                  //                 ? ThemeMode.dark
                  //                 : ThemeMode.light;
                  //       });
                  //     },
                  //   ),
                  //   // onTap: () async {
                  //   //   final userPrefsBox = Hive.box('userPrefs');
                  //   //
                  //   //   userPrefsBox.put(
                  //   //     'darkModeEnabled',
                  //   //     MyApp.themeNotifier.value == ThemeMode.light
                  //   //         ? true
                  //   //         : false,
                  //   //   );
                  //   //
                  //   //   setState(() {
                  //   //     MyApp.themeNotifier.value =
                  //   //         MyApp.themeNotifier.value == ThemeMode.light
                  //   //             ? ThemeMode.dark
                  //   //             : ThemeMode.light;
                  //   //   });
                  //   // },
                  // ),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded),
                    title: const Text('Logout'),
                    onTap: () => logout(context),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
