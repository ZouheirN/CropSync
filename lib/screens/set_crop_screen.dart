import 'package:cropsync/json/device.dart';
import 'package:cropsync/json/plants.dart';
import 'package:cropsync/services/trefle_api.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:cropsync/widgets/plants_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SetCropScreen extends StatefulWidget {
  const SetCropScreen({super.key});

  @override
  State<SetCropScreen> createState() => _SetCropScreenState();
}

class _SetCropScreenState extends State<SetCropScreen> {
  Device? device;
  bool isLoading = false;
  bool hasReachedMax = false;

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
        hasReachedMax = true;
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
      setState(() {
        device = args['device'] as Device;
      });
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
      body: device == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : PlantsList(
              plants: plants,
              isLoading: isLoading,
              hasReachedMax: hasReachedMax,
              fetchData: fetchData,
              device: device!,
            ),
    );
  }
}
