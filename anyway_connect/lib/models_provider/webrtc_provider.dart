import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// https://blog.flutter.wtf/video-chat-in-flutter-using-webrtc/
class WebRtcProvider with ChangeNotifier {
  static const Map<String, dynamic> _configuration = {};

  final List<StreamSubscription> _subscriptions = [];

  RTCVideoRenderer? _localRenderer;

  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCPeerConnection? _peerConnection;

  bool _isConnected = false;
  bool _videoDisabled = false;

  bool get isConnected => _isConnected;
  RTCVideoRenderer? get localRenderer => _localRenderer;

  void setConnected(bool isConnected) {
    _isConnected = isConnected;
    notifyListeners();
  }

  void init() {}

  @override
  dispose() {
    disable();
    super.dispose();
  }

  Future<void> enable() async {
    _localRenderer = RTCVideoRenderer();
    await _localRenderer!.initialize();

    await _enableUserMediaStream();
    await _createRoom();
    _enableVideo();
  }

  Future<void> disable() async {
    _disableVideo();
    _localStream?.dispose();
    _remoteStream?.dispose();
    _peerConnection?.dispose();
    _localRenderer?.dispose();
  }
  
  Future<void> _enableUserMediaStream() async {
    var stream = await navigator.mediaDevices.getUserMedia({ 'video': true }, );
    _localStream = stream;
    notifyListeners();
  }

  Future<void> _createPeerConnection() async {
    final peerConnection = await createPeerConnection(_configuration);
    _peerConnection = peerConnection;
    notifyListeners();
  }

  void _enableVideo() {
    if (_videoDisabled) {
      _localStream?.getVideoTracks().forEach((track) => track.enabled = true);
      _videoDisabled = false;
      notifyListeners();
    }
  }

  void _disableVideo() {
    if (!_videoDisabled) {
      _localStream?.getVideoTracks().forEach((track) => track.enabled = false);
      _videoDisabled = true;
      notifyListeners();
    }
  }

  Future<void> _handup() async {
    if (_localRenderer == null) return;

    final tracks = _localRenderer!.srcObject?.getTracks();
    for (var track in tracks!) {
      track.stop();
    }

    if (_peerConnection != null) {
      await _peerConnection!.close();
    }

    _localStream!.dispose();

    for (final subs in _subscriptions) {
      subs.cancel();
    }
  }

  Future<void> _createRoom() async {
    await _createPeerConnection();

    final offer = await _peerConnection!.createOffer();
    const roomId = 'anyway-connect';

    print('offer: ${offer.sdp?.replaceAll("\r\n", "\\r\\n")}\\r\\n');

    _registerPeerConnectionListeners(roomId);

    await _peerConnection!.setLocalDescription(offer);

    _subscriptions.addAll([

    ]);
  }

  void _registerPeerConnectionListeners(String roomId) {
    _peerConnection!.onIceCandidate = (candidate) {
      print('onIceCandidate: $candidate');
    };

    _peerConnection!.onAddStream = (stream) {
      _remoteStream = stream;
      notifyListeners();
    };

    _peerConnection!.onTrack = (event) {
      event.streams[0].getTracks().forEach((track) => _remoteStream?.addTrack(track));
    };
  }
}