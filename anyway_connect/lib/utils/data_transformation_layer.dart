import 'package:anyway_connect/models/TcpPacket.dart';
import 'package:anyway_connect/models_provider/webrtc_provider.dart';

Future<void> Function(TcpPacket packet) transformData(WebRtcProvider webRtcProvider) {
  return (TcpPacket packet) async {
    if (packet is InitConnectionPacket) {
      // Send packet
    }

    // Ignore, the packet is invalid
  };
}