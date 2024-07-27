import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey;

  WeatherService({required this.apiKey});

  Future<Map<String, dynamic>> getHourlyForecast(double lat, double lon) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load hourly forecast');
    }
  }

  Future<Map<String, dynamic>> getWeeklyForecast(double lat, double lon) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weekly forecast');
    }
  }
}
