import 'dart:math' as math;
import '../models/point_3d.dart';

class ShapeFactory {

  static List<Point3D> generateMorphingShape(int n, double radius) {
    List<Point3D> points = [];

    for (int i = 0; i < n; i++) {
      double theta = (i * 2 * math.pi) / n;

      points.add(
        Point3D(
          radius * math.cos(theta),
          radius * math.sin(theta),
          (i % 2 == 0) ? radius * 0.5 : -radius * 0.5,
        ),
      );
    }

    return points;
  }
}