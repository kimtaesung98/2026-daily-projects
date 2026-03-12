class WeatherModel {
  final String city;
  final CurrentWeather current;
  final List<HourlyData> hourly; // 시계열 데이터 (그래프용)
  final List<DailyData> daily;   // 요일별 데이터 (예측용)

  WeatherModel({
    required this.city,
    required this.current,
    required this.hourly,
    required this.daily,
  });
}

class CurrentWeather {
  final double temp;
  final double humidity;
  final String condition;
  final double windSpeed;

  CurrentWeather({required this.temp, required this.humidity, required this.condition, required this.windSpeed});
}

class HourlyData {
  final DateTime time;
  final double temp;
  final double precipitation; // 강수 확률

  HourlyData({required this.time, required this.temp, required this.precipitation});
}

class DailyData {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String condition;

  DailyData({required this.date, required this.maxTemp, required this.minTemp, required this.condition});
}