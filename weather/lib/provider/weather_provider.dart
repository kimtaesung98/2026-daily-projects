import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/weather_model.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherModel? _weather;
  bool _isLoading = false;

  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;

  // 단순 수치 외 '예측' 및 '분석' 데이터 생성
  String get temperatureTrend {
    if (_weather == null || _weather!.hourly.length < 2) return "분석 불가";
    double diff = _weather!.hourly[1].temp - _weather!.hourly[0].temp;
    return diff > 0 ? "${diff.toStringAsFixed(1)}°C 상승 중" : "${diff.abs().toStringAsFixed(1)}°C 하강 중";
  }

  Future<void> fetchWeatherData() async {
    _isLoading = true;
    notifyListeners();

    // [Data Source 시뮬레이션] 실제로는 API 호출이 일어나는 지점
    await Future.delayed(const Duration(seconds: 1));
    
    _weather = WeatherModel(
      city: "SEOUL",
      current: CurrentWeather(temp: 24.5, humidity: 60, condition: "Sunny", windSpeed: 3.2),
      hourly: List.generate(24, (i) => HourlyData(
        time: DateTime.now().add(Duration(hours: i)),
        temp: 20.0 + (i % 5),
        precipitation: 10.0 + i,
      )),
      daily: List.generate(7, (i) => DailyData(
        date: DateTime.now().add(Duration(days: i)),
        maxTemp: 28.0,
        minTemp: 18.0,
        condition: "Clear",
      )),
    );

    _isLoading = false;
    notifyListeners();
  }
}