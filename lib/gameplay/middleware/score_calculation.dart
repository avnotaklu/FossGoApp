import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go/constants/constants.dart';
import 'package:go/gameplay/create/create_game.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/game_end_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/models/cluster.dart';
import 'package:go/models/stone.dart';
import 'package:go/playfield/stone_widget.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/utils/player.dart';
import 'package:go/models/position.dart';
import 'package:go/constants/constants.dart' as Constants;
import 'package:provider/provider.dart';

import '../../models/position.dart';
import 'stone_logic.dart';

class ScoreCalculation extends InheritedWidget {
  final Map<Position, ValueNotifier<Area?>> areaMap = {};
  final List<Cluster> clusterEncountered = [];
  List<int> _territoryScores = [];

  // Map<int,bool>
  List<int> stoneRemovalAccepted = [];

  // BuildContext? _context;
  Map<Position, Stone> virtualPlaygroundMap = {};
  Set<Cluster> virtualRemovedCluster = {};
  final GameStateBloc gameStateBloc;

  Player getWinner(BuildContext context) {
    gameStateBloc.getPlayerWithTurn.score =
        _territoryScores[gameStateBloc.getPlayerWithTurn.turn] +
            StoneLogic.of(context)!
                .prisoners[gameStateBloc.getPlayerWithTurn.turn]
                .value +
            (playerColors[gameStateBloc.getPlayerWithTurn.turn] == Colors.white
                ? 6.5
                : 0);
    gameStateBloc.getPlayerWithoutTurn.score =
        _territoryScores[gameStateBloc.getPlayerWithoutTurn.turn] +
            StoneLogic.of(context)!
                .prisoners[gameStateBloc.getPlayerWithoutTurn.turn]
                .value +
            (playerColors[gameStateBloc.getPlayerWithoutTurn.turn] ==
                    Colors.white
                ? 6.5
                : 0);
    Player winner = (gameStateBloc.getPlayerWithTurn.score >
            gameStateBloc.getPlayerWithoutTurn.score)
        ? gameStateBloc.getPlayerWithTurn
        : gameStateBloc.getPlayerWithoutTurn;
    return winner;
  }

  // GETTERS
  List<int> scores(context) {
    if (_territoryScores.isNotEmpty) return _territoryScores;
    calculateScore(context);
    return _territoryScores;
  }

  ScoreCalculation(
    rows,
    cols, {
    required this.gameStateBloc,
    required Widget mChild,
  }) : super(child: mChild) {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        areaMap[Position(i, j)] = ValueNotifier(null);
      }
    }
  }

  onGameEnd(GameStateBloc gameState, removedCluster) {
    if (stoneRemovalAccepted.length == 2) {
      gameState.cur_stage_type = StageType.GameEnd;
      gameState.endGame();
    }
  }

  calculateScore(StoneLogic stoneLogic) {
    clusterEncountered.clear();

    for (int i = 0; i < stoneLogic.rows; i++) {
      for (int j = 0; j < stoneLogic.cols; j++) {
        areaMap[Position(i, j)]!.value = null;
        // TODO: for now entire areaMap is updated so each value notifier listens even if it doesn't need to change use a tmp areaMap and update only the values that are required
      }
    }

    virtualPlaygroundMap = Map.from(
        stoneLogic.playgroundMap.map((key, value) => MapEntry(key, value)));
    for (Cluster cluster in virtualRemovedCluster) {
      for (var pos in cluster.data) {
        virtualPlaygroundMap.remove(pos);
      }
    }

    // const Position startPos = Position(0, 0);
    // List<Area> result = [];

    // Area? startArea = Area();
    // startArea.spaces.add(startPos);
    // areaMap[startPos] = startArea;

    // result.add(startArea);
    // forEachEmptyArea(startPos, startArea);

    // Iterate map with clusters
    // Map<Cluster, bool> markDoneCluster = {};

    // while (clusterEncountered.isNotEmpty) {
    //   var cluster = clusterEncountered.first;

    //   if (markDoneCluster[cluster] == false || markDoneCluster.containsKey(cluster) == false) {
    //     for (Position pos in cluster.data) {
    //       StoneLogic.doActionOnNeighbors(pos, (curPos, neighbor) {
    //         if (areaMap[neighbor] == null) {
    //           forEachEmptyArea(neighbor, Area());
    //         }
    //       });
    //     }
    //   }

    //   markDoneCluster[cluster] = true;
    //   clusterEncountered.removeAt(0);
    // }

    // iterate map starting from 0 0 to last

    for (int i = 0; i < stoneLogic.rows; i++) {
      for (int j = 0; j < stoneLogic.rows; j++) {
        if (areaMap[Position(i, j)]!.value == null &&
            virtualPlaygroundMap[Position(i, j)] == null) {
          forEachEmptyArea(Position(i, j), Area(), stoneLogic);
        }
      }
    }
    _territoryScores = [0, 0];
    // print(startArea);
    areaMap.forEach((key, value) {
      if (value.value?.owner != null) {
        _territoryScores[Constants.playerColors
            .indexWhere((element) => element == value.value?.owner)] += 1;
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

  forEachEmptyArea(Position startPos, Area curArea, StoneLogic stoneLogic) {
    if (stoneLogic.checkIfInsideBounds(startPos)) {
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
        if (stoneLogic.checkIfInsideBounds(neighbor) &&
            stoneLogic.checkIfInsideBounds(curPos)) {
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
                forEachEmptyArea(neighbor, curArea, stoneLogic);
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

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

  static ScoreCalculation? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ScoreCalculation>();
}
