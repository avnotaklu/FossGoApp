import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/error_handling/signal_r_error.dart';
import 'package:go/services/api.dart';

import 'package:go/services/signal_r_message.dart';
import 'package:go/services/find_match_dto.dart';
import 'package:signalr_netcore/signalr_client.dart';

class SignalRProvider extends ChangeNotifier {
  // The location of the SignalR Server.
  final serverUrl = "${Api.baseUrl}/mainHub";
  Either<SignalRError, String> connectionId;
  // connectionCompleter.future;
  // final Either<SignalRError, String> connectionCompleter =
  // Completer();
  // late final AuthProvider authBloc;
  HubConnection? hubConnection;
  late final Timer _timeoutTimer;
  @override
  void dispose() {
    // TODO: implement dispose
    debugPrint("Disposing SignalR Provider");
  }

// Creates the connection by using the HubConnectionBuilder.
  SignalRProvider()
      : connectionId = Either.left(
          SignalRError(
            message: "Connection not started",
            connectionState: RegisterationConnectionState.Disconnected,
          ),
        );

  Future<Either<AppError, String>> connectSignalR(String token) async {
    try {
      hubConnection = HubConnectionBuilder()
          .withUrl(
        serverUrl,
        options: HttpConnectionOptions(
          accessTokenFactory: () async => token,
        ),
      )
          .withAutomaticReconnect(
        reconnectPolicy: null,
        // retryDelays: [
        //   0,
        //   2000,
        //   2000,
        //   2000,
        // ],
      ).build();
      hubConnection!.onclose(({Exception? error}) {
        debugPrint("Connection closed: ${error.toString()}");
      });

      hubConnection!.onreconnecting(({Exception? error}) {
        _reconnectionC.sink.add(false);
        debugPrint("Connection reconnecting: ${error.toString()}");
      });

      hubConnection!.onreconnected(({String? connectionId}) {
        _reconnectionC.sink.add(true);
        debugPrint("Connection reconnected with Id: $connectionId");
      });

      await hubConnection!.start();
      final conId = hubConnection!.connectionId!;
      connectionId = (Either.right(conId));

      listenMessages();

      return right(conId);
    } catch (e) {
      return left(AppError(message: e.toString()));
    }
  }

  final StreamController<bool> _reconnectionC = StreamController.broadcast();
  Stream<bool> get reconnectionStream => _reconnectionC.stream;

  Stream<SignalRMessage> get gameMessageStream => _gameMessageController.stream;

  final StreamController<SignalRMessage> _gameMessageController =
      StreamController<SignalRMessage>.broadcast();

  Stream<SignalRMessage> get userMessagesStream =>
      _userMessageController.stream;

  final StreamController<SignalRMessage> _userMessageController =
      StreamController<SignalRMessage>.broadcast();

  void listenMessages() {
    hubConnection!.on('gameUpdate', (SignalRMessageListRaw? messagesRaw) {
      assert(messagesRaw != null, "Message can't be null");

      if (messagesRaw!.length != 1) {
        throw "messages count ${messagesRaw.length}, WHAT TO DO?";
      }

      var messageList = messagesRaw.signalRMessageList;
      var message = messageList.first;

      debugPrint("Got game update: ${message.toJson()}");

      _gameMessageController.add(message);
    });

    hubConnection!.on('userUpdate', (SignalRMessageListRaw? messagesRaw) {
      assert(messagesRaw != null, "Message can't be null");

      if (messagesRaw!.length != 1) {
        throw "messages count ${messagesRaw.length}, WHAT TO DO?";
      }

      var messageList = messagesRaw.signalRMessageList;
      var message = messageList.first;

      debugPrint("Got user update: ${message.toJson()}");

      _userMessageController.add(message);
    });
  }

  // Hub methods
  Future<Either<AppError, Null>> findMatch(FindMatchDto dto) async {
    if (hubConnection == null ||
        hubConnection!.state != HubConnectionState.Connected) {
      return left(AppError(message: "Player Not connected"));
    }

    await hubConnection!.send('FindMatch', args: [dto.toMap()]).catchError((e) {
      var err = "Error in findMatch: $e";
      debugPrint(err);
    });

    return right(null);
  }

  Future<Either<AppError, Null>> cancelFind() async {
    if (hubConnection == null ||
        hubConnection!.state != HubConnectionState.Connected) {
      return left(AppError(message: "Player Not connected"));
    }

    await hubConnection!.send('CancelFind').catchError((e) {
      var err = "Error in findMatch: $e";
      debugPrint(err);
    });

    return right(null);
  }

  // Utils
  void silenceMessages() {
    hubConnection?.off('gameUpdate');
  }

  Future<void> disconnect() async {
    await hubConnection?.stop();
    silenceMessages();
  }
}
