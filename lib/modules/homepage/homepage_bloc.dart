// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:go/core/error_handling/app_error.dart';
import 'package:go/models/game.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/modules/gameplay/game_state/game_entrance_data.dart';
import 'package:go/services/api.dart';
import 'package:go/services/user_account.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/services/available_game.dart';
import 'package:go/services/game_join_dto.dart';
import 'package:go/services/ongoing_games.dart';
import 'package:go/services/signal_r_message.dart';

class HomepageBloc extends ChangeNotifier {
  List<UserAccount> otherActivePlayers = [];
  List<AvailableGame> _availableGames = [];
  List<AvailableGame> get availableGames => _availableGames
      .where((a) => !a.game.didStart() && !a.game.didEnd())
      .toList();

  List<OnGoingGame> myGames = [];

  var api = Api();
  final SignalRProvider signalRProvider;

  HomepageBloc({
    required this.signalRProvider,
    required this.authBloc,
  }) {
    listenForNewGame();
  }

  final AuthProvider authBloc;

  Future<Either<AppError, GameEntranceData>> joinGame(
      String gameId, String token) async {
    var game = await api.joinGame(GameJoinDto(gameId: gameId), token);
    return game;
  }

  Future<void> getAvailableGames(String token) async {
    var game = await api.getAvailableGames(token);
    game.fold((e) {
      debugPrint("Couldn't get available games");
    }, (games) {
      _availableGames.addAll(games.games);
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
        if (newGameMessage.game.creatorInfo.id != authBloc.myId) {
          _availableGames.add(newGameMessage.game);
        }
        notifyListeners();
      }
    });
  }

  void addNewGame(OnGoingGame g) {
    myGames.add(g);
    notifyListeners();
  }
}
