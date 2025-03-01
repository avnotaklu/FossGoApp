// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/modules/gameplay/game_state/game_entrance_data.dart';
import 'package:go/modules/gameplay/game_state/oracle/game_state_oracle.dart';
import 'package:go/modules/gameplay/middleware/local_gameplay_server.dart';
import 'package:go/modules/gameplay/middleware/score_calculator.dart';
import 'package:go/modules/gameplay/middleware/time_calculator.dart';
import 'package:go/models/time_control.dart';
import 'package:go/modules/gameplay/middleware/board_utility/board_utilities.dart';
import 'package:go/modules/stats/stats_repository.dart';
import 'package:go/models/game_and_opponent.dart';
import 'package:go/models/user_account.dart';
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
import 'package:go/models/edit_dead_stone_dto.dart';
import 'package:go/models/game_over_message.dart';
import 'package:go/models/move_position.dart';
import 'package:go/models/public_user_info.dart';
import 'package:go/models/signal_r_message.dart';
import 'package:go/models/player_rating.dart';

// This assumes the game is already started at time of creation
// This assumes the two player's ids are "bottom" and "top"

class FaceToFaceGameOracle extends GameStateOracle {
  final LocalGameplayServer gp;

  @override
  Stream<ConnectionStrength>? get opponentConnection => null;

  FaceToFaceGameOracle(this.gp) {
    gameUpdateC.addStream(gp.gameUpdate);
    gp.gameUpdate.listen((d) {
      if (d.game?.gameState == GameState.ended) {
        gameEndC.add(null);
        // NOTE: After end there are no other updates, so this will happen once only
      }
    });
  }

  String get myPlayerId => "bottom";
  String get otherPlayerId => "top";

  @override
  Duration get headsUpTime => Duration.zero;

  @override
  DisplayablePlayerData myPlayerData(Game game) {
    StoneType stone = game.getStoneFromPlayerId(myPlayerId)!;

    return DisplayablePlayerData(
      waiting: false,
      displayName: stone.color,
      stoneType: stone,
      rating: null, // No rating for face to face games
      ratingDiffOnEnd: null,
      komi: stone.komi(game),
      prisoners: stone.prisoners(game),
      score: stone.score(game),
    );
  }

  @override
  DisplayablePlayerData otherPlayerData(Game game) {
    StoneType stone = game.getStoneFromPlayerId(otherPlayerId)!;

    return DisplayablePlayerData(
      waiting: false,
      displayName: stone.color,
      stoneType: stone,
      rating: null, // No rating for face to face games
      ratingDiffOnEnd: null,
      komi: stone.komi(game),
      prisoners: stone.prisoners(game),
      score: stone.score(game),
    );
  }

  @override
  Future<Either<AppError, Game>> resignGame(Game game) async {
    return gp.resignGame(thisAccountStone(game));
  }

  @override
  Future<Either<AppError, Game>> acceptScores(Game game) async {
    return gp.acceptScores(thisAccountStone(game));
  }

  @override
  Future<Either<AppError, Game>> continueGame(Game game) async {
    return gp.continueGame();
  }

  @override
  Future<Either<AppError, Game>> playMove(Game game, MovePosition move) async {
    var newGame = gp.makeMove(move, thisAccountStone(game));

    newGame.fold(identity, (r) {
      moveUpdateC.add((r.moves.last, r.moves.length - 1));
    });

    return newGame;
  }

  Future<Either<AppError, Game>> editDeadStoneCluster(
      Game game, Position pos, DeadStoneState state) async {
    return gp.editDeadStone(thisAccountStone(game), pos, state);
  }

  @override
  bool isThisAccountsTurn(Game game) {
    return true;
  }

  @override
  StoneType thisAccountStone(Game game) {
    return game.getStoneFromPlayerId(game.getPlayerIdWithTurn()!)!;
  }

  @override
  GamePlatform getPlatform() {
    return GamePlatform.local;
  }
}
