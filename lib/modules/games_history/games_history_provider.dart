import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/models/game.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/services/api.dart';
import 'package:go/services/game_and_opponent.dart';

class GamesHistoryProvider extends ChangeNotifier {
  int page = 0;
  bool isLastPage = false;
  final List<Game> games = [];
  final Api api;
  final AuthProvider auth;

  GamesHistoryProvider({required this.auth, required this.api});

  Future<void> loadGames() async {
    final token = auth.token!;
    final res = await api.getGamesHistory(token, page);

    res.fold(
      (error) {
        isLastPage = true;
        notifyListeners();
      },
      (games) {
        if (games.games.isEmpty) {
          isLastPage = true;
          notifyListeners();
        }
        this.games.addAll(games.games);
        notifyListeners();
        page++;
      },
    );
  }

  Future<Either<AppError, GameAndOpponent?>> getGameAndOpponent(
      Game game) async {
    final token = auth.token!;
    final myId = auth.myId;
    final opponent = game.getOtherPlayerIdFromPlayerId(myId);

    if (opponent == null) {
      return right(null);
    }

    final res = await api.getOpponent(opponent, token);

    return res.map((r) => GameAndOpponent(game: game, opponent: r));
  }
}
