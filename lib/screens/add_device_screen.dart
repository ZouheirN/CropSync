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
  final _formKey = GlobalKey<FormState>();
  final _cityTextController = TextEditingController();
  final _countryTextController = TextEditingController();
  final _panelController = PanelController();
  final _mapController = MapController();

  bool _isLoading = false;

  void _confirm() {
    if (_formKey.currentState!.validate()) {}
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return Future.error('Location services are disabled.');
      showErrorDialog('Location services are disabled',
          'Please enable location services to continue.', context);
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return Future.error('Location permissions are denied');
        showErrorDialog('Location permissions are denied',
            'Please enable location permissions to continue.', context);
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
      showErrorDialog('Location permissions are permanently denied',
          'Please enable location permissions to continue.', context);
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Device'),
      ),
      body: SlidingUpPanel(
        parallaxEnabled: true,
        defaultPanelState: PanelState.CLOSED,
        controller: _panelController,
        maxHeight: MediaQuery.of(context).size.height * 0.3,
        panel: _buildPanel(),
        body: _buildMap(),
      ),
    );
  }

  Widget _buildPanel() {
    return Form(
      key: _formKey,
      child: Container(
        color: MyApp.themeNotifier.value == ThemeMode.light
            ? Colors.white
            : const Color(0xFF191C1B),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const Icon(
                Icons.drag_handle_rounded,
                color: Colors.grey,
              ),
              PrimaryButton(
                text: 'Get Current Location',
                isLoading: _isLoading,
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });

                  await _getCurrentLocation().then((value) async {
                    try {
                      List<Placemark> placemarks =
                          await placemarkFromCoordinates(
                              value.latitude, value.longitude);

                      _panelController.open();
                      _mapController.move(
                          LatLng(value.latitude, value.longitude), 15);

                      setState(() {
                        _cityTextController.text =
                            placemarks[0].subAdministrativeArea!;
                        _countryTextController.text = placemarks[0].country!;
                      });
                    } on Exception {
                      if (!mounted) return;
                      showErrorDialog(
                          'Network Error', 'Please try again.', context);
                    } catch (e) {
                      if (!mounted) return;
                      showErrorDialog(
                          'Unknown Error', 'Please try again.', context);
                    } finally {
                      setState(() {
                        _isLoading = false;
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
                      textController: _cityTextController,
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
                      textController: _countryTextController,
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
              PrimaryButton(
                text: 'Confirm',
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
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(33.8547, 35.8623),
        initialZoom: 3.2,
        interactionOptions: InteractionOptions(
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
      ],
    );
  }
}
