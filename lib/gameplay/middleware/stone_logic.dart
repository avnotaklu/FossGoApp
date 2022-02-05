
import 'package:flutter/material.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/utils/position.dart';

class StoneLogic extends InheritedWidget {
  final Widget mChild;
  final int rows;
  final int cols;
  Map<Position?, ValueNotifier<Stone?>> _playgroundMap = {};
  Stone? _teststone;
  Position? _position;

  Position? koDelete;
  Position? koInsert;

  ValueNotifier<Stone?> stoneNotifierAt(Position) {
    return playground_Map[Position]!;
  }

  Stone? stoneAt(Position pos) {
    return playground_Map[pos]?.value;
  }

  // Database update
  // this function wouldn't work in any other inherited widget because it requires StoneLogic which is built later than other inherited widgets.
  void fetchNewStoneFromDB(context) {
    // TODO put this function in a better place, it has no relation to board
    print('hello');

    MultiplayerData.of(context)!.database.child('game').child(GameData.of(context)!.match.id).child('moves').onValue.listen((event) {
      // TODO unnecessary listen move even when move is played by clientPlayer even though (StoneLogic.of(context)!.stoneAt(pos)  == null) stops it from doing anything stupid
      final data = event.snapshot.value as List;
      if (data.last != null && data.last != "null") {
        final pos = Position(int.parse(data.last!.split(' ')[0]), int.parse(data.last!.split(' ')[1]));
        if (StoneLogic.of(context)!.stoneAt(pos) == null) {
          if (StoneLogic.of(context)!.handleStoneUpdate(pos, context)) {
            print("illegel");
            GameData.of(context)?.toggleTurn(context); // FIXME pos was passed to toggleTurn idk if that broke anything
            // setState(() {});
          }
        }
      }
    });
  }



  // Constructor
  StoneLogic({required Map<Position?, Stone?> playgroundMap, required this.mChild, required this.rows, required this.cols})
      // : _playgroundMap = Map.from(playgroundMap)
      : super(child: mChild) {
    _playgroundMap = Map<Position?, ValueNotifier<Stone?>>.from(playgroundMap.map((key, value) => MapEntry(key, ValueNotifier(value))));
  }

  // Getters
  Map<Position?, ValueNotifier<Stone?>> get playground_Map => _playgroundMap; // TODO maybe Position? can be just Position
  get teststone => _teststone;

  // Inheritance Widget related functions
  @override
  bool updateShouldNotify(StoneLogic oldWidget) {
    return oldWidget._position == _position;
    // return oldWidget.playgroundMap == playgroundMap;
  }

  static StoneLogic? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<StoneLogic>();

  // Helper functions
  printEntireGrid() {
    playground_Map.forEach((i, j) {
      debugPrint(" ${i?.x} ${i?.y} => color : ${j.value?.color.toString()} ${j.value?.cluster.freedoms.toString()}");
    });
  }

  getClusterFromPosition(Position pos) {
    return _playgroundMap[pos]?.value?.cluster;
  }

  /// returns true if not out of bounds
  checkOutofBounds(Position pos) {
    return pos.x > -1 && pos.x < rows && pos.y < cols && pos.y > -1;
  }

  /* Main Stone Logic functionality */

