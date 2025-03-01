import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go/models/game.dart';
import 'package:go/modules/gameplay/middleware/score_calculator.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';
import 'package:go/modules/gameplay/middleware/board_utility/cluster.dart';
import 'package:go/modules/gameplay/middleware/board_utility/stone.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/game_state/board_state_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/models/edit_dead_stone_dto.dart';

import 'package:go/models/position.dart';

class ScoreCalculationBloc extends ChangeNotifier {
  Map<Position, ValueNotifier<Area?>> areaMap = {};
  List<int> _score = [];

  Map<Position, Stone> virtualPlaygroundMap = {};
  Set<Position> removedPositions = {};
  List<Cluster> get removedClusters => removedPositions
      .map((pos) => gameBoardBloc.stoneAt(pos)!.cluster)
      .toList();

  final Api api;
  final AuthProvider authBloc;

  final GameStateBloc gameStateBloc;
  final BoardStateBloc gameBoardBloc;

  ScoreCalculationBloc({
    required this.api,
    required this.authBloc,
    required this.gameStateBloc,
    required this.gameBoardBloc,
  }) {
    setupScore();
    listenFromEditDeadStone();
  }

  void setupScore() {
    final game = gameStateBloc.game;
    final rows = game.rows;
    final cols = game.columns;

    _score = [0, 0];

    virtualPlaygroundMap =
        Map.fromEntries(gameBoardBloc.board.playgroundMap.entries);

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        areaMap[Position(i, j)] = ValueNotifier(null);
      }
    }

    for (final pos in gameStateBloc.game.deadStones) {
      removedPositions.add(pos);
    }

    calculateScore();
  }

  void calculateScore() {
    final game = gameStateBloc.game;

    final calc = ScoreCalculator(
        rows: game.rows,
        cols: game.columns,
        komi: game.komi,
        prisoners: game.prisoners,
        deadStones: gameStateBloc.game.deadStones,
        playground: Map.fromEntries(virtualPlaygroundMap.entries
            .where((e) => !removedPositions.contains(e.key))));

    // areaMap = calc.areaMap;
    calc.areaMap.forEach((key, value) {
      areaMap[key]!.value = value;
    });

    _score = calc.score;
  }

  StreamSubscription listenFromEditDeadStone() {
    return gameStateBloc.gameOracle.gameUpdate.listen((message) {
      var pos = message.deadStonePosition;
      var state = message.deadStoneState;
      if (pos != null && state != null) {
        applyDeadStones(pos, state);
        debugPrint(
          "Dead stone edited at position $pos to $state",
        );
      }
    });
  }

  void applyDeadStones(Position pos, DeadStoneState state) {
    final cluster = gameBoardBloc.stoneAt(pos)!.cluster;
    for (var pos in cluster.data) {
      if (state == DeadStoneState.Dead) {
        removedPositions.add(pos);
        virtualPlaygroundMap.remove(pos);
      } else {
        removedPositions.remove(pos);
      }
    }
    calculateScore();
    notifyListeners();
  }

  void onClickStone(Position pos) async {
    final cluster = gameBoardBloc.stoneAt(pos)!.cluster;
    if (cluster.data.any(removedPositions.contains)) {
      var res = await gameStateBloc.editDeadStone(pos, DeadStoneState.Alive);
      res.map((res) => {applyDeadStones(pos, DeadStoneState.Alive)});
    } else {
      var res = await gameStateBloc.editDeadStone(pos, DeadStoneState.Dead);
      res.map((res) => {applyDeadStones(pos, DeadStoneState.Dead)});
    }
  }

  void continueGame() {
    virtualPlaygroundMap.clear();
    removedPositions.clear();
  }
}
