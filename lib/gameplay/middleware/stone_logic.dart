import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart' as Constants;
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/stages/score_calculation_stage.dart';
import 'package:go/models/cluster.dart';
import 'package:go/models/game.dart';
import 'package:go/models/stone.dart';
import 'package:go/playfield/game_widget.dart';
import 'package:go/playfield/stone_widget.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/providers/game_board_bloc.dart';
import 'package:go/utils/player.dart';
import 'package:go/models/position.dart';

class StoneLogic {
  final int rows;
  final int cols;

  Position? get koDelete => gameBoardBloc.koDelete;

  set koDelete(Position? pos) {
    // Do nothing from now, it's set using api response
  }

  List<ValueNotifier<int>> prisoners = [ValueNotifier(0), ValueNotifier(0)];

  Stone? stoneAt(Position? pos) {
    return gameBoardBloc.stoneAt(pos);
  }

  void setStoneAt(Position pos, Stone stone) {
    gameBoardBloc.setStoneAt(pos, stone);
  }

  void removeStoneAt(Position pos) {
    gameBoardBloc.removeStoneAt(pos);
  }

  final GameBoardBloc gameBoardBloc;

  StoneLogic({
    required this.gameBoardBloc,
    required this.rows,
    required this.cols,
  });

  Cluster? getClusterFromPosition(Position pos) {
    return stoneAt(pos)?.cluster;
  }

  /// returns true if not out of bounds
  bool checkIfInsideBounds(Position pos) {
    return gameBoardBloc.checkIfInsideBounds(pos);
  }

  /* Main Stone Logic functionality */

  // --- finally update freedoms for newly inserted stone
  // Update freedom by calculating only current stones neighbor( We can increment and decrement for neighbors in this way)
  void updateFreedomsFromNewlyInsertedStone(Position position) {
    doActionOnNeighbors(position, (Position curpos, Position neighbor) {
      if ((traversed[curpos]?.contains(getClusterFromPosition(neighbor)) ??
              false) ==
          false) {
        // if( stoneAt(neighbor) == null && checkOutofBounds(neighbor))
        // {
        //   stoneAt(curpos)?.cluster.freedoms += 1;
        // }
        if (stoneAt(neighbor)?.player != stoneAt(curpos)?.player) {
          getClusterFromPosition(neighbor)?.freedoms -= 1;
          if (traversed[curpos] == null) {
            traversed[curpos] = [getClusterFromPosition(neighbor)];
          } else {
            traversed[curpos]!.add(getClusterFromPosition(neighbor));
          }
        }
      }
    });
  }

  bool checkInsertable(Position position, StoneType playerStone) {
    if (koDelete == position) {
      return false;
    }
    bool insertable = false;
    doActionOnNeighbors(
        position,
        (curpos, neighbor) => {
              if (stoneAt(neighbor) != null)
                {
                  if (!insertable)
                    {
                      if (stoneAt(neighbor)?.player == playerStone.index)
                        insertable =
                            !(getClusterFromPosition(neighbor)?.freedoms == 1)
                      else
                        insertable =
                            getClusterFromPosition(neighbor)?.freedoms == 1,
                    }
                }
              else if (checkIfInsideBounds(neighbor))
                {
                  insertable = true,
                }
            });

    return insertable;
  }

  // Update Freedom by going through all stone in cluster and counting freedom for every stone

  /* From here */
  void calculateFreedomForPosition(Position position) {
    doActionOnNeighbors(position, (Position curpos, Position neighbor) {
      if (stoneAt(neighbor) == null &&
          checkIfInsideBounds(neighbor) &&
          ((traversed[neighbor]?.contains(getClusterFromPosition(curpos)) ??
                  false) ==
              false))
      // neighbor are the possible free position here unlike recalculateFreedomsForNeighborsOfDeleted where deletedStonePosition is the free position and neighbors are possible clusters for which we will increment freedoms
      {
        stoneAt(curpos)?.cluster.freedoms += 1;
        traversed[neighbor] = [getClusterFromPosition(curpos)];
      }
    });
  }

  calculateFreedomForCluster(Cluster cluster) {
    for (var i in cluster.data) {
      calculateFreedomForPosition(i);
    }
  }
  /* to here */

  // --- Step 1
  void addAllOfNeighborToCurpos(
      Position curpos, Position? neighbor) // done on all neighbors
  {
    if (neighbor != null &&
        stoneAt(neighbor)?.player == stoneAt(curpos)?.player) {
      // If neighbor isn't null and both neighbor and curpos both have same color
      for (var i in getClusterFromPosition(neighbor)!.data) {
        // add all of neighbors Position to cluster of curpos
        stoneAt(curpos)?.cluster.data.add(i);
      }
    }
  }

