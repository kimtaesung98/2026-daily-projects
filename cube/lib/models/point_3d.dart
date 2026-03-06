import 'dart:ui';
import 'package:vector_math/vector_math_64.dart';

class Point3D {
  final double x, y, z;

  Point3D(this.x, this.y, this.z);

  Offset project(Matrix4 matrix, Offset center) {
    final Vector4 v = Vector4(x, y, z, 1.0);
    final Vector4 transformed = matrix.transform(v);

    final double w = transformed.w != 0 ? transformed.w : 1.0;

    return Offset(
      (transformed.x / w) + center.dx,
      (transformed.y / w) + center.dy,
    );
  }
}