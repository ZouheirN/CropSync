import 'package:cropsync/main.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:cropsync/widgets/dialogs.dart';
import 'package:cropsync/widgets/textfields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final formKey = GlobalKey<FormState>();
  final cityTextController = TextEditingController();
  final countryTextController = TextEditingController();
  final panelController = PanelController();
  final mapController = MapController();

  bool isLoading = false;

  List<CircleMarker> _circles = [];

  void _confirm() {
    if (formKey.currentState!.validate()) {}
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return Future.error('Location services are disabled.');
      Dialogs.showErrorDialog('Location services are disabled',
          'Please enable location services to continue.', context);
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return Future.error('Location permissions are denied');
        Dialogs.showErrorDialog('Location permissions are denied',
            'Please enable location permissions to continue.', context);
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
      Dialogs.showErrorDialog('Location permissions are permanently denied',
          'Please enable location permissions to continue.', context);
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _onMapTap(tapPosition, LatLng position) async {
    panelController.open();

    setState(() {
      isLoading = true;
      _circles = [
        CircleMarker(
          point: position,
          color: Colors.red.withOpacity(0.3),
          borderColor: Colors.red.withOpacity(0.7),
          borderStrokeWidth: 2,
          radius: 1000,
          useRadiusInMeter: true,
        )
      ];
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude,
          localeIdentifier: 'en_LB');

      print(placemarks);

      setState(() {
        cityTextController.text = placemarks[0].subAdministrativeArea!;
        countryTextController.text = placemarks[0].country!;
      });
    } on Exception {
      if (!mounted) return;
      Dialogs.showErrorDialog('Network Error', 'Please try again.', context);
    } catch (e) {
      if (!mounted) return;
      Dialogs.showErrorDialog('Unknown Error', 'Please try again.', context);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Device'),
        actions: [
          if (_circles.isNotEmpty)
            IconButton(
              onPressed: () {
                mapController.move(_circles[0].point, 13);
              },
              icon: const Icon(Icons.gps_not_fixed_rounded),
            )
        ],
      ),
      body: SlidingUpPanel(
        parallaxEnabled: true,
        defaultPanelState: PanelState.CLOSED,
        controller: panelController,
        color: Colors.transparent,
        maxHeight: MediaQuery.of(context).size.height * 0.3,
        panel: _buildPanel(),
        body: _buildMap(),
      ),
    );
  }

  Widget _buildPanel() {
    return Form(
      key: formKey,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          color: MyApp.themeNotifier.value == ThemeMode.light
              ? Colors.white
              : const Color(0xFF1B2522),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const Icon(
                Icons.drag_handle_rounded,
                color: Colors.grey,
              ),
              SecondaryButton(
                icon: Icons.gps_fixed_rounded,
                text: 'Get Current Location',
                isLoading: isLoading,
                onPressed: () async {
                  if (isLoading) return;

                  setState(() {
                    isLoading = true;
                  });

                  await _getCurrentLocation().then((value) async {
                    try {
                      List<Placemark> placemarks =
                          await placemarkFromCoordinates(
                              value.latitude, value.longitude,
                              localeIdentifier: 'en_LB');

                      panelController.open();
                      mapController.move(
                          LatLng(value.latitude, value.longitude), 15);

                      setState(() {
                        _circles = [
                          CircleMarker(
                            point: LatLng(value.latitude, value.longitude),
                            color: Colors.red.withOpacity(0.3),
                            borderColor: Colors.red.withOpacity(0.7),
                            borderStrokeWidth: 2,
                            radius: 1000,
                            useRadiusInMeter: true,
                          )
                        ];
                        cityTextController.text =
                            placemarks[0].subAdministrativeArea!;
                        countryTextController.text = placemarks[0].country!;
                      });
                    } on Exception {
                      if (!mounted) return;
                      Dialogs.showErrorDialog(
                          'Network Error', 'Please try again.', context);
                    } catch (e) {
                      if (!mounted) return;
                      Dialogs.showErrorDialog(
                          'Unknown Error', 'Please try again.', context);
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  });
                },
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: PrimaryTextField(
                      hintText: 'City',
                      textController: cityTextController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter city';
                        }
                        return null;
                      },
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: PrimaryTextField(
                      hintText: 'Country',
                      textController: countryTextController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter country';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const Gap(16),
              CommonButton(
                text: 'Confirm',
                textColor: Colors.white,
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: _confirm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: const LatLng(33.8547, 35.8623),
        initialZoom: 3.2,
        onTap: _onMapTap,
        interactionOptions: const InteractionOptions(
          enableMultiFingerGestureRace: true,
          flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.zouheirn.cropsync',
          tileProvider: FMTC.instance('mapStore').getTileProvider(),
        ),
        CircleLayer(circles: [
          ..._circles,
        ])
      ],
    );
  }
}
