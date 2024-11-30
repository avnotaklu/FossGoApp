import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/error_handling/signal_r_error.dart';
import 'package:go/services/api.dart';
import 'package:go/services/auth.dart';
import 'package:go/services/auth_provider.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:go/ui/homepage/find_match_dto.dart';
import 'package:signalr_netcore/default_reconnect_policy.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/json_hub_protocol.dart';
import 'package:signalr_netcore/signalr_client.dart';

class SignalRProvider extends ChangeNotifier {
  // The location of the SignalR Server.
  final serverUrl = "${Api.baseUrl}/mainHub";
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
    hubConnection = HubConnectionBuilder()
        .withUrl(serverUrl)
        // .withHubProtocol(JsonHubProtocol())
        .build();
    hubConnection.onclose(({Exception? error}) {
      debugPrint(error.toString());
    });
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

  Stream<SignalRMessage> get gameMessageStream => _gameMessageController.stream;

  final StreamController<SignalRMessage> _gameMessageController =
      StreamController<SignalRMessage>.broadcast();

  Stream<SignalRMessage> get userMessagesStream =>
      _gameMessageController.stream;

  final StreamController<SignalRMessage> _userMessageController =
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

    hubConnection.on('userUpdate', (SignalRMessageListRaw? messagesRaw) {
      assert(messagesRaw != null, "Message can't be null");

      if (messagesRaw!.length != 1) {
        throw "messages count ${messagesRaw.length}, WHAT TO DO?";
      }

      var messageList = messagesRaw.signalRMessageList;
      var message = messageList.first;

      _userMessageController.add(message);
    });
  }

  // Hub methods
  Future<void> findMatch(FindMatchDto dto) async {
    var res = await hubConnection
        .invoke('FindMatch', args: [dto.toMap()]).catchError((e) {
      var err = "Error in findMatch: $e";
      debugPrint(err);
      return err;
    });
    debugPrint(res.toString());
  }

  // Utils
  void silenceMessages() {
    hubConnection.off('gameUpdate');
  }

  Future<void> disconnect() async {
    await hubConnection.stop();
    silenceMessages();
  }
}
