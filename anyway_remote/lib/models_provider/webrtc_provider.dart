import 'package:anyway_remote/models/client_packets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRtcProvider with ChangeNotifier {
  // RTC peer connection
  RTCPeerConnection? _rtcPeerConnection;

  // videoRenderer for remotePeer
  var _remoteRTCVideoRenderer = RTCVideoRenderer();

  // On new ice candidate callback
  void Function(RTCIceCandidate)? onIceCandidate;

  bool get isConnected =>
      _rtcPeerConnection?.connectionState ==
      RTCPeerConnectionState.RTCPeerConnectionStateConnected;

  RTCVideoRenderer get remoteVideoRenderer => _remoteRTCVideoRenderer;

  Future<void> setupPeerConnection() async {
    // Create peer connections
    _rtcPeerConnection = await createPeerConnection({});

    // listen for remotePeer mediaTrack event
    _rtcPeerConnection!.onTrack = (event) async {
      print('Got remote track: ${event.streams[0]}');
      await _remoteRTCVideoRenderer.initialize();
      _remoteRTCVideoRenderer.srcObject = event.streams[0];
      notifyListeners();
    };

    // Listen for local iceCandidate and add it to the list of IceCandidates
    _rtcPeerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      onIceCandidate?.call(candidate);
      notifyListeners();
    };
  }

  Future<void> disable() async {
    _remoteRTCVideoRenderer.dispose();
    _remoteRTCVideoRenderer = RTCVideoRenderer();

    _rtcPeerConnection?.close();
    _rtcPeerConnection = null;
  }

  Future<RTCSessionDescription> createAnswer(SdpDescriptionPacket offer) async {
    // Set SDP offer as remoteDescription for peerConnection
    await _rtcPeerConnection!
        .setRemoteDescription(RTCSessionDescription(offer.sdp, offer.type));

    // Create SDP answer
    final RTCSessionDescription answer =
        await _rtcPeerConnection!.createAnswer();

    // Set SDP answer as localDescription for peerConnection
    await _rtcPeerConnection!.setLocalDescription(answer);

    return answer;
  }

  void addCandidate(IceCandidatePacket candidatePacket) {
    print('Adding candidate');
    _rtcPeerConnection!.addCandidate(RTCIceCandidate(
        candidatePacket.candidate, candidatePacket.mId, candidatePacket.label));
  }
}
