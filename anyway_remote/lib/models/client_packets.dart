import 'dart:typed_data';

import 'package:anyway_remote/models/packets_id.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

abstract class TcpPacket {
  late PacketId id;

  Uint8List toBytes();
}

class InitConnectionPacket implements TcpPacket {
  InitConnectionPacket();

  @override
  PacketId id = PacketId.initConnection;

  static InitConnectionPacket fromBytes(Uint8List bytes) {
    // Check if the packet is valid
    if (bytes.length != 1) {
      throw Exception('Invalid packet');
    }

    // Return the packet type
    return InitConnectionPacket();
  }

  @override
  Uint8List toBytes() {
    return Uint8List.fromList([id.index]);
  }
}

class SdpDescriptionPacket implements TcpPacket {
  @override
  PacketId id = PacketId.sdpDescription;

  String? sdp;
  String? type;

  SdpDescriptionPacket({this.sdp, this.type});

  static SdpDescriptionPacket fromSdp(RTCSessionDescription sdp) {
    return SdpDescriptionPacket(sdp: sdp.sdp, type: sdp.type);
  }

  static SdpDescriptionPacket fromBytes(Uint8List bytes) {
    // Check if the packet is valid
    if (bytes.length < 2) {
      throw Exception('Invalid packet');
    }

    // Get SDP size
    var sdpSize = bytes[1];
    // Get SDP
    var sdp = String.fromCharCodes(bytes.sublist(2, 2 + sdpSize));

    // Get type size
    var typeSize = bytes[2 + sdpSize];
    // Get type
    var type = String.fromCharCodes(bytes.sublist(3 + sdpSize, 3 + sdpSize + typeSize));

    // Return the packet type
    return SdpDescriptionPacket(sdp: sdp, type: type);
  }

  @override
  Uint8List toBytes() {
    // Get sdp
    var sdp = Uint8List.fromList(this.sdp!.codeUnits);
    var sdpLength = ByteData(4)..setInt32(0, sdp.length);
    // Get type
    var type = Uint8List.fromList(this.type!.codeUnits);
    var typeLength = ByteData(4)..setInt32(0, type.length);

    return Uint8List.fromList([
      // Packet type
      id.index,

      // SDP size (ensure it is 32 bits integer with padding)
      ...sdpLength.buffer.asUint8List(),
      // SDP
      ...sdp,

      // Type size
      ...typeLength.buffer.asUint8List(),
      // Type
      ...type,
    ]);
  }
}

class IceCandidatePacket implements TcpPacket {
  @override
  PacketId id = PacketId.iceCandidate;

  String? candidate;
  String? mId;
  int? label;

  IceCandidatePacket({this.candidate, this.mId, this.label});

  @override
  Uint8List toBytes() {
    // Get candidate
    var candidate = Uint8List.fromList(this.candidate!.codeUnits);
    var candidateLength = ByteData(4)..setInt32(0, candidate.length);
    // Get candidateId
    var mId = Uint8List.fromList(this.mId!.codeUnits);
    var mIdLength = ByteData(4)..setInt32(0, mId.length);

    return Uint8List.fromList([
      // Packet type
      id.index,

      // Candidate size
      ...candidateLength.buffer.asUint8List(),
      // Candidate
      ...candidate,

      // CandidateId size
      ...mIdLength.buffer.asUint8List(),
      // CandidateId
      ...mId,

      // Label
      label!,
    ]);
  }

  static IceCandidatePacket fromCandidate(RTCIceCandidate candidate) {
    return IceCandidatePacket(candidate: candidate.candidate, mId: candidate.sdpMid, label: candidate.sdpMLineIndex);
  }

  static IceCandidatePacket fromBytes(Uint8List bytes) {
    // Check if the packet is valid
    if (bytes.length < 2) {
      throw Exception('Invalid packet');
    }

    // Get candidate size
    var candidateSize = bytes[1];
    // Get candidate
    var candidate = String.fromCharCodes(bytes.sublist(2, 2 + candidateSize));

    // Get candidateId size
    var candidateIdSize = bytes[2 + candidateSize];
    // Get candidateId
    var candidateId = String.fromCharCodes(bytes.sublist(3 + candidateSize, 3 + candidateSize + candidateIdSize));

    // Get label
    var label = bytes[3 + candidateSize + candidateIdSize];

    // Return the packet type
    return IceCandidatePacket(candidate: candidate, mId: candidateId, label: label);
  }
}
