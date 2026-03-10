class MachineModel {
  final String id;
  final String name;
  final double temperature;
  final double pressure;
  final String status;
  final DateTime lastUpdate;
  final List<double> tempHistory;

  MachineModel({
    required this.id,
    required this.name,
    required this.temperature,
    required this.pressure,
    required this.status,
    required this.lastUpdate,
    required this.tempHistory,
  });

  double get efficiency =>
      ((temperature * 0.6 + pressure * 0.4) / 150 * 100).clamp(0, 100);

  MachineModel copyWith({double? newTemp, double? newPressure}) {

    List<double> updatedHistory = List.from(tempHistory);

    if (newTemp != null) {
      updatedHistory.add(newTemp);

      if (updatedHistory.length > 20) {
        updatedHistory.removeAt(0);
      }
    }

    return MachineModel(
      id: id,
      name: name,
      temperature: newTemp ?? temperature,
      pressure: newPressure ?? pressure,
      status: (newTemp ?? temperature) > 90 ? "WARNING" : "RUNNING",
      lastUpdate: DateTime.now(),
      tempHistory: updatedHistory,
    );
  }

  factory MachineModel.fromJson(Map<String, dynamic> json) {

    return MachineModel(
      id: json['id'],
      name: json['name'],
      temperature: (json['temp'] as num).toDouble(),
      pressure: (json['press'] as num).toDouble(),
      status: json['status'],
      lastUpdate: DateTime.now(),
      tempHistory: [],
    );

  }
}