import 'package:get_it/get_it.dart';

import '../domain/interfaces/i_sensor_service.dart';
// import '../domain/interfaces/i_buffer_manager.dart';
import '../domain/interfaces/i_connection_monitor.dart';
import '../domain/interfaces/i_edge_client.dart';

import '../sensors/device_sensor_service.dart';
import '../buffer/buffer_manager.dart';
// Implementations for NetworkMonitor and EdgeClient would be created similarly
import '../network/mock_connection_monitor.dart';
import '../network/mock_edge_client.dart';
import '../network/sync_service.dart';
import '../presentation/state/dashboard_controller.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Core Services
  locator.registerLazySingleton<ISensorService>(() => DeviceSensorService());
  locator.registerLazySingleton<IBufferManager>(() => BufferManager());
  locator.registerLazySingleton<IConnectionMonitor>(() => MockConnectionMonitor());
  locator.registerLazySingleton<IEdgeClient>(() => MockEdgeClient());

  // Orchestrator
  locator.registerLazySingleton<SyncService>(() => SyncService(
    locator<ISensorService>(),
    locator<IBufferManager>(),
    locator<IConnectionMonitor>(),
    locator<IEdgeClient>(),
  ));

  // UI State Controller
  locator.registerFactory<DashboardController>(() => DashboardController(
    sensorService: locator<ISensorService>(),
    bufferManager: locator<IBufferManager>(),
    connectionMonitor: locator<IConnectionMonitor>(),
    syncService: locator<SyncService>(),
  ));
}