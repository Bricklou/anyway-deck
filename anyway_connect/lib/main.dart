import 'package:anyway_connect/app.dart';
import 'package:anyway_connect/models_provider/bluetooth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),
      ],
      child: const AnywayConnect(),
    )
  );
}
