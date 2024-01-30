import 'package:anyway_remote/models/client_packets.dart';
import 'package:anyway_remote/models_provider/tcp_client_provider.dart';
import 'package:anyway_remote/utils/data_transformation_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

import '../models_provider/webrtc_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.connection});

  final RemoteClient connection;

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TcpClientProvider? tcpClientProvider;
  WebRtcProvider? webRtcProvider;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    tcpClientProvider = context.read<TcpClientProvider>();
    webRtcProvider = context.read<WebRtcProvider>();

    try {
      await tcpClientProvider!.init();
      await tcpClientProvider!.connect(widget.connection);
      print('connected to ${widget.connection.ip}:${widget.connection.port}');
      tcpClientProvider!.send(InitConnectionPacket());
      print('sent init packet');

      webRtcProvider!.onIceCandidate = (candidate) {
        tcpClientProvider!.send(IceCandidatePacket.fromCandidate(candidate));
      };

      tcpClientProvider!
          .listen(transformData(webRtcProvider!, tcpClientProvider!));
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    tcpClientProvider?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      final tcpClientProvider = context.watch<TcpClientProvider>();
      final webRtcProvider = context.watch<WebRtcProvider>();

      // While the app isn't connected to the server, show a waiting screen.
      if (!tcpClientProvider.isConnected && !webRtcProvider.isConnected) {
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

      print('connected to ${widget.connection.ip}:${widget.connection.port}');

      return Scaffold(
        body: Stack(children: [
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
                  child: const Icon(Icons.arrow_back, color: Colors.black54))),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: RTCVideoView(
                webRtcProvider.remoteVideoRenderer,
                mirror: true,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
          ),
        ]),
      );
    });
  }
}
