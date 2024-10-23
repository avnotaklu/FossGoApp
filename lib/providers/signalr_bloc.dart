import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/signal_r_error.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/signalr_client.dart';

class SignalRBloc extends ChangeNotifier {
  // The location of the SignalR Server.
  final serverUrl = "http://192.168.188.71:8080/gameHub";
  Future<Either<SignalRError, String>> get connectionId =>
      connectionCompleter.future;
  final Completer<Either<SignalRError, String>> connectionCompleter =
      Completer();
  late final HubConnection hubConnection;
  late final Timer _timeoutTimer;
// Creates the connection by using the HubConnectionBuilder.
  SignalRBloc() {
    hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();
    hubConnection.start();
    hubConnection.onclose(({error}) => debugPrint("Connection Closed"));

    hubConnection.stateStream.listen((data) {
      debugPrint("Connection State is now: ${data.name}");
      if (data == HubConnectionState.Connected) {
        connectionCompleter.complete(Either.right(hubConnection.connectionId!));
        _timeoutTimer.cancel();
      }
    });
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (hubConnection.state != HubConnectionState.Connected) {
        connectionCompleter.complete(
            Either.left(SignalRError(message: "Connection Timed Out")));
      }
    });
  }

  StreamController<GameMessage> gameMessageController =
      StreamController<GameMessage>.broadcast();

  void listenMessages() {
    hubConnection.on('gameMessage', (data) {
      gameMessageController.add(GameMessage(data));
    });
  }

  void silenceMessages() {
    hubConnection.off('gameMessage');
    ;
  }

}

class GameMessage {
  dynamic placeholder;
  GameMessage(this.placeholder);
}
