import 'package:flutter/material.dart';

import '../logic/shape_factory.dart';
import '../renderer/universal_3d_painter.dart';

class MorphingShapeScreen extends StatefulWidget {
  const MorphingShapeScreen({super.key});

  @override
  State<MorphingShapeScreen> createState() => _MorphingShapeScreenState();
}

class _MorphingShapeScreenState extends State<MorphingShapeScreen> {

  double rx = 0.5;
  double ry = 0.5;
  double subdivisions = 6;

  @override
  Widget build(BuildContext context) {

    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(rx)
      ..rotateY(ry);

    final points =
        ShapeFactory.generateMorphingShape(subdivisions.toInt(), 150);

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
                  painter: Universal3DPainter(
                    points: points,
                    matrix: matrix,
                  ),
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
                    min: 3,
                    max: 50,
                    divisions: 47,
                    onChanged: (value) {
                      setState(() {
                        subdivisions = value;
                      });
                    },
                  ),
                ),

                Text(
                  "${subdivisions.toInt()} 각",
                  style: const TextStyle(color: Colors.white),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}