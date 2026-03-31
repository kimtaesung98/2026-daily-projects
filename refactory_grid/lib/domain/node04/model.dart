class ComplexNodeModel {
  // 3개가 아니라 원하는 만큼 무한히 정의합니다.
  String serverName = 'Main Cluster';
  List<String> activeLogs = ['Booting...', 'Connecting DB...', 'Ready'];
  Map<String, double> cpuTemperatures = {'Core1': 45.2, 'Core2': 48.1};
  bool isFirewallActive = true;
  int upTimeHours = 120;
  // ... 더 많은 데이터 ...
}