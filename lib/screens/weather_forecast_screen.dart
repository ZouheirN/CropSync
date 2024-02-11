import 'package:cropsync/services/weather_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as Map;
    final String deviceId = arg['deviceId'];

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
                return Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: AnimationLimiter(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: const SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Text('Weather Forecast'),
                            ),
                          ),
                        );
                      },
                      itemCount: snapshot.data.length,
                    ),
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
