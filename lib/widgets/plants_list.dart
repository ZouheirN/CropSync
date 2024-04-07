import 'package:cached_network_image/cached_network_image.dart';
import 'package:cropsync/json/device.dart';
import 'package:cropsync/json/plants.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:flutter/material.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class PlantsList extends StatelessWidget {
  final List<PlantsDatum> plants;
  final bool isLoading;
  final bool hasReachedMax;
  final void Function() fetchData;
  final Device device;

  const PlantsList({
    super.key,
    required this.plants,
    required this.isLoading,
    required this.hasReachedMax,
    required this.fetchData,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
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
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                SizedBox(
              width: 100,
              height: 200,
              child: Center(
                child:
                    CircularProgressIndicator(value: downloadProgress.progress),
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          title: Text(plants[index].commonName!),
          subtitle: Text(plants[index].scientificName ?? ''),
        );
      },
    );
  }
}
