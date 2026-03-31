import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/gridprovider.dart';
import 'provider/gridscreen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GridProvider(),
      child: const DashboardApp(),
    ),
  );
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Static Node Dashboard',
      // Enforced design constraint: dark theme only
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
        ),
      ),
      home: const GridScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}