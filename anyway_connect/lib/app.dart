import 'package:anyway_connect/pages/main_page.dart';
import 'package:flutter/material.dart';

class AnywayConnect extends StatelessWidget {
  const AnywayConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anyway Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange, brightness: Brightness.light),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}