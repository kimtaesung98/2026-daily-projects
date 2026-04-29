lib/
├── main.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── types/
│   │   └── network_status.dart
│   └── exceptions/
│       └── buffer_overflow_exception.dart
├── domain/
│   ├── entities/
│   │   └── sensor_packet.dart
│   └── interfaces/
│       ├── i_sensor_service.dart
│       ├── i_buffer_manager.dart
│       ├── i_connection_monitor.dart
│       └── i_edge_client.dart
├── sensors/
│   └── device_sensor_service.dart
├── buffer/
│   ├── memory_data_buffer.dart
│   └── buffer_manager.dart
├── network/
│   ├── connection_monitor.dart
│   ├── mock_edge_client.dart
│   └── sync_service.dart
├── presentation/
│   ├── state/
│   │   └── dashboard_controller.dart
│   ├── screens/
│   │   └── dashboard_screen.dart
│   └── widgets/
│       └── status_indicator.dart
└── dependency_injection/
    └── locator.dart