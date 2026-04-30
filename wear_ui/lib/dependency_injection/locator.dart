import 'package:get_it/get_it.dart';
import '../domain/interfaces/i_sensor_service.dart';
import '../domain/interfaces/i_buffer_manager.dart';
import '../domain/interfaces/i_connection_monitor.dart';
import '../domain/interfaces/i_edge_client.dart';

import '../sensors/device_sensor_service.dart';
// Implementations for NetworkMonitor and EdgeClient would be created similarly
import '../network/connection_monitor.dart';
import '../network/sync_service.dart';
import '../presentation/state/dashboard_controller.dart';
import '../network/mqtt_edge_client.dart';
import '../buffer/storage_adapter.dart';
import '../buffer/sqlite_storage_adapter.dart';
import '../buffer/persistent_buffer_manager.dart';
import '../network/wear_connectivity_service.dart';
import '../core/policy/transmission_policy.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<TransmissionPolicy>(() => TransmissionPolicy());

  // Core Services
  locator.registerLazySingleton<ISensorService>(() => DeviceSensorService());
  locator.registerLazySingleton<WearConnectivityService>(
    () => WearConnectivityService(),
  );
  locator.registerLazySingleton<IConnectionMonitor>(
    () => ConnectionMonitor(
      wearConnectivityService: locator<WearConnectivityService>(),
      userId: locator<TransmissionPolicy>().state.adminUserId,
    ),
  );
  locator.registerLazySingleton<IEdgeClient>(() => MqttEdgeClient());

  // Orchestrator
  locator.registerLazySingleton<SyncService>(() => SyncService(
    locator<ISensorService>(),
    locator<IBufferManager>(),
    locator<IConnectionMonitor>(),
    locator<IEdgeClient>(),
    locator<TransmissionPolicy>(),
  ));

  // UI State Controller
  locator.registerLazySingleton<DashboardController>(() => DashboardController(
    sensorService: locator<ISensorService>(),
    bufferManager: locator<IBufferManager>(),
    connectionMonitor: locator<IConnectionMonitor>(),
    syncService: locator<SyncService>(),
    transmissionPolicy: locator<TransmissionPolicy>(),
  ));

  locator.registerLazySingleton<IStorageAdapter>(() => SqliteStorageAdapter());

  // Persistent buffer with SQLite-backed storage
  locator.registerLazySingleton<IBufferManager>(
    () => PersistentBufferManager(locator<IStorageAdapter>())
  );
}