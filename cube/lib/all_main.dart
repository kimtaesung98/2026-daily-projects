import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' hide Colors;

void main() => runApp(const MaterialApp(home: MorphingShape()));

class MorphingShape extends StatefulWidget {
  const MorphingShape({super.key});

  @override
  State<MorphingShape> createState() => _MorphingShapeState();
}

class _MorphingShapeState extends State<MorphingShape> {
  double rx = 0.5;
  double ry = 0.5;
  double subdivisions = 3.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  ry += details.delta.dx * 0.01;
                  rx -= details.delta.dy * 0.01;
                });
              },
              child: Center(
                child: CustomPaint(
                  size: const Size(400, 400),
                  painter: ShapePainter(subdivisions.toInt(), rx, ry),
                ),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.grey[900],
            child: Row(
              children: [
                const Icon(Icons.architecture, color: Colors.white),
                Expanded(
                  child: Slider(
                    value: subdivisions,
                    min: 3.0,
                    max: 50.0,
                    divisions: 47,
                    onChanged: (value) {
                      setState(() {
                        subdivisions = value;
                      });
                    },
                    activeColor: Colors.blueAccent,
                  ),
                ),
                Text(
                  "${subdivisions.toInt()} 각",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final int n;
  final double rx;
  final double ry;
  final double radius = 150.0;

  ShapePainter(this.n, this.rx, this.ry);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);

    final Matrix4 matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(rx)
      ..rotateY(ry);

    final List<Offset> points = [];

    for (int i = 0; i <= n; i++) {
      final angle = (i * 2 * math.pi) / n;

      final p = _project(
        radius * math.cos(angle),
        radius * math.sin(angle),
        0,
        matrix,
        center,
      );

      if (i > 0) {
        canvas.drawLine(points.last, p, paint);
      }

      points.add(p);
    }

    if (points.length > 2) {
      canvas.drawLine(points.last, points.first, paint);
    }
  }

  Offset _project(
    double x,
    double y,
    double z,
    Matrix4 matrix,
    Offset center,
  ) {
    final Vector4 v = Vector4(x, y, z, 1.0);
    final transformed = matrix.transform(v);

    return Offset(
      transformed.x + center.dx,
      transformed.y + center.dy,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}