import 'package:flutter/material.dart';
import 'core/policy/transmission_policy.dart';
import 'core/services/background_service_manager.dart';
import 'dependency_injection/locator.dart';
import 'presentation/screens/admin_gate_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Dependency Injection
  setupLocator();
  await locator<TransmissionPolicy>().load();

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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        cardColor: const Color(0xFF161B22),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161B22),
          foregroundColor: Color(0xFFC9D1D9),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'monospace'),
        ),
        useMaterial3: true,
      ),
      home: const AdminGateScreen(),
    );
  }
}