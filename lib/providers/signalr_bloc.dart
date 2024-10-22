import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/signal_r_error.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/signalr_client.dart';

class SignalRBloc extends ChangeNotifier {
  // The location of the SignalR Server.
  final serverUrl = "http://192.168.188.71:8080/gameHub";
  late final String _connectionId;
  Future<Either<SignalRError, String>> get connectionId =>
      connectionCompleter.future;
  final Completer<Either<SignalRError, String>> connectionCompleter =
      Completer();
  late final HubConnection hubConnection;
  late final Timer _timeoutTimer;
  bool gameJoined = false;
// Creates the connection by using the HubConnectionBuilder.
  SignalRBloc() {
    hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();
    hubConnection.start();
    hubConnection.onclose(({error}) => debugPrint("Connection Closed"));

    hubConnection.stateStream.listen((data) {
      debugPrint("Connection State is now: ${data.name}");
      if (data == HubConnectionState.Connected) {
        connectionCompleter.complete(Either.right(hubConnection.connectionId!));
      }
    });
    _timeoutTimer = Timer(Duration(seconds: 5), () {
      if (hubConnection.state != HubConnectionState.Connected) {}
    });
    // TODO: shouldn't exist here
    listenFromGameJoin();
  }

  void listenFromGameJoin() {
    hubConnection.on('gameUpdate', (data) {
      debugPrint("Joined game BAHAHA");
      gameJoined = true;
      notifyListeners();
    });
  }
}
