import 'package:flutter/material.dart';
import '../../provider/weather_provider.dart';
import 'package:provider/provider.dart';


class WeatherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final weather = provider.weather;

    if (provider.isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));
    if (weather == null) return Scaffold(body: Center(child: Text("데이터를 불러오세요")));

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(weather),
          // n행 2열 구조 (기능이 추가될 때마다 아래로 확장)
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverGrid.count(
              crossAxisCount: 2, // 2열 구조
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.5, // 가로로 긴 직사각형 (허쉬 바 형태)
              children: [
                _buildDataBlock("현재 온도", "${weather.current.temp}°C", Colors.cyan),
                _buildDataBlock("습도", "${weather.current.humidity}%", Colors.blue),
                _buildDataBlock("풍속", "${weather.current.windSpeed}m/s", Colors.green),
                _buildDataBlock("기온 추세", provider.temperatureTrend, Colors.orange),
                // 여기에 새로운 기능을 추가하면 자동으로 아래 2열에 배치됨
                _buildDataBlock("강수 확률", "${weather.hourly[0].precipitation}%", Colors.indigo),
                _buildDataBlock("기상 상태", weather.current.condition, Colors.amber),
              ],
            ),
          ),
          // 시계열 그래프 영역 (필요시 전폭 사용)
          SliverToBoxAdapter(
            child: _buildTimeSeriesGraph(weather.hourly),
          ),
          // 요일별 예측 리스트 (아래로 무한 확장 가능)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildDailyRow(weather.daily[index]),
              childCount: weather.daily.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataBlock(String label, String value, Color color) {
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}