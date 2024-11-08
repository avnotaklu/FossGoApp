import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/error_handling/signal_r_error.dart';
import 'package:go/services/api.dart';
import 'package:go/services/auth.dart';
import 'package:go/services/auth_provider.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/signalr_client.dart';

class SignalRProvider extends ChangeNotifier {
  // The location of the SignalR Server.
  final serverUrl = "${Api.baseUrl}/gameHub";
  Either<SignalRError, String> connectionId;
  // connectionCompleter.future;
  // final Either<SignalRError, String> connectionCompleter =
  // Completer();
  // late final AuthProvider authBloc;
  late final HubConnection hubConnection;
  late final Timer _timeoutTimer;
  @override
  void dispose() {
    // TODO: implement dispose
    debugPrint("Disposing SignalR Provider");
  }

// Creates the connection by using the HubConnectionBuilder.
  SignalRProvider()
      : connectionId = Either.left(SignalRError(
          message: "Connection not started",
          connectionState: RegisterationConnectionState.Disconnected,
        )) {
    hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();
    listenMessages();
  }

  Future<Either<AppError, String>> connectSignalR() async {
    try {
      await hubConnection.start();
      final conId = hubConnection.connectionId!;
      connectionId = (Either.right(conId));
      return right(conId);
    } catch (e) {
      return left(AppError(message: e.toString()));
    }
  }

  void setupHubConnection() {
    // hubConnection.onclose(({error}) => debugPrint("Connection Closed"));

    // hubConnection.stateStream.listen((data) async {
    //   debugPrint("Connection State is now: ${data.name}");
    //   if (data == HubConnectionState.Connected) {
    //     final registerRes = await authBloc.registerUser(
    //         authBloc.currentUserRaw!, authBloc.token!, conId);
    //     registerRes.fold(
    //       (e) {
    //         hubConnection.stop();
    //         debugPrint(e.toString());
    //       },
    //       (v) {
    //         connectionId = (Either.right(conId));
    //         _timeoutTimer.cancel();
    //         notifyListeners();
    //       },
    //     );
    //   }
    //   if (data == HubConnectionState.Disconnected) {
    //     hubConnection.start();
    //     debugPrint("Connection Disconnected");
    //   }
    // });
    // _timeoutTimer = Timer(const Duration(seconds: 5), () {
    //   if (hubConnection.state != HubConnectionState.Connected) {
    //     connectionId = (Either.left(SignalRError(
    //         message: "Connection Timed Out",
    //         connectionState: RegisterationConnectionState.Disconnected)));
    //   }
    // });
  }

  Stream<SignalRMessage> get gameMessageStream => _gameMessageController.stream;

  final StreamController<SignalRMessage> _gameMessageController =
      StreamController<SignalRMessage>.broadcast();

  void listenMessages() {
    hubConnection.on('gameUpdate', (SignalRMessageListRaw? messagesRaw) {
      assert(messagesRaw != null, "Message can't be null");

      if (messagesRaw!.length != 1) {
        throw "messages count ${messagesRaw.length}, WHAT TO DO?";
      }

      var messageList = messagesRaw.signalRMessageList;
      var message = messageList.first;

      _gameMessageController.add(message);
    });
  }

  void silenceMessages() {
    hubConnection.off('gameUpdate');
  }
}
