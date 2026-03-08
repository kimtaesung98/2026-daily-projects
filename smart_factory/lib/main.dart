import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'factory_provider.dart';
import 'dashboard_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FactoryProvider()..startMonitoring(),
      child: const FactoryApp(),
    ),
  );
}

class FactoryApp extends StatelessWidget {
  const FactoryApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const DashboardScreen(),
    );
  }
}