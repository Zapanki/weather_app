import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:weather_app/consts.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);

  Weather? _weather;

  void initState() {
    super.initState();
    _wf.currentWeatherByCityName("Thessaloniki").then((w) {
      setState(() {
        _weather = w;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (_weather == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _locationMeader(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.08,
          ),
          _dateTimeInfo(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.05,
          ),
          _weatherIcon(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _currentTemp(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _extraInfo(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _feelsLike(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _maxMinTemp(),
        ],
      ),
    );
  }

  Widget _locationMeader() {
    return Text(
      _weather?.areaName ?? "Loading...",
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _dateTimeInfo() {
    DateTime now = _weather!.date!;
    return Column(
      children: [
        Text(
          DateFormat("h:mm a").format(now),
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat("EEEE").format(now),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              ", ${DateFormat("d.M.y").format(now)}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _weatherIcon() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Lottie.asset(
          _getLottieAnimation(_weather?.weatherDescription),
          height: MediaQuery.sizeOf(context).height * 0.3,
        ),
        Text(
          _weather?.weatherDescription ?? "Loading...",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getLottieAnimation(String? weatherDescription) {
    if (weatherDescription == null) {
      return 'assets/animations/default.json';
    }
    if (weatherDescription.contains('rain')) {
      return 'assets/animations/Rain.json';
    } else if (weatherDescription.contains('cloud')) {
      return 'assets/animations/clouds.json';
    } else if (weatherDescription.contains('sun')) {
      return 'assets/animations/sun.json';
    } else if (weatherDescription.contains('snow')) {
      return 'assets/animations/Snow.json';
    } else if (weatherDescription.contains('storm')) {
      return 'assets/animations/storm.json';
    } else if (weatherDescription.contains('fog')) {
      return 'assets/animations/fog.json';
    } else {
      return 'assets/animations/default.json';
    }
  }

  Widget _currentTemp() {
    return Text(
      "${_weather?.temperature?.celsius?.toStringAsFixed(0)}°C",
      style: const TextStyle(
        color: Colors.black,
        fontSize: 70,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _extraInfo() {
    return Text(
      "Wind: ${_weather?.windSpeed?.toStringAsFixed(0)} m/s",
      style: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _feelsLike() {
    return Text(
      "Feels like: ${_weather?.tempFeelsLike?.celsius?.toStringAsFixed(0)}°C",
      style: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _maxMinTemp() {
    return Text(
      "Max: ${_weather?.tempMax?.celsius?.toStringAsFixed(0)}°C, Min: ${_weather?.tempMin?.celsius?.toStringAsFixed(0)}°C",
      style: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
