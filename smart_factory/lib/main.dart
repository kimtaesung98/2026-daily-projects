import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './provider/factory_provider.dart';
import 'data/datasources/machine_remote_datasource.dart';
import 'data/repositories/machine_repository.dart';
import 'screens/dashboard_screen.dart';

void main() {

  final dataSource = MachineRemoteDataSource();
  final repository = MachineRepository(dataSource);

  runApp(
    ChangeNotifierProvider(
      create: (_) => FactoryProvider(),
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