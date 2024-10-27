// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:go/core/error_handling/app_error.dart';
import 'package:go/models/game.dart';
import 'package:go/providers/signalr_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/services/app_user.dart';
import 'package:go/services/game_creation_dto.dart';
import 'package:go/services/game_join_dto.dart';
import 'package:go/services/signal_r_message.dart';

class HomepageBloc extends ChangeNotifier {
  List<AppUser> otherActivePlayers = [];
  List<Game> availableGames = [];

  var api = Api();
  final SignalRProvider signalRProvider;

  HomepageBloc({
    required this.signalRProvider,
  }) {
    listenForNewGame();
  }

  Future<Either<AppError, GameJoinMessage>> joinGame(String gameId, String token) async {
    var game = await api.joinGame(GameJoinDto(gameId: gameId), token);
    return game.mapLeft(AppError.fromApiError);
  }

  Future<void> getAvailableGames(String token) async {
    var game = await api.getAvailableGames(token);
    game.fold((e) {
      debugPrint("Couldn't get available games");
    }, (games) {
      availableGames.addAll(games.games);
    });
  }

  void listenForNewGame() {
    signalRProvider.hubConnection.on('gameUpdate',
        (SignalRMessageListRaw? messagesRaw) {
      assert(messagesRaw != null, "New Game data can't be null");
      var messageList = messagesRaw!.signalRMessageList;
      if (messageList.length != 1) {
        throw "messages count ${messageList.length}, WHAT TO DO?";
      }
      var message = messageList.first;
      if (message.type == "NewGame") {
        debugPrint("Found new game");
        final newGameMessage = (message.data as NewGameCreatedMessage);
        availableGames.add(newGameMessage.game);
        debugPrint("Found new game done");
        notifyListeners();
      }
    });
  }
}
