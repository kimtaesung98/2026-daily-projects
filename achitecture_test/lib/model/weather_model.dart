class WeatherModel {
  final String cityName;
  final double temperature;
  final int humidity;
  final String condition;
  final String iconCode;
  final List<HourlyTemp> hourlyData;

  const WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.humidity,
    required this.condition,
    required this.iconCode,
    required this.hourlyData,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    // Parse current weather
    final current = json['current'];
    final hourlyList = (json['hourly'] as List).take(8).toList();

    return WeatherModel(
      cityName: json['timezone'] ?? 'Unknown',
      temperature: (current['temp'] as num).toDouble(),
      humidity: current['humidity'] as int,
      condition: current['weather'][0]['description'] as String,
      iconCode: current['weather'][0]['icon'] as String,
      hourlyData: hourlyList.map((h) {
        final dt = DateTime.fromMillisecondsSinceEpoch(
          (h['dt'] as int) * 1000,
        );
        return HourlyTemp(
          hour: dt.hour,
          temp: (h['temp'] as num).toDouble(),
        );
      }).toList(),
    );
  }
}

class HourlyTemp {
  final int hour;
  final double temp;
  const HourlyTemp({required this.hour, required this.temp});
}