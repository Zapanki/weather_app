import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/CitySelectionDialog.dart';
import 'package:weather_app/consts.dart';
import 'package:weather_app/hourly_method.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  final WeatherService _weatherService = WeatherService(apiKey: OPENWEATHER_API_KEY);
  Weather? _weather;
  List<dynamic>? _hourlyForecast;

  @override
  void initState() {
    super.initState();
    _fetchWeather("Thessaloniki");
  }

  Future<void> _fetchWeather(String cityName) async {
    try {
      Weather weather = await _wf.currentWeatherByCityName(cityName);
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final hourlyForecast = await _weatherService.getHourlyForecast(weather.latitude!, weather.longitude!);
      setState(() {
        _weather = weather;
        _hourlyForecast = hourlyForecast['list'];
      });
    } catch (e) {
      print('Failed to fetch weather: $e');
      _showErrorDialog('Failed to fetch weather. Please check your API key and try again.');
    }
  }

  Future<void> _fetchWeatherByLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final weather = await _wf.currentWeatherByLocation(position.latitude, position.longitude);
      final hourlyForecast = await _weatherService.getHourlyForecast(position.latitude, position.longitude);
      setState(() {
        _weather = weather;
        _hourlyForecast = hourlyForecast['list'];
      });
    } catch (e) {
      print('Failed to fetch weather by location: $e');
      _showErrorDialog('Failed to fetch weather by location. Please check your API key and try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectCity() async {
    final selectedCity = await showDialog<String>(
      context: context,
      builder: (context) => CitySelectionDialog(
        cities: ["My Location", "Thessaloniki", "New York", "London", "Tokyo", "Sydney"],
        onSelectedCity: (city) {
          if (city == "My Location") {
            _fetchWeatherByLocation();
          } else {
            _fetchWeather(city);
          }
        },
      ),
    );

    if (selectedCity == "My Location") {
      await _fetchWeatherByLocation();
    } else if (selectedCity != null) {
      await _fetchWeather(selectedCity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _searchCityField(),
        actions: [
          IconButton(
            icon: Icon(Icons.location_city),
            onPressed: _selectCity,
          ),
        ],
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_weather != null) ...[
            _currentWeatherSection(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            _hourlyForecastSection(),
          ] else
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _searchCityField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onSubmitted: (value) => _fetchWeather(value),
        decoration: InputDecoration(
          hintText: "Search city",
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _currentWeatherSection() {
    return Column(
      children: [
        Text(
          _weather?.areaName ?? "Loading...",
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 20),
        Text(
          DateFormat("h:mm a").format(_weather!.date!),
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
              DateFormat("EEEE").format(_weather!.date!),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              ", ${DateFormat("d.M.y").format(_weather!.date!)}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
        SizedBox(height: 20),
        Lottie.asset(
          _getLottieAnimation(_weather?.weatherDescription),
          height: MediaQuery.of(context).size.height * 0.2,
        ),
        Text(
          _weather?.weatherDescription ?? "Loading...",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "${_weather?.temperature?.celsius?.toStringAsFixed(0)}°C",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 70,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "Feels like: ${_weather?.tempFeelsLike?.celsius?.toStringAsFixed(0)}°C",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "Wind: ${_weather?.windSpeed?.toStringAsFixed(0)} m/s",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "Max: ${_weather?.tempMax?.celsius?.toStringAsFixed(0)}°C, Min: ${_weather?.tempMin?.celsius?.toStringAsFixed(0)}°C",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _hourlyForecastSection() {
    if (_hourlyForecast == null) {
      return Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hourly Forecast",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _hourlyForecast!.length,
            itemBuilder: (context, index) {
              final forecast = _hourlyForecast![index];
              return Container(
                width: 80,
                child: Column(
                  children: [
                    Text(DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000))),
                    SizedBox(height: 5),
                    Lottie.asset(
                      _getLottieAnimation(forecast['weather'][0]['description']),
                      width: 50,
                      height: 50,
                    ),
                    SizedBox(height: 5),
                    Text("${forecast['main']['temp'].toStringAsFixed(0)}°C"),
                  ],
                ),
              );
            },
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
      return 'assets/animations/rain.json';
    } else if (weatherDescription.contains('cloud')) {
      return 'assets/animations/clouds.json';
    } else if (weatherDescription.contains('sun')) {
      return 'assets/animations/sun.json';
    } else if (weatherDescription.contains('snow')) {
      return 'assets/animations/snow.json';
    } else if (weatherDescription.contains('storm')) {
      return 'assets/animations/storm.json';
    } else if (weatherDescription.contains('fog')) {
      return 'assets/animations/fog.json';
    } else {
      return 'assets/animations/default.json';
    }
  }
}
