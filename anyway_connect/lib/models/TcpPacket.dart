import 'dart:typed_data';

import 'package:anyway_connect/models/networkTypes.dart';
import 'package:anyway_connect/models/packet_id.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

abstract class TcpPacket {
  late PacketId id;

  Uint8List toBytes();
}

class InitConnectionPacket implements TcpPacket {
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

    int offset = 0;

    // Get SDP
    var (sdp, sdpSize) = VarString.fromBytes(bytes.sublist(1));
    offset += sdpSize;

    // Get type
    var (type, typeSize) = VarString.fromBytes(bytes.sublist(1 + offset));
    offset += typeSize;

    // Return the packet type
    return SdpDescriptionPacket(sdp: sdp.value, type: type.value);
  }

  @override
  Uint8List toBytes() {
    // Get sdp
    var sdp = VarString(this.sdp!);
    // Get type
    var type = VarString(this.type!);

    return Uint8List.fromList([
      // Packet type
      id.index,

      // SDP
      ...sdp.toBytes(),

      // Type
      ...type.toBytes(),
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
    var candidate = VarString(this.candidate!);
    // Get candidateId
    var mId = VarString(this.mId!);
    // Get label (ensure it is 32 bits integer with padding)
    var label = ByteData(4)..setInt32(0, this.label!);

    return Uint8List.fromList([
      // Packet type
      id.index,

      // Candidate
      ...candidate.toBytes(),

      // CandidateId
      ...mId.toBytes(),

      // Label
      ...label.buffer.asUint8List(),
    ]);
  }

  static IceCandidatePacket fromCandidate(RTCIceCandidate candidate) {
    return IceCandidatePacket(
        candidate: candidate.candidate,
        mId: candidate.sdpMid,
        label: candidate.sdpMLineIndex);
  }

  static IceCandidatePacket fromBytes(Uint8List bytes) {
    // Check if the packet is valid
    if (bytes.length < 2) {
      throw Exception('Invalid packet');
    }

    int offset = 0;
    // Get candidate
    var (candidate, candidateSize) = VarString.fromBytes(bytes.sublist(1));
    offset += candidateSize;

    // Get candidateId
    var (candidateId, mIdSize) = VarString.fromBytes(bytes.sublist(1 + offset));
    offset += mIdSize;

    // Get label
    var label =
        ByteData.sublistView(bytes, 1 + offset, 1 + offset + 4).getInt32(0);

    // Return the packet type
    return IceCandidatePacket(
        candidate: candidate.value, mId: candidateId.value, label: label);
  }
}

class EndCommunicationPacket implements TcpPacket {
  @override
  PacketId id = PacketId.endConnection;

  static EndCommunicationPacket fromBytes(Uint8List bytes) {
    // Check if the packet is valid
    if (bytes.length != 1) {
      throw Exception('Invalid packet');
    }

    // Return the packet type
    return EndCommunicationPacket();
  }

  @override
  Uint8List toBytes() {
    return Uint8List.fromList([id.index]);
  }
}
