import 'dart:io';

import 'package:anyway_connect/models/TcpPacket.dart';
import 'package:anyway_connect/models_provider/tcp_server_provider.dart';
import 'package:anyway_connect/models_provider/webrtc_provider.dart';

Future<void> Function(TcpPacket packet, Socket socket) transformData(
    WebRtcProvider webRtcProvider, TcpServerProvider tcpServerProvider) {
  return (TcpPacket packet, Socket socket) async {
    if (packet is InitConnectionPacket) {
      // Send packet
      if (!webRtcProvider.isConnected) {
        await webRtcProvider.setupPeerConnection();

        // Create SDP offer and send it to the client
        var offer = await webRtcProvider.createOffer();
        var packet = SdpDescriptionPacket.fromSdp(offer);
        socket.add(packet.toBytes());
        socket.flush();
      }
      return;
    }

    if (packet is SdpDescriptionPacket) {
      if (!webRtcProvider.isConnected) {
        // When the client sends an SDP answer
        await webRtcProvider.setRemoteDescription(packet);
      }
      return;
    }

    if (packet is IceCandidatePacket) {
      // When the client sends an ICE candidate
      print('Received ice candidate');
      webRtcProvider.addCandidate(packet);
      return;
    }

    if (packet is EndCommunicationPacket) {
      // When the client ends the communication
      print('Client ended communication');
      await tcpServerProvider.send(EndCommunicationPacket());
      await webRtcProvider.disable();
      return;
    }
    // Ignore, the packet is invalid
  };
}
