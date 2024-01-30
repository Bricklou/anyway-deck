import 'package:anyway_connect/models/TcpPacket.dart';
import 'package:anyway_connect/models_provider/tcp_server_provider.dart';
import 'package:anyway_connect/models_provider/webrtc_provider.dart';
import 'package:anyway_connect/utils/data_transformation_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

class WebRtcCard extends StatefulWidget {
  const WebRtcCard({super.key});

  @override
  State<StatefulWidget> createState() => _WebRtcCard();
}

class _WebRtcCard extends State<WebRtcCard> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            constraints: const BoxConstraints(minHeight: 180),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ]),
            child: Stack(
              children: [
                // Card title
                const Positioned(
                    top: 15,
                    left: 15,
                    child: Text('WebRTC',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54))),

                // WebRTC settings button
                /* Positioned(
                    top: 3,
                    right: -5,
                    child: ElevatedButton(
                        onPressed: () async {},
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(0),
                          shadowColor: Colors.transparent,
                        ),
                        child: Icon(Icons.settings,
                            color: Theme.of(context).colorScheme.secondary))),*/
                // Card content
                Container(
                    padding: const EdgeInsets.all(10).copyWith(
                      top: 55,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Consumer2<WebRtcProvider, TcpServerProvider>(
                          builder:
                              (context, webrtcProvider, tcpServerProvider, _) =>
                                  renderWebRtcButton(
                                      webrtcProvider, tcpServerProvider)),
                    ))
              ],
            )));
  }

  Widget renderWebRtcButton(
      WebRtcProvider webRtcProvider, TcpServerProvider tcpServerProvider) {
    // If the TCP server is not enabled, then show a button to enable it
    if (!tcpServerProvider.isRunning) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          // WebRTC icon
          Center(
              child: Icon(Icons.desktop_windows_outlined,
                  size: 50,
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withOpacity(0.8))),

          // Enable WebRTC button
          ElevatedButton(
              onPressed: () async {
                await _enableServer(webRtcProvider, tcpServerProvider);
              },
              child: const Text('Enable WebRTC')),
        ],
      );
    }

    const textStyle = TextStyle(
        fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black54);

    // Otherwise, show a button to disable everything and the server address
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          'Server address: ${tcpServerProvider.address}:${tcpServerProvider.port}',
          textAlign: TextAlign.center,
          style: textStyle,
        ),
        ElevatedButton(
            onPressed: () async {
              await _disableServer(webRtcProvider, tcpServerProvider);
            },
            child: const Text('Disable WebRTC')),
      ],
    );
  }

  Future<void> _enableServer(WebRtcProvider webRtcProvider,
      TcpServerProvider tcpServerProvider) async {
    await tcpServerProvider.enable();

    webRtcProvider.onIceCandidate = (RTCIceCandidate event)  {
      tcpServerProvider.broadcast(IceCandidatePacket.fromCandidate(event));
    };

    tcpServerProvider.listen(transformData(webRtcProvider, tcpServerProvider));
  }

  Future<void> _disableServer(WebRtcProvider webRtcProvider,
      TcpServerProvider tcpServerProvider) async {
    await webRtcProvider.disable();
    tcpServerProvider.disable();
  }
}
