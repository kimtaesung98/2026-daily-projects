import 'package:flutter/material.dart';

class TrendPainter extends CustomPainter {
  final List<double> history;

  TrendPainter(this.history);

  @override
  void paint(Canvas canvas, Size size) {
    if (history.length < 2) return;

    final paint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    double dx = size.width / (history.length - 1);

    for (int i = 0; i < history.length; i++) {

      double x = i * dx;

      double y = size.height - ((history[i] - 50) / 50 * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}