  void updateAllInTheClusterWithCorrectCluster(Cluster correctCluster) {
    for (var i in correctCluster.data) {
      setStoneAt(i, stoneAt(i)!.copyWith(cluster: correctCluster));
    }
  }
  // Step 1 ---

  // --- Deletion
  // Traversed key gives the empty freedom point position and value is the list of cluster that has recieved freedom from that point
  Map<Position?, List<Cluster?>?> traversed = {
    null: null
  }; // TODO: Find a way to do this without making this data member
  deleteStonesInDeletableCluster(Position curpos, Position neighbor) {
    if (stoneAt(neighbor)?.player != stoneAt(curpos)?.player &&
        stoneAt(neighbor)?.cluster.freedoms == 1) {
      for (var i in getClusterFromPosition(neighbor)!.data) {
        // This supposedly works because a
        // position where delete occurs in such a way that ko is possible
        // the cluster at that position can only have one member because
        // all the neighboring ones have to opposite ones for ko to be possible

        // how do we solve the behaviour when neighboring cells will be null

        // we store in koDelete The position that was deleted
        // we check that against newly entered stone and stone can only be deleted when neighboring cells will be opposite
        //

        if (getClusterFromPosition(i)!.data.length == 1) {
          koDelete = neighbor;
        }

        // prisoners[Constants.playerColors.indexWhere(
        //         (element) => element != stoneAt(i)?.value?.color)]
        //     .value += 1;

        prisoners[1 - stoneAt(i)!.player].value += 1;
        removeStoneAt(i);

        recalculateFreedomsForNeighborsOfDeleted(i);
      }
    }
  }

  recalculateFreedomsForNeighborsOfDeleted(Position deletedStonePosition) {
    // If a deleted position( free position ) has already contributed to the freedoms of a cluster it should not contribute again as that will result in duplication
    // A list of clusters is stored to keep track of what cluster has recieved freedoms points one free position can't give two freedoms to one cluster
    // but it can give freedom to different cluster
    doActionOnNeighbors(deletedStonePosition,
        (Position curpos, Position neighbor) {
      if (traversed.containsKey(curpos) == false) {
        traversed[curpos] = [null];
        // :assert(traversed[curpos]!.contains(getClusterFromPosition(neighbor)));
      }
      if ((traversed[curpos]?.contains(getClusterFromPosition(neighbor)) ??
              false) ==
          false) {
        getClusterFromPosition(neighbor)?.freedoms += 1;
        traversed[curpos]?.add(getClusterFromPosition(neighbor));
        assert(traversed[curpos]!.contains(getClusterFromPosition(neighbor)));
      }
    });
  }

  // Deletion ---

  bool handleStoneUpdate(Position? position, int playerTurn, StoneType stone) {
    if (position == null) {
      return true;
    }

    Position? thisCurrentCell = position;

    if (checkInsertable(position, stone)) {
      final currentCluster = Cluster({position}, {}, 0, playerTurn);

      setStoneAt(
        thisCurrentCell,
        Stone(
          position: position,
          player: playerTurn,
          cluster: currentCluster,
        ),
      );

      // if stone can be inserted at this position
      koDelete = null;
      doActionOnNeighbors(position, addAllOfNeighborToCurpos);
      updateAllInTheClusterWithCorrectCluster(currentCluster);
      doActionOnNeighbors(position, deleteStonesInDeletableCluster);
      calculateFreedomForCluster(currentCluster);
      updateFreedomsFromNewlyInsertedStone(position);
      traversed.clear();

      return true;
    }

    return false;
  }

  static doActionOnNeighbors(Position thisCell,
      Function(Position curPos, Position neighbor) doAction) {
    var rowPlusOne = Position(thisCell.x + 1, thisCell.y);
    doAction(thisCell, rowPlusOne);
    var rowMinusOne = Position(thisCell.x - 1, thisCell.y);
    doAction(thisCell, rowMinusOne);
    var colPlusOne = Position(thisCell.x, thisCell.y + 1);
    doAction(thisCell, colPlusOne);
    var colMinusOne = Position(thisCell.x, thisCell.y - 1);
    doAction(thisCell, colMinusOne);
  }

  // Scoring

  // Extend outward by checking all neighbors approach
}

