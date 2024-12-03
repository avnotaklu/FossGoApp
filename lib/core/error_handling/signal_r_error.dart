// ignore_for_file: public_member_api_docs, sort_constructors_first


class SignalRError {
  final String message;
  final RegisterationConnectionState connectionState;

// HubConnectionState state;
  // final Conne
  SignalRError({
    required this.message,
    required this.connectionState,
  });
}

enum RegisterationConnectionState {
  /// The hub connection is disconnected.
  Disconnected,

  /// The hub connection is connecting.
  Connecting,

  /// The hub connection is connected.
  Connected,

  /// The hub connection is disconnecting.
  Disconnecting,

  /// The hub connection is reconnecting.
  Reconnecting,
}
