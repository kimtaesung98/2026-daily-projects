enum NetworkStatus {
  offline,        // 네트워크 연결 없음 (Wi-Fi/LTE 꺼짐)
  searching,      // 네트워크는 있으나 Edge 장치를 찾는 중
  connecting,     // Edge 장치(MQTT 브로커)와 핸드셰이크 중
  online,         // Edge 장치와 완전히 연결되어 전송 가능
  reconnecting,   // 연결이 끊겨 재시도 중
  error           // 인증 실패 또는 호스트 찾을 수 없음
}