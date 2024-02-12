import 'package:cropsync/json/weather_forecast.dart';
import 'package:cropsync/services/weather_api.dart';
import 'package:cropsync/widgets/cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:logger/logger.dart';

class WeatherForecastScreen extends StatefulWidget {
  const WeatherForecastScreen({super.key});

  @override
  State<WeatherForecastScreen> createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  late Future? dataFuture;

  @override
  void initState() {
    dataFuture = getData();
    super.initState();
  }

  Future getData() async {
    final weatherForecast = await WeatherApi.getWeatherForecastData();
    if (weatherForecast.runtimeType == List<WeatherForecast>) {
      Logger().d('Fetched Weather Forecast');
      return weatherForecast;
    }
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as Map;
    final String deviceId = arg['deviceId'];
    final String deviceName = arg['deviceName'];
    final String deviceLocation = arg['deviceLocation'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('3 Day Weather Forecast'),
        centerTitle: false,
      ),
      body: FutureBuilder(
        future: dataFuture,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (snapshot.hasData) {
                final filteredData =
                    snapshot.data.where((e) => e.deviceId == deviceId).toList();
                return Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const FaIcon(FontAwesomeIcons.raspberryPi),
                          const Gap(8),
                          Text(
                            deviceName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const FaIcon(FontAwesomeIcons.locationDot),
                          const Gap(8),
                          Text(
                            deviceLocation,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: AnimationLimiter(
                            child: ListView.builder(
                              itemCount: filteredData.first.weatherData.length,
                              itemBuilder: (context, index) =>
                                  AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 300,
                                          child: WeatherForecastCard(
                                            weather: filteredData
                                                .first.weatherData[index],
                                            context: context,
                                          ),
                                        ),
                                        const Gap(20)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: Text('Failed to load data. Please try again.'),
                );
              }
          }
        },
      ),
    );
  }
}
