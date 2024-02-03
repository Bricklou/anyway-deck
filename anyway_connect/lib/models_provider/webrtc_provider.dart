import 'dart:async';

import 'package:anyway_connect/models/TcpPacket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// https://blog.flutter.wtf/video-chat-in-flutter-using-webrtc/
class WebRtcProvider with ChangeNotifier {
  // RTC peer connection
  RTCPeerConnection? _rtcPeerConnection;

  // mediaStream for localPeer
  MediaStream? _localStream;

  // videoRenderer for localPeer
  var _localRTCVideoRenderer = RTCVideoRenderer();

  // list of rtcCandidates to be sent over signalling
  List<RTCIceCandidate> rtcIceCandidates = [];

  // On new ice candidate callback
  void Function(RTCIceCandidate)? onIceCandidate;

  RTCVideoRenderer get localVideoRenderer => _localRTCVideoRenderer;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<void> setupPeerConnection() async {
    // Create peer connections
    _rtcPeerConnection = await createPeerConnection({});

    // Get localStream
    print('Getting user media...');
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': false,
      'video': {'facingMode': 'environment'},
    });

    // Add mediaTrack to peerConnection
    print('Adding local stream...');
    _localStream!.getTracks().forEach((track) {
      _rtcPeerConnection!.addTrack(track, _localStream!);
      notifyListeners();
    });

    // Set source for local video renderer
    await _localRTCVideoRenderer.initialize();
    _localRTCVideoRenderer.srcObject = _localStream;

    // Listen for local iceCandidate and add it to the list of IceCandidates
    _rtcPeerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      rtcIceCandidates.add(candidate);
      onIceCandidate?.call(candidate);
      notifyListeners();
    };

    _rtcPeerConnection?.onConnectionState = (state) {
      print('Connection state: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _isConnected = true;
      } else {
        _isConnected = false;
      }
      notifyListeners();
    };

    notifyListeners();
  }

  Future<void> disable() async {
    print('Disabling WebRTC...');
    _localRTCVideoRenderer.dispose();
    _localRTCVideoRenderer = RTCVideoRenderer();

    _rtcPeerConnection?.dispose();
    _rtcPeerConnection = null;

    _localStream?.getTracks().forEach((track) {
      track.stop();
    });

    _localStream?.dispose();
    _localStream = null;

    _isConnected = false;

    notifyListeners();
  }

  Future<RTCSessionDescription> createOffer() async {
    // Create a new SDP offer
    print('Creating offer...');
    final offer = await _rtcPeerConnection!.createOffer({});
    _rtcPeerConnection!.setLocalDescription(offer);
    return offer;
  }

  Future<void> setRemoteDescription(SdpDescriptionPacket packet) async {
    print('Setting remote description...');
    // Set SDP answer as remoteDescription for peerConnection
    await _rtcPeerConnection!
        .setRemoteDescription(RTCSessionDescription(packet.sdp, packet.type));
  }

  void addCandidate(IceCandidatePacket packet) {
    print('Adding candidate...');
    _rtcPeerConnection!.addCandidate(
        RTCIceCandidate(packet.candidate, packet.mId, packet.label));
  }
}
