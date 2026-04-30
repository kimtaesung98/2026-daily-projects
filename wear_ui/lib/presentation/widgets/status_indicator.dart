import 'package:flutter/material.dart';
import '../../core/types/network_status.dart';

class StatusIndicator extends StatelessWidget {
  final NetworkStatus networkStatus;
  final int bufferSize;
  final bool isStreaming;

  const StatusIndicator({
    super.key,
    required this.networkStatus,
    required this.bufferSize,
    required this.isStreaming,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildRow(
              'Network:', 
              networkStatus.name.toUpperCase(), 
              _getNetworkColor(networkStatus)
            ),
            const Divider(),
            _buildRow(
              'Buffer Size:', 
              '$bufferSize packets', 
              bufferSize > 4000 ? Colors.red : Colors.black87
            ),
            const Divider(),
            _buildRow(
              'Bridge Status:', 
              isStreaming ? 'ACTIVE' : 'IDLE', 
              isStreaming ? Colors.blue : Colors.grey
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }

  Color _getNetworkColor(NetworkStatus status) {
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