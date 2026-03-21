import 'package:flutter/material.dart';
import '../models/point_3d.dart';

class Universal3DPainter extends CustomPainter {

  final List<Point3D> points;
  final Matrix4 matrix;

  Universal3DPainter({
    required this.points,
    required this.matrix,
  });

  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    final projectedPoints =
        points.map((p) => p.project(matrix, center)).toList();

    for (int i = 0; i < projectedPoints.length - 1; i++) {
      canvas.drawLine(
        projectedPoints[i],
        projectedPoints[i + 1],
        paint,
      );
    }

    if (projectedPoints.isNotEmpty) {
      canvas.drawLine(
        projectedPoints.last,
        projectedPoints.first,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}