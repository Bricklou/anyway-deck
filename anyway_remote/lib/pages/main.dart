import 'package:anyway_remote/models_provider/tcp_client_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.connection});

  final RemoteClient connection;

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();

    final tcpClientProvider = context.read<TcpClientProvider>();

    tcpClientProvider
        .init()
        .then((_) => tcpClientProvider.connect(widget.connection))
        .catchError((e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      final tcpClientProvider = context.watch<TcpClientProvider>();

      // While the app isn't connected to the server, show a waiting screen.
      if (!tcpClientProvider.isConnected) {
        return Scaffold(
            body: Stack(
          children: [
            Positioned(
                top: 10,
                left: 0,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(0),
                      shadowColor: Colors.transparent,
                    ),
                    child:
                        const Icon(Icons.arrow_back, color: Colors.black54))),
            const Positioned.fill(
                child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Waiting for connection'),
                ],
              ),
            ))
          ],
        ));
      }

      return const Scaffold(
        body: Center(
          child: Text('Main Page'),
        ),
      );
    });
  }
}
