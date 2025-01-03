// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:go/modules/gameplay/middleware/board_utility/cluster.dart';
import 'package:go/models/game.dart';
import 'package:go/models/position.dart';
import 'package:go/modules/gameplay/middleware/board_utility/stone.dart';
import 'package:go/modules/gameplay/middleware/board_utility/board_utilities.dart';

class StoneLogic {
  BoardState board;
  final List<HighLevelBoardRepresentation> _prevBoardStates = [];

  StoneLogic(Game game)
      : this.fromBoardState(BoardStateUtilities(game.rows, game.columns)
            .boardStateFromGame(game));

  StoneLogic.fromBoardState(this.board) {
    _prevBoardStates.add(board.playgroundMap.toHighLevelBoardRepresentation());
  }

  StoneLogic.complete(
      this.board, List<HighLevelBoardRepresentation> prevBoardStates) {
    for (var st in prevBoardStates) {
      _prevBoardStates.add(st);
    }
  }

  StoneLogic deepCopy() {
    return StoneLogic.complete(
        board.copyWith(
          playgroundMap: Map.fromEntries(
            board.playgroundMap.entries.map(
              (e) => MapEntry(
                e.key,
                e.value.deepCopy(),
              ),
            ),
          ),
        ),
        _prevBoardStates);
  }

  void _setBoardState(BoardState board) {
    this.board = board;
  }

  Stone? _stoneAt(Position pos) {
    return board.playgroundMap[pos];
  }

  Stone? rawStoneAt(Position pos) {
    return _stoneAt(pos);
  }

  StoneType? stoneAt(Position pos) {
    return _stoneAt(pos)?.toStoneType();
  }

  void _setStoneAt(Position pos, Stone stone) {
    board.playgroundMap[pos] = stone;
  }

  Cluster? _getClusterFromPosition(Position pos) {
    return _stoneAt(pos)?.cluster;
  }

  /// returns true if not out of bounds
  bool _checkIfInsideBounds(Position pos) {
    return pos.x > -1 && pos.x < board.rows && pos.y < board.cols && pos.y > -1;
  }

  /* Main Stone Logic functionality */

  /// --- finally update freedoms for newly inserted stone
  ///
  /// Update freedom by calculating only current stones neighbor( We can increment and decrement for neighbors in this way)
  void _updateFreedomsFromNewlyInsertedStone(Position position) {
    doActionOnNeighbors(position, (Position curpos, Position neighbor) {
      if ((traversed[curpos]?.contains(_getClusterFromPosition(neighbor)) ??
              false) ==
          false) {
        if (_stoneAt(neighbor)?.player != _stoneAt(curpos)?.player) {
          _getClusterFromPosition(neighbor)?.freedoms -= 1;
          if (traversed[curpos] == null) {
            traversed[curpos] = [_getClusterFromPosition(neighbor)];
          } else {
            traversed[curpos]!.add(_getClusterFromPosition(neighbor));
          }
        }
      }
    });
  }

  bool checkInsertable(Position position, StoneType playerStone) {
    if (_stoneAt(position) != null) return false;

    bool insertable = false;
    doActionOnNeighbors(position, (curpos, neighbor) {
      if (_stoneAt(neighbor) != null) {
        if (!insertable) {
          if (_stoneAt(neighbor)?.player == playerStone.index) {
            insertable = !(_getClusterFromPosition(neighbor)?.freedoms == 1);
          } else {
            insertable = _getClusterFromPosition(neighbor)?.freedoms == 1;
          }
        }
      } else if (_checkIfInsideBounds(neighbor)) {
        insertable = true;
      }
    });

    return insertable;
  }

  // Update Freedom by going through all stone in cluster and counting freedom for every stone

  /* From here */
  void _calculateFreedomForPosition(Position position) {
    doActionOnNeighbors(position, (Position curpos, Position neighbor) {
      if (_stoneAt(neighbor) == null &&
          _checkIfInsideBounds(neighbor) &&
          ((traversed[neighbor]?.contains(_getClusterFromPosition(curpos)) ??
                  false) ==
              false))
      // neighbor are the possible free position here unlike recalculateFreedomsForNeighborsOfDeleted where deletedStonePosition is the free position and neighbors are possible clusters for which we will increment freedoms
      {
        _stoneAt(curpos)?.cluster.freedoms += 1;
        traversed[neighbor] = [_getClusterFromPosition(curpos)];
      }
    });
  }

  void _calculateFreedomForCluster(Cluster cluster) {
    for (var i in cluster.data) {
      _calculateFreedomForPosition(i);
    }
  }
  /* to here */

  // --- Step 1
  void _addAllOfNeighborToCurpos(
      Position curpos, Position? neighbor) // done on all neighbors
  {
    if (neighbor != null &&
        _stoneAt(neighbor)?.player == _stoneAt(curpos)?.player) {
      // If neighbor isn't null and both neighbor and curpos both have same color
      for (var i in _getClusterFromPosition(neighbor)!.data) {
        // add all of neighbors Position to cluster of curpos
        _stoneAt(curpos)?.cluster.data.add(i);
      }
    }
  }

