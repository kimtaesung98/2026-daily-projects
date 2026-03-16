import 'package:flutter/material.dart';
import '../../../model/weather_model.dart';
import '../data/weather_api.dart';

enum WeatherStatus { initial, loading, loaded, error }

class WeatherProvider extends ChangeNotifier {
  final WeatherApi _api = WeatherApi();

  WeatherStatus _status = WeatherStatus.initial;
  WeatherModel? _weather;
  String _errorMessage = '';

  WeatherStatus get status => _status;
  WeatherModel? get weather => _weather;
  String get errorMessage => _errorMessage;

  Future<void> loadWeather() async {
    _status = WeatherStatus.loading;
    notifyListeners();

    try {
      _weather = await _api.fetchWeather();
      _status = WeatherStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = WeatherStatus.error;
    }

    notifyListeners();
  }
}