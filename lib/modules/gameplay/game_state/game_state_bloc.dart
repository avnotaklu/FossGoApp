import 'dart:async';
import 'package:barebones_timer/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/utils/system_utilities.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';
import 'package:go/modules/gameplay/stages/stage.dart';
import 'package:go/models/game.dart';
import 'package:go/models/game_move.dart';
import 'package:go/models/position.dart';
import 'package:go/modules/gameplay/game_state/game_state_oracle.dart';
import 'package:go/services/edit_dead_stone_dto.dart';
import 'package:go/services/game_over_message.dart';
import 'package:go/services/move_position.dart';
import 'package:go/services/player_rating.dart';

import 'package:signalr_netcore/errors.dart';

class DisplayablePlayerData {
  final String displayName;
  final StoneType? stoneType;
  final PlayerRatingData? rating;

  DisplayablePlayerData({
    required this.displayName,
    required this.stoneType,
    required this.rating,
  });
}

class GameStateBloc extends ChangeNotifier {
  Game game;

  int get turn => game.moves.length;
  int get playerTurn => game.moves.length % 2;

  int get gametime => game.timeControl.mainTimeSeconds;

  StoneType? get getWinnerStone => game.result?.etWinnerStone();
  StoneType? get getLoserStone => game.result?.getLoserStone();

  GameOverMethod? get getGameOverMethod => game.gameOverMethod;

  List<double> get getSummedPlayerScores => [
        game.finalTerritoryScores[0].toDouble() + game.prisoners[0],
        game.finalTerritoryScores[1].toDouble() + game.prisoners[1] + game.komi,
      ];

  String getPlayerIdFromStoneType(StoneType stone) {
    return game.players.entries
        .firstWhere((element) => element.value == stone)
        .key;
  }

  Map<StoneType, bool> acceptedBy = {
    StoneType.black: false,
    StoneType.white: false
  };

  // Join Data

  DisplayablePlayerData get bottomPlayerUserInfo =>
      gameOracle.myPlayerData(game);
  DisplayablePlayerData? get topPlayerUserInfo =>
      gameOracle.otherPlayerData(game);

  // List<Duration> times;
  final List<TimerController> _controller;

  List<TimerController> get timerController => _controller;

  late StageType curStageType;

  final GameStateOracle gameOracle;
  final SystemUtilities systemUtilities;
  late final StreamSubscription<GameUpdate> gameUpdateListener;

  GameStateBloc(
    this.game,
    this.gameOracle,
    this.systemUtilities,
  ) : _controller = [
          TimerController(
            autoStart: false,
            updateInterval: const Duration(milliseconds: 100),
            duration: Duration(seconds: game.timeControl.mainTimeSeconds),
          ),
          TimerController(
            autoStart: false,
            updateInterval: const Duration(milliseconds: 100),
            duration: Duration(seconds: game.timeControl.mainTimeSeconds),
          )
        ] {
    updateStateFromGame(game);

    gameUpdateListener = gameOracle.gameUpdate.listen((event) {
      updateStateFromGame(event.makeCopyFromOldGame(game));
    });
  }

  Future<Either<AppError, Game>> playMove(
      Position? position, StoneLogic stoneLogic) async {
    bool canPlayMove = gameOracle.isThisAccountsTurn(game);
    var updateStone = gameOracle.thisAccountStone(game);

    if (position == null && canPlayMove) {
      canPlayMove = true;
    } else if (position != null && canPlayMove) {
      canPlayMove = stoneLogic.checkInsertable(position, updateStone);
    }

    if (!canPlayMove) {
      return left(AppError(message: "You can't play here"));
    }

    final move = MovePosition(
      x: position?.x,
      y: position?.y,
    );

    return (await gameOracle.playMove(game, move)).map((g) {
      return updateStateFromGame(g);
    });
  }

  void updateNewPlayerTimes(Game game) {
    _controller[playerTurn].updateDuration(Duration(
        milliseconds:
            game.playerTimeSnapshots[playerTurn].mainTimeMilliseconds));

    _controller[1 - playerTurn].updateDuration(Duration(
        milliseconds:
            game.playerTimeSnapshots[1 - playerTurn].mainTimeMilliseconds));
  }

  void recalculatePlayerLagTime() {
    _controller[playerTurn].updateDuration(_controller[playerTurn].duration -
        systemUtilities.currentTime.difference(
          game.playerTimeSnapshots[playerTurn].snapshotTimestamp,
        ));
  }

  String getPlayerIdFromTurn(int turn) {
    for (var e in game.players.entries) {
      if (e.value.index == turn) {
        return e.key;
      }
    }
    throw NotImplementedException();
  }

  Future<Either<AppError, Game>> continueGame() async {
    return (await gameOracle.continueGame(game)).map((g) {
      return updateStateFromGame(g);
    });
  }

  Future<Either<AppError, Game>> acceptScores() async {
    return (await gameOracle.acceptScores(game)).map((g) {
      return updateStateFromGame(g);
    });
  }

  Future<Either<AppError, Game>> resignGame() async {
    return (await gameOracle.resignGame(game)).map((g) {
      return updateStateFromGame(g);
    });
  }

  // void addDeadStones(Position pos) async {
  //   final token = authBloc.token!;
  //   final res = await api.editDeadStoneCluster(
  //     EditDeadStoneClusterDto(position: pos, state: DeadStoneState.Dead),
  //     token,
  //     gameStateBloc.game.gameId,
  //   );

  //   res.fold((e) {}, (r) {
  //     applyDeadStones(pos, DeadStoneState.Dead);
  //   });
  // }

  // void removeDeadStones(Position pos) async {
  //   final token = authBloc.token!;
  //   applyDeadStones(pos, DeadStoneState.Alive);
  // }

  Future<Either<AppError, Game>> editDeadStone(
      Position pos, DeadStoneState state) async {
    return gameOracle.editDeadStoneCluster(game, pos, state);
  }

  void startPausedTimerOfActivePlayer() {
    timerController[playerTurn].start();
    timerController[1 - playerTurn].pause();
  }

  Game updateStateFromGame(Game game) {
    this.game = game;
    updateStageType(game.gameState);

    if (game.didStart()) {
      updateNewPlayerTimes(game);
    }

    if (game.gameState == GameState.playing) {
      recalculatePlayerLagTime();
      startPausedTimerOfActivePlayer();
    } else {
      timerController[0].pause();
      timerController[1].pause();
    }

    notifyListeners();
    return game;
  }

  void updateStageType(GameState state) {
    if (state == GameState.playing) {
      curStageType = StageType.Gameplay;
    } else if (state == GameState.scoreCalculation) {
      curStageType = StageType.ScoreCalculation;
    } else if (state == GameState.ended) {
      curStageType = StageType.GameEnd;
    } else if (state == GameState.waitingForStart) {
      curStageType = StageType.BeforeStart;
    }
  }
}
