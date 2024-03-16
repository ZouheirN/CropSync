import 'package:cached_network_image/cached_network_image.dart';
import 'package:cropsync/json/device.dart';
import 'package:cropsync/json/plants.dart';
import 'package:cropsync/services/trefle_api.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class SetCropScreen extends StatefulWidget {
  const SetCropScreen({super.key});

  @override
  State<SetCropScreen> createState() => _SetCropScreenState();
}

class _SetCropScreenState extends State<SetCropScreen> {
  Device? device;
  bool isLoading = false;

  var plants = <PlantsDatum>[];
  int page = 1;
  final searchController = TextEditingController();

  void fetchData() async {
    setState(() {
      isLoading = true;
    });

    final response = await TrefleApi.getPlants(page);

    if (!mounted) return;

    if (response == ReturnTypes.endOfPages) {
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        plants.addAll(response!);
        page++;
      });
    }
  }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      device = args['device'] as Device;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Crop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              showSearch(
                context: context,
                delegate: PlantSearchDelegate(
                  device!,
                ),
              );
            },
          ),
        ],
      ),
      body: InfiniteList(
        separatorBuilder: (context, index) => const Divider(),
        itemCount: plants.length,
        isLoading: isLoading,
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
              PlantSearchDelegate(device!).setPlant(
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
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            title: Text(plants[index].commonName!),
          );
        },
      ),
    );
  }
}
