import 'dart:async';
import 'dart:math';
import 'package:barebones_timer/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/utils/system_utilities.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/score_calculation_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/models/cluster.dart';
import 'package:go/models/game.dart';
import 'package:go/models/game_move.dart';
import 'package:go/models/position.dart';
import 'package:go/models/stone.dart';
import 'package:go/providers/live_game_interactor.dart';
import 'package:go/providers/signalr_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/services/app_user.dart';
import 'package:go/services/auth_provider.dart';
import 'package:go/services/edit_dead_stone_dto.dart';
import 'package:go/services/game_over_message.dart';
import 'package:go/services/move_position.dart';
import 'package:go/services/join_message.dart';
import 'package:go/services/public_user_info.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:go/services/user_rating.dart';
import 'package:go/ui/gameui/game_timer.dart';
import 'package:go/utils/player.dart';
import 'package:ntp/ntp.dart';
import 'package:signalr_netcore/errors.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:timer_count_down/timer_controller.dart';

class DisplayablePlayerData {
  final String? displayName;
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

  StoneType? get getWinnerStone => game.players[game.winnerId];
  StoneType? get getLoserStone => game.players[game.winnerId] == null
      ? null
      : StoneType.values[1 - game.players[game.winnerId]!.index];

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
      gameInteractor.myPlayerData(game);
  DisplayablePlayerData get topPlayerUserInfo =>
      gameInteractor.otherPlayerData(game);

  // List<Duration> times;
  final List<TimerController> _controller;

  List<TimerController> get timerController => _controller;

  late final StageType curStageTypeNotifier;
  StageType get curStageType => curStageTypeNotifier;

  set curStageType(StageType stage) {
    // cur_stage.disposeStage();
    curStageTypeNotifier = stage;
  }

  final GameInteractor gameInteractor;
  final SystemUtilities systemUtilities;
  late final StreamSubscription<GameUpdate> gameUpdateListener;

  GameStateBloc(
    this.game,
    this.gameInteractor,
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

    gameUpdateListener = gameInteractor.gameUpdate.listen((event) {
      updateStateFromGame(event.makeCopyFromOldGame(game));
    });
  }

  Future<Either<AppError, Game>> playMove(
      Position? position, StoneLogic stoneLogic) async {
    bool canPlayMove = gameInteractor.isThisAccountsTurn(game);
    var updateStone = gameInteractor.thisAccountStone(game);

    if (position == null && canPlayMove) {
      canPlayMove = true;
    } else if (position != null && canPlayMove) {
      canPlayMove = (stoneLogic.stoneAt(position) == null) &&
          stoneLogic.checkInsertable(position, updateStone);
    }

    if (!canPlayMove) {
      return left(AppError(message: "You can't play here"));
    }

    final move = MovePosition(
      x: position?.x,
      y: position?.y,
    );

    if (!move.isPass()) {
      stoneLogic.handleStoneUpdate(position, playerTurn, updateStone);
    }

    return (await gameInteractor.playMove(game, move)).map((g) {
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
    return (await gameInteractor.continueGame(game)).map((g) {
      return updateStateFromGame(g);
    });
  }

  Future<Either<AppError, Game>> acceptScores() async {
    return (await gameInteractor.acceptScores(game)).map((g) {
      return updateStateFromGame(g);
    });
  }

  Future<Either<AppError, Game>> resignGame() async {
    return (await gameInteractor.resignGame(game)).map((g) {
      return updateStateFromGame(g);
    });
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

  // Helpers
  bool hasPassedTwice() {
    var prev;
    bool hasPassedTwice = false;
    for (var i in (game.moves).reversed) {
      if (prev == null) {
        prev = i;
        continue;
      }

      if (i.isPass() && prev.isPass()) {
        hasPassedTwice = !hasPassedTwice;
      } else {
        break;
      }
    }
    return hasPassedTwice;
  }
}