  // --- finally update freedoms for newly inserted stone
  // Update freedom by calculating only current stones neighbor( We can increment and decrement for neighbors in this way)
  updateFreedomsFromNewlyInsertedStone(Position position) {
    doActionOnNeighbors(position, (Position curpos, Position neighbor) {
      if ((traversed[curpos]?.contains(getClusterFromPosition(neighbor)) ?? false) == false) {
        // if( _playgroundMap[neighbor] == null && checkOutofBounds(neighbor))
        // {
        //   _playgroundMap[curpos]?.cluster.freedoms += 1;
        // }
        if (_playgroundMap[neighbor]?.value?.color != _playgroundMap[curpos]?.value?.color) {
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

  // Hack
  checkInsertable(Position position) {
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
                      if (_playgroundMap[neighbor]?.value?.color == _playgroundMap[curpos]?.value?.color)
                        insertable = !(getClusterFromPosition(neighbor).freedoms == 1)
                      else
                        insertable = getClusterFromPosition(neighbor)?.freedoms == 1,
                    }
                }
              else if (checkOutofBounds(neighbor))
                {
                  insertable = true,
                }
            });

    return insertable;
  }

  // Update Freedom by going through all stone in cluster and counting freedom for every stone

  /* From here */
  calculateFreedomForPosition(Position position) {
    doActionOnNeighbors(position, (Position curpos, Position neighbor) {
      // if( _playgroundMap[neighbor] == null && checkOutofBounds(neighbor) && alreadyAdded.contains(neighbor) == false)//  && (traversed[neighbor]?.contains(getClusterFromPosition(curpos)) == false) )
      if (stoneAt(neighbor) == null &&
          checkOutofBounds(neighbor) &&
          ((traversed[neighbor]?.contains(getClusterFromPosition(curpos)) ?? false) == false))
      //  && (traversed[neighbor]?.contains(getClusterFromPosition(curpos)) == false) )
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
  addAllOfNeighborToCurpos(Position curpos, Position? neighbor) // done on all neighbors
  {
    if (neighbor != null && _playgroundMap[neighbor]?.value?.color == _playgroundMap[curpos]?.value?.color) {
      // If neighbor isn't null and both neighbor and curpos both have same color
      for (var i in getClusterFromPosition(neighbor)?.data) {
        // add all of neighbors Position to cluster of curpos
        _playgroundMap[curpos]?.value?.cluster.data.add(i);
      }
    }
  }

  updateAllInTheClusterWithCorrectCluster(Cluster correctCluster) {
    for (var i in correctCluster.data) {
      _playgroundMap[i]?.value?.cluster = correctCluster;
    }
  }
  // Step 1 ---

  // --- Deletion
  // Traversed key gives the empty freedom point position and value is the list of cluster that has recieved freedom from that point
  Map<Position?, List<Cluster?>?> traversed = {null: null}; // TODO Find a way to do this without making this data member
  deleteStonesInDeletableCluster(Position curpos, Position neighbor) {
    if (_playgroundMap[neighbor]?.value?.color != _playgroundMap[curpos]?.value?.color && _playgroundMap[neighbor]?.value?.cluster.freedoms == 1) {
      for (var i in getClusterFromPosition(neighbor).data) {
        // This supposedly works because a
        // position where delete occurs in such a way that ko is possible
        // the cluster at that position can only have one member because
        // all the neighboring ones have to opposite ones for ko to be possible

        // how do we solve the behaviour when neighboring cells will be null

        // we store in koDelete The position that was deleted
        // we check that against newly entered stone and stone can only be deleted when neighboring cells will be opposite
        //

        if (getClusterFromPosition(i).data.length == 1) {
          koDelete = neighbor;
        }

        _playgroundMap[i]?.value = null;
        recalculateFreedomsForNeighborsOfDeleted(i);
      }
    }
  }

  recalculateFreedomsForNeighborsOfDeleted(Position deletedStonePosition) {
    // If a deleted position( free position ) has already contributed to the freedoms of a cluster it should not contribute again as that will result in duplication
    // A list of clusters is stored to keep track of what cluster has recieved freedoms points one free position can't give two freedoms to one cluster
    // but it can give freedom to different cluster
    doActionOnNeighbors(deletedStonePosition, (Position curpos, Position neighbor) {
      if (traversed.containsKey(curpos) == false) {
        traversed[curpos] = [null];
        // :assert(traversed[curpos]!.contains(getClusterFromPosition(neighbor)));
      }
      if ((traversed[curpos]?.contains(getClusterFromPosition(neighbor)) ?? false) == false) {
        getClusterFromPosition(neighbor)?.freedoms += 1;
        traversed[curpos]?.add(getClusterFromPosition(neighbor));
        assert(traversed[curpos]!.contains(getClusterFromPosition(neighbor)));
      }
    });
  }

  // Deletion ---

  bool handleStoneUpdate(Position position, BuildContext context) {
    _position = position;
    Position? thisCurrentCell = position;
    playground_Map[thisCurrentCell]?.value = Stone(GameData.of(context)?.getPlayerWithTurn.mColor, position);

    if (checkInsertable(position)) {
      // if stone can be inserted at this position
      koDelete = null;
      doActionOnNeighbors(position, addAllOfNeighborToCurpos);
      updateAllInTheClusterWithCorrectCluster(getClusterFromPosition(position));
      doActionOnNeighbors(position, deleteStonesInDeletableCluster);
      calculateFreedomForCluster(getClusterFromPosition(position));
      updateFreedomsFromNewlyInsertedStone(position);
      traversed.clear();

      // playgroundMap.cast<String,dynamic>;
      // Map<String,dynamic> tmp1;
      // var tmp2 = tmp1.cast<int,dynamic>;

      GameData.of(context)?.match.moves.add(position);
      return true;
    }

    playground_Map[thisCurrentCell]?.value = null;
    return false;
  }

  doActionOnNeighbors(Position thisCell, Function(Position, Position) doAction) {
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