import 'dart:async';

import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go/constants/constants.dart';
import 'package:go/gameplay/create/create_game_screen.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/game_end_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/models/cluster.dart';
import 'package:go/models/stone.dart';
import 'package:go/playfield/stone_widget.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/providers/game_board_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/services/auth_provider.dart';
import 'package:go/services/edit_dead_stone_dto.dart';
import 'package:go/utils/player.dart';
import 'package:go/models/position.dart';
import 'package:go/constants/constants.dart' as Constants;
import 'package:provider/provider.dart';

import '../../models/position.dart';
import 'stone_logic.dart';

class ScoreCalculationBloc extends ChangeNotifier {
  final Map<Position, ValueNotifier<Area?>> areaMap = {};
  // final List<Cluster> clusterEncountered = [];
  List<int> _territoryScores = [];

  // BuildContext? _context;
  Map<Position, Stone> virtualPlaygroundMap = {};
  Set<Cluster> virtualRemovedCluster = {};

  final Api api;
  final AuthProvider authBloc;

  final GameStateBloc gameStateBloc;
  final GameBoardBloc gameBoardBloc;

  // GETTERS
  List<int> scores(context) {
    if (_territoryScores.isNotEmpty) return _territoryScores;
    calculateScore();
    return _territoryScores;
  }

  late final StreamSubscription editStoneSubscription;

  ScoreCalculationBloc({
    required this.api,
    required this.authBloc,
    required this.gameStateBloc,
    required this.gameBoardBloc,
  }) {
    editStoneSubscription = listenFromEditDeadStone();
    setupScore();
  }

