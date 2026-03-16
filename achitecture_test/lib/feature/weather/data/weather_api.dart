import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../model/weather_model.dart';

class WeatherApi {
  // ── Replace with your OpenWeatherMap API key ──
  static const String _apiKey = 'c4d8dc7f9026dcfbd436757d8907430b';
  static const String _baseUrl = 'https://api.openweathermap.org/data/3.0/onecall';

  // Default: Seoul
  static const double _defaultLat = 37.5665;
  static const double _defaultLon = 126.9780;

  Future<WeatherModel> fetchWeather({
    double lat = _defaultLat,
    double lon = _defaultLon,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl?lat=$lat&lon=$lon'
      '&exclude=minutely,daily,alerts'
      '&units=metric'
      '&appid=$_apiKey',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      // Inject city name via reverse-geocoding or use timezone
      return WeatherModel.fromJson(json);
    } else {
      throw Exception('Failed to fetch weather: ${response.statusCode}');
    }
  }
}