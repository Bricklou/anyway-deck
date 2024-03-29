enum PacketId {
  // Emitted to start a connection
  initConnection,
  // Received to announce the WebRTC offer/answer
  sdpDescription,
  // Received sdp answer
  peerAnswer,
  // Received for new ice candidate
  iceCandidate,
  endConnection,
}
