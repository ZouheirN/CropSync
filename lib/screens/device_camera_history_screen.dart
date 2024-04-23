import 'package:cached_network_image/cached_network_image.dart';
import 'package:cropsync/json/device_camera.dart';
import 'package:cropsync/services/device_api.dart';
import 'package:cropsync/services/user_token.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:cropsync/widgets/cards.dart';
import 'package:cropsync/widgets/dialogs.dart';
import 'package:cropsync/widgets/disease_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class DeviceCameraHistoryScreen extends StatefulWidget {
  const DeviceCameraHistoryScreen({super.key});

  @override
  State<DeviceCameraHistoryScreen> createState() =>
      _DeviceCameraHistoryScreenState();
}

class _DeviceCameraHistoryScreenState extends State<DeviceCameraHistoryScreen> {
  DeviceCamera? deviceCamera;

  var images = <String>[];
  var dates = <DateTime>[];
  int page = 1;

  bool isLoading = false;
  bool hasReachedMax = false;

  String token = '';

  void fetchData() async {
    setState(() {
      isLoading = true;
    });

    final response =
        await DeviceApi.getDeviceImages(deviceCamera!.deviceId!, page);

    if (!mounted) return;

    if (response == ReturnTypes.endOfPages) {
      setState(() {
        hasReachedMax = true;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        images.addAll(response!.images!);
        dates.addAll(response.cameraCollectionDate!);
        page++;
      });
    }
  }

  Future<void> handlePopupMenuPress(String value, int index) async {
    switch (value) {
      case 'Save to Gallery':
        // Check for access permission
        final hasAccess = await Gal.hasAccess();

        if (!hasAccess) {
          await Gal.requestAccess();
        }

        final directory = await getExternalStorageDirectories(
            type: StorageDirectory.pictures);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloading image...'),
          ),
        );

        // Download Image
        final imagePath =
            '${directory?.first.path}/${deviceCamera!.name}_${dates[index].millisecondsSinceEpoch}.jpg';
        final response =
            await DeviceApi.downloadImage(images[index], imagePath);

        if (response != ReturnTypes.success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error download image'),
            ),
          );
          return;
        }

        await Gal.putImage(imagePath);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image saved to gallery'),
          ),
        );
        break;
      case 'Change Prediction':
        final newPrediction = await Dialogs.showChangePredictionDialog(context);

        if (newPrediction == "null") {
          return;
        }

        // todo change on server

        break;
    }
  }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      setState(() {
        deviceCamera = args['deviceCamera'] as DeviceCamera;
      });
    });

    UserToken.getToken().then(
      (value) {
        token = value;
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // todo add date range

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(child: Text('${deviceCamera?.name!} Camera History')),
      ),
      body: InfiniteList(
        itemCount: images.length,
        isLoading: isLoading,
        centerLoading: true,
        hasReachedMax: hasReachedMax,
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
          return StickyHeader(
            header: Container(
              height: 50.0,
              color: Colors.blueGrey[700],
              padding: const EdgeInsets.only(left: 16.0),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    convertDateFormat(dates[index].toString(), withTime: true),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Text(
                    'Prediction',
                    style: TextStyle(color: Colors.white),
                  ),
                  PopupMenuButton(
                    onSelected: (String value) {
                      handlePopupMenuPress(value, index);
                    },
                    itemBuilder: (context) {
                      return {'Save to Gallery', 'Change Prediction'}
                          .map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  )
                ],
              ),
            ),
            content: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HeroPhotoViewRouteWrapper(
                      imageProvider: CachedNetworkImageProvider(images[index]),
                    ),
                  ),
                );
              },
              child: CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200.0,
                progressIndicatorBuilder: (context, url, downloadProgress) {
                  return Center(
                    child: CircularProgressIndicator(
                        value: downloadProgress.progress),
                  );
                },
                httpHeaders: {
                  "Authorization": "Bearer $token",
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
