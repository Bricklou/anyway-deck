import 'dart:io';

import 'package:anyway_remote/models_provider/tcp_client_provider.dart';

import '../models/client_packets.dart';
import '../models_provider/webrtc_provider.dart';

Future<void> Function(TcpPacket packet, Socket socket) transformData(
    WebRtcProvider webRtcProvider, TcpClientProvider tcpServerProvider) {
  return (TcpPacket packet, Socket socket) async {
    if (packet is SdpDescriptionPacket) {
      // Send packet
      if (!webRtcProvider.isConnected) {
        await webRtcProvider.setupPeerConnection();

        // Create SDP offer and send it to the client
        final answer = await webRtcProvider.createAnswer(packet);
        socket.add(SdpDescriptionPacket.fromSdp(answer).toBytes());
        socket.flush();
      }
      return;
    }

    if (packet is IceCandidatePacket) {
      print('Received ice candidate');
      webRtcProvider.addCandidate(packet);
      return;
    }
    // Ignore, the packet is invalid
  };
}