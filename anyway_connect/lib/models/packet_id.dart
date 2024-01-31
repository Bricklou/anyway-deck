enum PacketId {
  // Received to start a connection
  initConnection,
  // Emitted to announce the WebRTC offer/answer
  sdpDescription,
  // Received sdp answer
  peerAnswer,
  // Emitted for new ice candidate
  iceCandidate,
  // Received to end the connection
  endConnection,
}
