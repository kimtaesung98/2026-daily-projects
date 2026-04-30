import 'package:flutter/material.dart';
import 'core/services/background_service_manager.dart';
import 'dependency_injection/locator.dart';
import 'presentation/screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Dependency Injection
  setupLocator();

  // 2. Initialize foreground background-service engine
  await BackgroundServiceManager.initializeService();
  
  // 3. Start Application
  runApp(const EdgeBridgeApp());
}

class EdgeBridgeApp extends StatelessWidget {
  const EdgeBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensor Data Bridge',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}