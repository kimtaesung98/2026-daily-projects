lib/
├── main.dart                          # 앱의 진입점, DI 설정 및 UI 실행
├── dependency_injection/
│   └── locator.dart                   # 서비스 부품(MQTT, DB, 센서) 조립소
├── core/
│   ├── constants/app_constants.dart   # 버퍼 크기, 서버 주소 등 설정값
│   ├── types/network_status.dart      # Online/Offline/Connecting 상태 정의
│   └── exceptions/                    # 버퍼 오버플로우 등 예외 정의
├── domain/
│   ├── entities/sensor_packet.dart    # 불변(Immutable) 센서 데이터 모델
│   ├── interfaces/                    # 추상화 계약 (DIP의 핵심)
│   │   ├── i_sensor_service.dart
│   │   ├── i_buffer_manager.dart
│   │   ├── i_connection_monitor.dart
│   │   └── i_edge_client.dart
│   └── usecases/                      # 브릿지 시작/종료 등 핵심 비즈니스 액션
├── sensors/
│   ├── sensor_stream.dart             # 로우 센서 데이터(sensors_plus) 래퍼
│   └── device_sensor_service.dart     # 센서 데이터를 패킷으로 가공
├── buffer/
│   ├── sqlite_storage_adapter.dart    # Level 2: SQLite DB 실제 연동
│   └── persistent_buffer_manager.dart # Level 1(RAM) + Level 2(DB) 통합 관리
├── network/
│   ├── connection_monitor.dart        # Wi-Fi/LTE 상태 감시
│   ├── mqtt_edge_client.dart          # 실제 MQTT 프로토콜 통신
│   └── sync_service.dart              # 데이터 전송 및 재시도 전략(Orchestrator)
└── presentation/
    ├── state/dashboard_controller.dart# UI 상태 관리 (Logic 없음)
    ├── screens/dashboard_screen.dart  # 메인 화면
    └── widgets/                       # 차트, 상태 인디케이터 등 재사용 위젯

[Sensor -> Edge 데이터 여정]
1) 발생 (Sensor Layer)
- 스마트폰 가속도/자이로 센서 이벤트를 `SensorStreamWrapper`가 캡슐화하여 제공합니다.

2) 가공 (Domain Entity)
- `DeviceSensorService`가 센서 값을 수집해 타임스탬프, 기기 ID, 시퀀스 번호를 포함한 `SensorPacket`으로 생성합니다.

3) 1차 보관 (Memory Buffer)
- `PersistentBufferManager`의 메모리 캐시(RAM)에 우선 저장되어 즉시 UI 상태에 반영됩니다.

4) 2차 보관 (SQLite Persistence)
- 메모리 버퍼가 임계치(100개)에 도달하거나 flush 시점이 오면 `SqliteStorageAdapter`를 통해 SQLite DB에 영속화됩니다.
- 네트워크 단절 중에도 데이터는 DB에 안전하게 보관되어 대기합니다.

5) 감시 (Network Monitor)
- `ConnectionMonitor`가 연결 상태를 스트리밍하고, `MqttEdgeClient`는 브로커(Edge) 연결/재연결을 처리합니다.

6) 동기화 (Sync Service)
- `SyncService`가 Online 상태를 감지하면 버퍼(RAM+DB flush 결과)에서 패킷을 가져와 `MqttEdgeClient`로 전달합니다.

7) 최종 전송 (Edge Transmission)
- MQTT로 JSON 배치를 publish 하며, 실패 시 지수 백오프 기반 재시도 후 재전송합니다.