// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:go/core/error_handling/app_error.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/services/user_account.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/services/available_game.dart';
import 'package:go/services/game_join_dto.dart';
import 'package:go/services/my_games.dart';
import 'package:go/services/signal_r_message.dart';

class HomepageBloc extends ChangeNotifier {
  List<UserAccount> otherActivePlayers = [];
  List<AvailableGame> availableGames = [];
  List<MyGame> myGames = [];

  var api = Api();
  final SignalRProvider signalRProvider;

  HomepageBloc({
    required this.signalRProvider,
    required this.authBloc,
  }) {
    listenForNewGame();
  }

  final AuthProvider authBloc;

  Future<Either<AppError, GameJoinMessage?>> joinGame(
      String gameId, String token) async {
    var game = await api.joinGame(GameJoinDto(gameId: gameId), token);
    return game;
  }

  Future<void> getAvailableGames(String token) async {
    var game = await api.getAvailableGames(token);
    game.fold((e) {
      debugPrint("Couldn't get available games");
    }, (games) {
      availableGames.addAll(games.games);
      notifyListeners();
    });
  }

  Future<void> getMyGames(String token) async {
    var game = await api.getMyGames(token);
    game.fold((e) {
      debugPrint("Couldn't get my games");
    }, (games) {
      myGames.addAll(games.games);
      notifyListeners();
    });
  }

  void listenForNewGame() {
    signalRProvider.userMessagesStream.listen((message) {
      if (message.type == SignalRMessageTypes.newGame) {
        debugPrint("New game was recieved");
        final newGameMessage = (message.data as NewGameCreatedMessage);
        if (newGameMessage.game.creatorInfo.id == authBloc.currentUserInfo.id) {
          myGames.add(
              MyGame(game: newGameMessage.game.game, opposingPlayer: null));
        } else {
          availableGames.add(newGameMessage.game);
        }
        notifyListeners();
      }
    });
  }
}
