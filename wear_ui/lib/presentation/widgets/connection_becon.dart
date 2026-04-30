import 'package:flutter/material.dart';
import '../../core/types/network_status.dart';

class ConnectionBeacon extends StatelessWidget {
  final NetworkStatus status;

  const ConnectionBeacon({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(  
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPulseDot(_getStatusColor(status)),
          const SizedBox(width: 8),
          Text(
            status.name.toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(status),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseDot(Color color) {
    // 실제로는 애니메이션을 넣으면 좋으나 우선 단순 원으로 구현
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Color _getStatusColor(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.online: return Colors.green;
      case NetworkStatus.offline: return Colors.red;
      case NetworkStatus.reconnecting: return Colors.orange;
      case NetworkStatus.searching:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NetworkStatus.connecting:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NetworkStatus.error:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}