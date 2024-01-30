import 'package:anyway_connect/models_provider/webrtc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

class WebRTCVideo extends StatefulWidget {
  const WebRTCVideo({super.key});

  @override
  State<StatefulWidget> createState() => _WebRTCVideo();
}

class _WebRTCVideo extends State<WebRTCVideo> {
  @override
  Widget build(BuildContext context) {
    final webrtcProvider = context.watch<WebRtcProvider>();

    if (!webrtcProvider.isConnected) {
      return const Center(
        child: Text('WebRTC is not connected'),
      );
    }

    return RTCVideoView(
      webrtcProvider.localVideoRenderer,
      mirror: true,
      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
    );
  }
}