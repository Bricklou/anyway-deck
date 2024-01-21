import 'package:anyway_connect/app.dart';
import 'package:anyway_connect/models_provider/bluetooth_provider.dart';
import 'package:anyway_connect/models_provider/tcp_server_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models_provider/webrtc_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),
        ChangeNotifierProvider(create: (_) => TcpServerProvider()),
        ChangeNotifierProvider(create: (_)=> WebRtcProvider()),
      ],
      child: const AnywayConnect(),
    )
  );
}