class Area {
  Set<Position?> spaces = {};
  // int value;
  int get value => spaces.length;
  int? owner;
  bool isDame;
  Area.from(this.isDame, this.owner);
  Area()
      : isDame = false,
        owner = null;
}



  // Failed approach in this i started from 0 0 and went horizontaly till end then next row and so on
/* calculateFinalScore() {
    // REPRESENTATION
    // * -> white stone
    // # -> black stone
    // 0 -> emtpy

    // DATA
    // list of allAreas
    // map of positions with areas /* WE CAN IGNORE THE POSITIONS WITH STONES AND ONLY ENTER EMPTY POSITIONs

    // STEP 1
    // There will be a list of areas -> allAreas
    // we start from first and move in one direction let A
    // at start we put the first empty group of places in curArea and push it in allAreas
    // encountering a stone we terminate the curArea for this iteration in this direction and if(curArea.owner == null and !isDame) put color of the stone in curArea.color
    // else if curArea.color = someone then check if that someone is equal to the stone.color we encountered if false isDame = true, owner = null

    // encountering empty place next curArea will start from that place
    // and next element will be pushed in allAreas in next index
    // and so on
    // STEP 2
    // start from first index of this iteration
    // for any empty area found we will look immediately up and if that place is empty put cur place into area at that place and set that area to curArea

    // for case like * 0 0 0 *
    //               * 0 * * *
    // this will work

    // for : * 0 0 0 * 2
    //       0 0 * * * 1
    //       A B C D E

    // this wont work because stone at A1 wouldn't get updated
    // so start moving back one by one until you reach a stone or bounds and put into every place curArea

    // calculate like this till end

    //AREA {
    /* value amount of stones */
    /* isDame bool if dame*/
    /* owner -> Player */
    //}

    Map<Position, Area> areaMap = {Position(0, 0): Area()};
    List<Area> result;

    Area? curArea = areaMap[Position(0, 0)];
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        // if curArea doesn't have an owner and isn't dame and is empty place then update owner

        if (playground_Map[Position(i, j)]!.value == null) {
          curArea = areaMap[Position(i - 1, j)] ?? curArea ?? Area();
          curArea?.value += 1;
          curArea.spaces.add(Position(i, j));
          areaMap[Position(i, j)] = curArea!;
          updateOwnerWhenReachingNewEmptyArea(areaMap, i, j);
          if (playground_Map[Position(i, j - 1)]?.value == null && areaMap[Position(i, j - 1)] != curArea) {
            for (int k = j - 1; k >= 0 && playground_Map[Position(i, k)]!.value == null; k--) {
              curArea?.value += 1;
              curArea.spaces.add(Position(i, k));
              areaMap[Position(i, k)] = curArea;
            }
          }
        } else {
          curArea = curArea ?? Area();
          updateOwnerWhenExitingEmptyArea(areaMap, i, j);
          // Check if next place bounding stone has color other than than the current area's owner
          if (curArea?.owner != null &&
              curArea?.owner != playground_Map[Position(i, j)]?.value?.color &&
              playground_Map[Position(i, j)]?.value?.color != null) {
            curArea?.isDame = true;
            curArea?.owner = null;
            curArea = null;
          }
          curArea = null;
        }
      }
      curArea = null;
    }
    return areaMap;
  }

  bool updateOwnerWhenExitingEmptyArea(Map<Position, Area> areaMap, int i, int j) {
    if (!checkIfInsideBounds(Position(i, j))) {
      return false;
    }
    if (areaMap[Position(i, j - 1)] == null) {
      return false;
    }
    if (areaMap[Position(i, j - 1)]?.owner == null && !areaMap[Position(i, j - 1)]!.isDame && playground_Map[Position(i, j)]!.value != null) {
      areaMap[Position(i, j - 1)]?.owner = playground_Map[Position(i, j)]?.value?.color;
      return true;
    } else {
      return false;
    }
  }

  bool updateOwnerWhenReachingNewEmptyArea(Map<Position, Area> areaMap, int i, int j) {
    if (!checkIfInsideBounds(Position(i, j - 1))) {
      return false;
    }
    if (areaMap[Position(i, j)] == null) {
      return false;
    }
    if (areaMap[Position(i, j)]?.owner == null && !areaMap[Position(i, j)]!.isDame && playground_Map[Position(i, j - 1)]!.value != null) {
      areaMap[Position(i, j)]?.owner = playground_Map[Position(i, j - 1)]?.value?.color;
      return true;
    } else {
      return false;
    }
  }  
*/ */