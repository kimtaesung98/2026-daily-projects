import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/grid_provider.dart';
import 'screen/grid_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GridProvider(),
      child: const MaterialApp(
        home: GridScreen(),
      ),
    ),
  );
}