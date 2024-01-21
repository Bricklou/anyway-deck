import 'package:anyway_remote/models_provider/tcp_client_provider.dart';
import 'package:anyway_remote/models_provider/webrtc_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => WebRtcProvider()),
      ChangeNotifierProvider(create: (_) => TcpClientProvider())
    ],
    child: const AnywayApp(),
  ));
}
