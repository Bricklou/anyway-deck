import 'package:anyway_connect/models_provider/webrtc_provider.dart';
import 'package:flutter/material.dart';
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
                const Positioned(
                    top: 15,
                    left: 15,
                    child: Text('WebRTC',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54))),
                Positioned(
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
                            color: Theme.of(context).colorScheme.secondary))),
                Container(
                    padding: const EdgeInsets.all(10).copyWith(
                      top: 55,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Center(
                            child: Icon(Icons.desktop_windows_outlined,
                                size: 50,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.8))),
                        Consumer<WebRtcProvider>(
                            builder: (context, webrtcProvider, _) =>
                                renderWebRtcButton(webrtcProvider)),
                      ],
                    ))
              ],
            )));
  }

  Widget renderWebRtcButton(WebRtcProvider webRtcProvider) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return ElevatedButton(
          onPressed: () async {
            if (webRtcProvider.isConnected) {
              await webRtcProvider.disable();
            } else {
              await webRtcProvider.enable();
            }
          },
          child: Text(
              webRtcProvider.isConnected ? 'Disable WebRTC' : 'Enable WebRTC'));
    });
  }
}
