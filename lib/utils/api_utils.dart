import 'package:cropsync/json/device.dart';
import 'package:cropsync/json/plants.dart';
import 'package:cropsync/main.dart';
import 'package:cropsync/models/devices_model.dart';
import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/services/device_api.dart';
import 'package:cropsync/services/trefle_api.dart';
import 'package:cropsync/utils/other_variables.dart';
import 'package:cropsync/widgets/dialogs.dart';
import 'package:cropsync/widgets/plants_list.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

void invalidTokenResponse(BuildContext context) {
  di<UserModel>().logout();
  Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
  Dialogs.showErrorDialog(
      'Error', 'Your session has expired, please log in again', context);
}

enum ReturnTypes {
  success,
  error,
  fail,
  alreadyConfigured,
  hasNotBeenConfigured,
  emailTaken,
  invalidToken,
  noDevices,
  invalidPassword,
  endOfPages,
}

String? getLabelForId(int id) {
  final List<Map<String, dynamic>> frequency = OtherVars().frequency;

  for (var item in frequency) {
    if (item['id'] == id) {
      return item['label'];
    }
  }

  // Return null if id is not found
  return null;
}

class PlantSearchDelegate extends SearchDelegate {
  final Device device;

  PlantSearchDelegate(this.device);

  Future<void> setPlant({
    required String name,
    required String imageUrl,
    required BuildContext context,
  }) async {
    final choice = await Dialogs.showConfirmationDialog(
        'Confirm Selection', 'Are you sure you want to select $name?', context);

    if (!choice) return;

    if (!context.mounted) return;
    Dialogs.showLoadingDialog('Setting Crop...', context);

    final response = await DeviceApi.setDeviceCrop(
      deviceId: device.deviceId!,
      name: name,
      imageUrl: imageUrl,
    );

    if (!context.mounted) return;
    if (response == ReturnTypes.fail) {
      Navigator.pop(context);
      Dialogs.showErrorDialog(
          'Error', 'Assigning crop failed, try again', context);
      return;
    } else if (response == ReturnTypes.error) {
      Navigator.pop(context);
      Dialogs.showErrorDialog(
          'Error', 'An error occurred, try again', context);
      return;
    }

    logger.d('Crop added on server');

    di<DevicesModel>().setCrop(
      id: device.deviceId!,
      name: name,
      profile: imageUrl,
    );

    if (!context.mounted) return;

    Navigator.pop(context);
    Dialogs.showSuccessDialog('Success', '$name has been selected!', context);
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear_rounded),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    var plants = <PlantsDatum>[];
    int page = 1;
    bool noResultsFound = false;
    bool isLoading = false;
    bool hasReachedMax = false;

    return StatefulBuilder(
      builder: (context, setState) {
        void fetchData() async {
          setState(() {
            isLoading = true;
          });

          final response = await TrefleApi.searchPlants(query, page);
          if (!context.mounted) return;

          if (response == ReturnTypes.endOfPages) {
            setState(() {
              hasReachedMax = true;
              isLoading = false;
            });
          } else if (response.isEmpty) {
            setState(() {
              isLoading = false;
              noResultsFound = true;
            });
          } else {
            setState(() {
              page++;
              isLoading = false;
              plants.addAll(response!);
            });
          }
        }

        if (noResultsFound) {
          return const Center(
            child: Text('No results found'),
          );
        }

        return PlantsList(
          plants: plants,
          isLoading: isLoading,
          hasReachedMax: hasReachedMax,
          fetchData: fetchData,
          device: device,
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
