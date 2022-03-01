import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:flutter/widgets.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/game_end_stage.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/utils/position.dart';
import 'package:go/constants/constants.dart' as Constants;

import '../../utils/position.dart';
import 'stone_logic.dart';

class ScoreCalculation extends InheritedWidget {
  final Map<Position, ValueNotifier<Area?>> areaMap = {};
  final List<Cluster> clusterEncountered = [];
  List<int> _scores = [];

  // Map<int,bool>
  List<int> stoneRemovalAccepted = [];

  BuildContext? _context;
  Map<Position, Stone?> virtualPlaygroundMap = {};
  Set<Cluster> virtualRemovedCluster = {};

  // GETTERS
  List<int> scores(context) {
    if (_scores.isNotEmpty) return _scores;
    calculateScore(context);
    return _scores;
  }

  ScoreCalculation(rows, cols, {required Widget mChild}) : super(child: mChild) {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        areaMap[Position(i, j)] = ValueNotifier(null);
      }
    }
  }

  onGameEnd(context, removedCluster) {
    if (stoneRemovalAccepted.length == 2) {
      GameData.of(context)!.cur_stage = GameEndStage(context);
      MultiplayerData.of(context)!.curGameReferences!.runStatus.set(false);
    }
  }

  calculateScore(BuildContext context) {
    _context = context;
    clusterEncountered.clear();

    for (int i = 0; i < StoneLogic.of(context)!.rows; i++) {
      for (int j = 0; j < StoneLogic.of(context)!.cols; j++) {
        areaMap[Position(i, j)]!.value = null;
        // TODO: for now entire areaMap is updated so each value notifier listens even if it doesn't need to change use a tmp areaMap and update only the values that are required
      }
    }

    virtualPlaygroundMap = Map.from(StoneLogic.of(context)!.playground_Map.map((key, value) => MapEntry(key, value.value)));
    for (Cluster cluster in virtualRemovedCluster) {
      for (var pos in cluster.data) {
        virtualPlaygroundMap[pos] = null;
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

    for (int i = 0; i < StoneLogic.of(context)!.rows; i++) {
      for (int j = 0; j < StoneLogic.of(context)!.rows; j++) {
        if (areaMap[Position(i, j)]!.value == null && virtualPlaygroundMap[Position(i, j)] == null) {
          forEachEmptyArea(Position(i, j), Area());
        }
      }
    }
    _scores = [0, 0];
    // print(startArea);
    areaMap.forEach((key, value) {
      if (value.value?.owner != null) {
        _scores[Constants.playerColors.indexWhere((element) => element == value.value?.owner)] += 1;
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

  forEachEmptyArea(Position startPos, Area curArea) {
    if (StoneLogic.of(_context!)!.checkIfInsideBounds(startPos)) {
      if (virtualPlaygroundMap[startPos]?.color != null) {
        if (!clusterEncountered.contains(virtualPlaygroundMap[startPos]!.cluster)) {
          // TODO: idk if it is possible to visit a stone at curpos without having it in cluster
          // so maybe this can be removed only cases i can think of is the first stone in which it maybe doesn't matter if we include it's cluster
          clusterEncountered.add(virtualPlaygroundMap[startPos]!.cluster);
          return;
        }
      }
      StoneLogic.doActionOnNeighbors(startPos, (curPos, neighbor) {
        if (StoneLogic.of(_context!)!.checkIfInsideBounds(neighbor) && StoneLogic.of(_context!)!.checkIfInsideBounds(curPos)) {
          // TODO: maybe check if inside bounds is not necessary for curpos
          if (!curArea.spaces.contains(curPos) && virtualPlaygroundMap[curPos] == null) {
            curArea.spaces.add(curPos);
            areaMap[curPos]!.value = curArea;
          }
          if (areaMap[neighbor]!.value == null) {
            if (virtualPlaygroundMap[neighbor] == null) {
              if (curArea.spaces.contains(neighbor) == false) {
                // if () {
                curArea.spaces.add(neighbor);
                areaMap[neighbor]!.value = curArea;
                forEachEmptyArea(neighbor, curArea);
                //}
              }
            }
            if (virtualPlaygroundMap[neighbor]?.color != null) {
              if (!clusterEncountered.contains(virtualPlaygroundMap[neighbor]!.cluster)) {
                clusterEncountered.add(virtualPlaygroundMap[neighbor]!.cluster);
              }

              if (curArea.owner == null && !curArea.isDame) {
                curArea.owner = virtualPlaygroundMap[neighbor]?.color;
              } else if (curArea.owner != null && virtualPlaygroundMap[neighbor]?.color != curArea.owner) {
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

  static ScoreCalculation? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ScoreCalculation>();
}
