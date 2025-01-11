import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/models/game.dart';
import 'package:go/models/variant_type.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/games_history/player_result.dart';
import 'package:go/services/api.dart';
import 'package:go/services/game_and_opponent.dart';

class GamesHistoryProvider extends ChangeNotifier {
  int page = 0;
  bool isLastPage = false;
  final List<Game> games = [];
  final Api api;
  final AuthProvider auth;

  BoardSize? boardSize;
  TimeStandard? timeStandard;
  PlayerResult? result;

  DateTime? from;
  DateTime? to;

  static const historyPageSize = 12;

  GamesHistoryProvider({required this.auth, required this.api});

  Future<void> loadGames() async {
    final res = await api.getGamesHistory(
      page,
      boardSize,
      timeStandard,
      result,
      from,
      to,
    );

    res.fold(
      (error) {
        isLastPage = true;
        notifyListeners();
      },
      (games) {
        if (games.games.length < historyPageSize) {
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
    final myId = auth.myId;
    final opponent = game.getOtherPlayerIdFromPlayerId(myId);

    if (opponent == null) {
      return right(null);
    }

    final res = await api.getOpponent(opponent);

    return res.map((r) => GameAndOpponent(game: game, opponent: r));
  }

  void setQueryParams({
    BoardSize? boardSize,
    TimeStandard? timeStandard,
    PlayerResult? result,
  }) {
    if (boardSize != this.boardSize ||
        timeStandard != this.timeStandard ||
        result != this.result) {
      page = 0;
      isLastPage = false;
      games.clear();
    }

    this.boardSize = boardSize ?? this.boardSize;
    this.timeStandard = timeStandard ?? this.timeStandard;
    this.result = result ?? this.result;
    notifyListeners();
  }

  void setFromTime(DateTime? fromTime) {
    if (from != fromTime) {
      page = 0;
      isLastPage = false;
      games.clear();
    }

    from = fromTime;
    notifyListeners();
  }

  void setToTime(DateTime? toTime) {
    if (to != toTime) {
      page = 0;
      isLastPage = false;
      games.clear();
    }

    to = toTime;
    notifyListeners();
  }
}
