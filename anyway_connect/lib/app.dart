import 'package:anyway_connect/pages/main_page.dart';
import 'package:flutter/material.dart';

class AnywayConnect extends StatelessWidget {
  const AnywayConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anyway Connect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const MainPage(),
    );
  }
}