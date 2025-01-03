// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/modules/gameplay/game_state/game_entrance_data.dart';
import 'package:go/modules/gameplay/middleware/local_gameplay_server.dart';
import 'package:go/modules/gameplay/middleware/score_calculator.dart';
import 'package:go/modules/gameplay/middleware/time_calculator.dart';
import 'package:go/models/time_control.dart';
import 'package:go/modules/gameplay/middleware/board_utility/board_utilities.dart';
import 'package:go/modules/stats/stats_repository.dart';
import 'package:go/services/game_and_opponent.dart';
import 'package:go/services/user_account.dart';
import 'package:signalr_netcore/errors.dart';

import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/utils/system_utilities.dart';
import 'package:go/modules/homepage/stone_selection_widget.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';
import 'package:go/models/game.dart';
import 'package:go/models/game_move.dart';
import 'package:go/models/position.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/services/edit_dead_stone_dto.dart';
import 'package:go/services/game_over_message.dart';
import 'package:go/services/move_position.dart';
import 'package:go/services/public_user_info.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:go/services/player_rating.dart';

// HACK: `GameUpdate` object is a hack as signalR messages don't always give the full game state
extension GameExt on Game {
  GameUpdate toGameUpdate() {
    return GameUpdate(
      game: this,
      curPlayerTimeSnapshot: didStart()
          ? playerTimeSnapshots[
              getStoneFromPlayerId(getPlayerIdWithTurn()!)!.index]
          : null,
      playerWithTurn:
          didStart() ? getStoneFromPlayerId(getPlayerIdWithTurn()!) : null,
    );
  }
}

extension GameUpdateExt on GameUpdate {
  Game makeCopyFromOldGame(Game game) {
    // REVIEW: this works for now,
    // but it might have some nullability issues down the line.
    // e.g. if the new game updated some value to a null value, it would be ignored by `??` operator.
    // In this case the update won't be communicated.
    var newGame = Game(
      gameId: this.game?.gameId ?? game.gameId,
      rows: this.game?.rows ?? game.rows,
      columns: this.game?.columns ?? game.columns,
      timeControl: this.game?.timeControl ?? game.timeControl,
      playgroundMap: this.game?.playgroundMap ?? game.playgroundMap,
      moves: this.game?.moves ?? game.moves,
      players: this.game?.players ?? game.players,
      prisoners: this.game?.prisoners ?? game.prisoners,
      startTime: this.game?.startTime ?? game.startTime,
      gameState: this.game?.gameState ?? game.gameState,
      deadStones: this.game?.deadStones ?? game.deadStones,
      result: this.game?.result ?? game.result,
      komi: this.game?.komi ?? game.komi,
      finalScore: this.game?.finalScore ?? game.finalScore,
      gameOverMethod: this.game?.gameOverMethod ?? game.gameOverMethod,
      endTime: this.game?.endTime ?? game.endTime,
      stoneSelectionType:
          this.game?.stoneSelectionType ?? game.stoneSelectionType,
      gameCreator: this.game?.gameCreator ?? game.gameCreator,
      playerTimeSnapshots:
          this.game?.playerTimeSnapshots ?? game.playerTimeSnapshots,
      playersRatingsAfter:
          this.game?.playersRatingsAfter ?? game.playersRatingsAfter,
      playersRatingsDiff:
          this.game?.playersRatingsDiff ?? game.playersRatingsDiff,
      gameType: this.game?.gameType ?? game.gameType,
      creationTime: this.game?.creationTime ?? game.creationTime,
      usernames: this.game?.usernames ?? game.usernames,
    );

    var tmpTimes = [...newGame.playerTimeSnapshots];

    if (playerWithTurn != null && curPlayerTimeSnapshot != null) {
      var idx = playerWithTurn!.index;
      tmpTimes[idx] = curPlayerTimeSnapshot!;
    }

    return newGame.copyWith(playerTimeSnapshots: tmpTimes);
  }
}

class GameUpdate {
  final Game? game;
  final PlayerTimeSnapshot? curPlayerTimeSnapshot;
  final StoneType? playerWithTurn;
  final Position? deadStonePosition;
  final DeadStoneState? deadStoneState;

  GameUpdate({
    this.game,
    this.curPlayerTimeSnapshot,
    this.playerWithTurn,
    this.deadStonePosition,
    this.deadStoneState,
  });

  // get state => null;
}

enum GamePlatform {
  online,
  local,
}

abstract class GameStateOracle {
  // FIXME: Controllers being here means they are easy to miss in implementation

  final StreamController<GameUpdate> gameUpdateC = StreamController.broadcast();
  Stream<GameUpdate> get gameUpdate => gameUpdateC.stream;

  final StreamController<Null> gameEndC = StreamController.broadcast();
  Stream<Null> get gameEndStream => gameEndC.stream;

  final StreamController<GameMove> moveUpdateC = StreamController.broadcast();
  Stream<GameMove> get moveUpdate => moveUpdateC.stream;

  Stream<ConnectionStrength>? get opponentConnection;

  Duration get headsUpTime;

  DisplayablePlayerData myPlayerData(Game game);
  DisplayablePlayerData? otherPlayerData(Game game);

  Future<Either<AppError, Game>> resignGame(Game game);
  Future<Either<AppError, Game>> acceptScores(Game game);
  Future<Either<AppError, Game>> continueGame(Game game);
  Future<Either<AppError, Game>> playMove(Game game, MovePosition move);
  Future<Either<AppError, Game>> editDeadStoneCluster(
      Game game, Position pos, DeadStoneState state);

  bool isThisAccountsTurn(Game game);
  StoneType thisAccountStone(Game game);

  GamePlatform getPlatform();
}
