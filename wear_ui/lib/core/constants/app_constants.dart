class AppConstants {
  // Buffer Constants
  static const int maxMemoryBufferLimit = 5000;
  static const int defaultFlushThreshold = 50;
  
  // Network Constants
  static const int networkCheckIntervalSeconds = 10;
  static const int defaultEdgeTimeoutMs = 5000;

  // Device Identifiers (추후 Wear OS에서 실제 ID 추출 로직으로 대체)
  static const String mockDeviceId = "EDGE_PHONE_01";
}