  void _updateAllInTheClusterWithCorrectCluster(Cluster correctCluster) {
    for (var i in correctCluster.data) {
      _setStoneAt(i, _stoneAt(i)!.copyWith(cluster: correctCluster));
    }
  }
  // Step 1 ---

  // --- Deletion
  // Traversed key gives the empty freedom point position and value is the list of cluster that has recieved freedom from that point
  Map<Position?, List<Cluster?>?> traversed = {
    null: null
  }; // REVIEW: should i do this using recursion

  void _deleteStonesInDeletableCluster(Position curpos, Position neighbor) {
    if (_stoneAt(neighbor)?.player != _stoneAt(curpos)?.player &&
        _stoneAt(neighbor)?.cluster.freedoms == 1) {
      for (var i in _getClusterFromPosition(neighbor)!.data) {
        board.prisoners[1 - _stoneAt(i)!.player] += 1;
        board.playgroundMap.remove(i);

        _recalculateFreedomsForNeighborsOfDeleted(i);
      }
    }
  }

  void _recalculateFreedomsForNeighborsOfDeleted(
      Position deletedStonePosition) {
    // If a deleted position( free position ) has already contributed to the freedoms of a cluster it should not contribute again as that will result in duplication
    // A list of clusters is stored to keep track of what cluster has recieved freedoms points one free position can't give two freedoms to one cluster
    // but it can give freedom to different cluster
    doActionOnNeighbors(deletedStonePosition,
        (Position curpos, Position neighbor) {
      if (traversed.containsKey(curpos) == false) {
        traversed[curpos] = [null];
        // :assert(traversed[curpos]!.contains(getClusterFromPosition(neighbor)));
      }
      if ((traversed[curpos]?.contains(_getClusterFromPosition(neighbor)) ??
              false) ==
          false) {
        _getClusterFromPosition(neighbor)?.freedoms += 1;
        traversed[curpos]?.add(_getClusterFromPosition(neighbor));
        assert(traversed[curpos]!.contains(_getClusterFromPosition(neighbor)));
      }
    });
  }

  // Deletion ---

  ({bool result, BoardState board}) handleStoneUpdate(
      Position? position, StoneType stone) {
    // REVIEW: This is stone update, and it handles passes as well
    if (position == null) {
      return (result: true, board: board);
    }

    Position? thisCurrentCell = position;

    var lastValid = board.copyWith(
      playgroundMap: Map.fromEntries(board.playgroundMap.entries),
    );

    if (checkInsertable(position, stone)) {
      final currentCluster = Cluster({position}, {}, 0, stone.index);

      _setStoneAt(
        thisCurrentCell,
        Stone(
          position: position,
          player: stone.index,
          cluster: currentCluster,
        ),
      );

      // if stone can be inserted at this position
      _setBoardState(board);
      doActionOnNeighbors(position, _addAllOfNeighborToCurpos);
      _updateAllInTheClusterWithCorrectCluster(currentCluster);
      doActionOnNeighbors(position, _deleteStonesInDeletableCluster);
      _calculateFreedomForCluster(currentCluster);
      _updateFreedomsFromNewlyInsertedStone(position);
      traversed.clear();

      if (_positionIsSuperKo(board)) {
        board = lastValid;
        return (result: false, board: board);
      }

      _prevBoardStates
          .add(board.playgroundMap.toHighLevelBoardRepresentation());
      return (result: true, board: board);
    }

    return (result: false, board: board);
  }

  bool _positionIsSuperKo(
    BoardState newBoardState,
  ) {
    // This also includes basic ko

    final newBoardStateMap = newBoardState.playgroundMap;

    for (final prevBoardState in _prevBoardStates) {
      if (prevBoardState.length != newBoardStateMap.length) {
        continue;
      }

      bool isSame = true;
      for (final pos in prevBoardState.keys) {
        if (!newBoardStateMap.containsKey(pos) ||
            newBoardStateMap[pos]!.player != prevBoardState[pos]?.index) {
          isSame = false;
          break;
        }
      }

      if (isSame) {
        return true;
      }
    }

    return false;
  }

  static void doActionOnNeighbors(Position thisCell,
      void Function(Position curPos, Position neighbor) doAction) {
    var rowPlusOne = Position(thisCell.x + 1, thisCell.y);
    doAction(thisCell, rowPlusOne);
    var rowMinusOne = Position(thisCell.x - 1, thisCell.y);
    doAction(thisCell, rowMinusOne);
    var colPlusOne = Position(thisCell.x, thisCell.y + 1);
    doAction(thisCell, colPlusOne);
    var colMinusOne = Position(thisCell.x, thisCell.y - 1);
    doAction(thisCell, colMinusOne);
  }
}

// class Area {
//   Set<Position?> spaces = {};
//   // int value;
//   int get value => spaces.length;
//   int? owner;
//   bool isDame;
//   Area.from(this.isDame, this.owner);
//   Area()
//       : isDame = false,
//         owner = null;
// }

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
