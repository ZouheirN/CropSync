import 'package:cached_network_image/cached_network_image.dart';
import 'package:cropsync/json/device.dart';
import 'package:cropsync/json/plants.dart';
import 'package:cropsync/main.dart';
import 'package:cropsync/models/devices_model.dart';
import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/services/device_api.dart';
import 'package:cropsync/services/trefle_api.dart';
import 'package:cropsync/widgets/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';
import 'package:watch_it/watch_it.dart';

void invalidTokenResponse(BuildContext context) {
  di<UserModel>().logout();
  Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
  Dialogs.showErrorDialog(
      'Error', 'Your session has expired. Please log in again.', context);
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
      Dialogs.showErrorDialog('Error', 'An error occurred, try again', context);
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

        return InfiniteList(
          separatorBuilder: (context, index) => const Divider(),
          itemCount: plants.length,
          isLoading: isLoading,
          hasReachedMax: hasReachedMax,
          centerLoading: true,
          onFetchData: fetchData,
          physics: const BouncingScrollPhysics(),
          loadingBuilder: (context) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                PlantSearchDelegate(device).setPlant(
                  imageUrl: plants[index].imageUrl!,
                  name: plants[index].commonName!,
                  context: context,
                );
              },
              leading: CachedNetworkImage(
                imageUrl: plants[index].imageUrl!,
                imageBuilder: (context, imageProvider) => Container(
                  width: 100,
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              title: Text(plants[index].commonName!),
            );
          },
        );
        // return ListView.separated(
        //   separatorBuilder: (context, index) => const Divider(),
        //   itemCount: plants!.length,
        //   padding: const EdgeInsets.all(16),
        //   itemBuilder: (context, index) {
        //     return ListTile(
        //       onTap: () {
        //         setPlant(
        //           imageUrl: plants![index].imageUrl!,
        //           name: plants![index].commonName!,
        //           context: context,
        //         );
        //       },
        //       leading: CachedNetworkImage(
        //         imageUrl: plants![index].imageUrl!,
        //         imageBuilder: (context, imageProvider) => Container(
        //           width: 100,
        //           height: 200,
        //           decoration: BoxDecoration(
        //             image: DecorationImage(
        //               image: imageProvider,
        //               fit: BoxFit.cover,
        //             ),
        //           ),
        //         ),
        //         placeholder: (context, url) =>
        //             const CircularProgressIndicator(),
        //         errorWidget: (context, url, error) => const Icon(Icons.error),
        //       ),
        //       title: Text(plants![index].commonName!),
        //     );
        //   },
        // );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
