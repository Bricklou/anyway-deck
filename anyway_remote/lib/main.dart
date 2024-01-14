import 'package:anyway_remote/models_provider/webrtc_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=> WebRtcProvider()),
      ],
      child: const AnywayApp(),
    )
  );
}