  void setupScore() {
    final game = gameStateBloc.game;
    final rows = game.rows;
    final cols = game.columns;

    _territoryScores = [0, 0];

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        areaMap[Position(i, j)] = ValueNotifier(null);
      }
    }

    for (final pos in gameStateBloc.game.deadStones) {
      virtualRemovedCluster.add(gameBoardBloc.stoneAt(pos)!.cluster);
    }

    calculateScore();
  }

  @override
  void dispose() {
    editStoneSubscription.cancel();
  }

  void addDeadStones(Position pos) async {
    final token = authBloc.token!;
    final res = await api.editDeadStoneCluster(
      EditDeadStoneClusterDto(position: pos, state: DeadStoneState.Dead),
      token,
      gameStateBloc.game.gameId,
    );

    res.fold((e) {}, (r) {
      applyDeadStones(pos, DeadStoneState.Dead);
    });
  }

  void removeDeadStones(Position pos) async {
    final token = authBloc.token!;
    final res = await api.editDeadStoneCluster(
      EditDeadStoneClusterDto(position: pos, state: DeadStoneState.Alive),
      token,
      gameStateBloc.game.gameId,
    );
    res.fold((e) {}, (r) {
      applyDeadStones(pos, DeadStoneState.Alive);
    });
  }

  void applyDeadStones(Position pos, DeadStoneState state) {
    final cluster = gameBoardBloc.stoneAt(pos)!.cluster;
    if (state == DeadStoneState.Dead) {
      virtualRemovedCluster.add(cluster);
    } else {
      virtualRemovedCluster.remove(cluster);
    }
    calculateScore();
    notifyListeners();
  }

  StreamSubscription listenFromEditDeadStone() {
    return gameStateBloc.listenForEditDeadStone.listen((message) {
      applyDeadStones(message.position, message.state);
      debugPrint(
        "Dead stone edited at position ${message.position} to ${message.state}",
      );
    });
  }

  void onClickStone(Position pos) {
    final cluster = gameBoardBloc.stoneAt(pos)!.cluster;
    if (virtualRemovedCluster.contains(cluster)) {
      removeDeadStones(pos);
    } else {
      addDeadStones(pos);
    }
  }

  onGameEnd(GameStateBloc gameState, removedCluster) {
    // if (stoneRemovalAccepted.length == 2) {
    //   gameState.curStageType = StageType.GameEnd;
    //   gameState.endGame();
    // }
  }

  void continueGame() {
    virtualPlaygroundMap.clear();
    virtualRemovedCluster.clear();
  }

  createVirtualPlayground() {
    virtualPlaygroundMap.clear();
    virtualPlaygroundMap.addAll(gameBoardBloc.stones);

    for (Cluster cluster in virtualRemovedCluster) {
      for (var pos in cluster.data) {
        virtualPlaygroundMap.remove(pos);
      }
    }
  }

  calculateScore() {
    for (int i = 0; i < gameBoardBloc.rows; i++) {
      for (int j = 0; j < gameBoardBloc.cols; j++) {
        areaMap[Position(i, j)]!.value = null;
        // TODO: for now entire areaMap is updated so each value notifier listens even if it doesn't need to change use a tmp areaMap and update only the values that are required
      }
    }

    createVirtualPlayground();

    for (int i = 0; i < gameBoardBloc.rows; i++) {
      for (int j = 0; j < gameBoardBloc.rows; j++) {
        if (areaMap[Position(i, j)]!.value == null &&
            virtualPlaygroundMap[Position(i, j)] == null) {
          forEachEmptyArea(Position(i, j), Area(), []);
        }
      }
    }
    _territoryScores = [0, 0];
    // print(startArea);
    areaMap.forEach((key, value) {
      if (value.value?.owner != null) {
        // _territoryScores[Constants.playerColors
        //     .indexWhere((element) => element == value.value?.owner)] += 1;

        _territoryScores[value.value!.owner!] += 1;
      }
    });

    return areaMap;

    // if this area neighbor is stone , owner is null and not dame then assign neighbor's color as the owner of this area

    // if neighbor is filled then check if owner of this area equal to neighbor
    // if yes then do nothing just move forward
    // if any of the neighbor is different then current owner, then this area is dame and owner is null

    // NOTE: // don't do action on neighbor for filled curPos

    // add this area to current area if this is empty
    // when no more empty places can be reached set curArea to null

    // if not then add this
  }

  forEachEmptyArea(
      Position startPos, Area curArea, List<Cluster> clusterEncountered) {
    if (gameBoardBloc.checkIfInsideBounds(startPos)) {
      if (virtualPlaygroundMap[startPos] != null) {
        if (!clusterEncountered
            .contains(virtualPlaygroundMap[startPos]!.cluster)) {
          // TODO: idk if it is possible to visit a stone at curpos without having it in cluster
          // so maybe this can be removed only cases i can think of is the first stone in which it maybe doesn't matter if we include it's cluster
          clusterEncountered.add(virtualPlaygroundMap[startPos]!.cluster);
          return;
        }
      }
      StoneLogic.doActionOnNeighbors(startPos, (curPos, neighbor) {
        if (gameBoardBloc.checkIfInsideBounds(neighbor) &&
            gameBoardBloc.checkIfInsideBounds(curPos)) {
          // TODO: maybe check if inside bounds is not necessary for curpos
          if (!curArea.spaces.contains(curPos) &&
              virtualPlaygroundMap[curPos] == null) {
            curArea.spaces.add(curPos);
            areaMap[curPos]!.value = curArea;
          }
          if (areaMap[neighbor]!.value == null) {
            if (virtualPlaygroundMap[neighbor] == null) {
              if (curArea.spaces.contains(neighbor) == false) {
                // if () {
                curArea.spaces.add(neighbor);
                areaMap[neighbor]!.value = curArea;
                forEachEmptyArea(neighbor, curArea, clusterEncountered);
                //}
              }
            }
            if (virtualPlaygroundMap[neighbor]?.player != null) {
              if (!clusterEncountered
                  .contains(virtualPlaygroundMap[neighbor]!.cluster)) {
                clusterEncountered.add(virtualPlaygroundMap[neighbor]!.cluster);
              }

              if (curArea.owner == null && !curArea.isDame) {
                curArea.owner = virtualPlaygroundMap[neighbor]?.player;
              } else if (curArea.owner != null &&
                  virtualPlaygroundMap[neighbor]?.player != curArea.owner) {
                curArea.owner = null;
                curArea.isDame = true;
              }
            }
          }
        }
      });
    }
  }
}
