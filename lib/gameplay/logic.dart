import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go/services/auth_bloc.dart';
import 'package:go/playfield/game.dart';
import 'package:go/models/game_match.dart';
import 'package:go/ui/gameui/game_ui.dart';
import 'package:go/ui/gameui/time_watch.dart';
import 'package:go/utils/core_utils.dart';
import 'package:go/utils/time_and_duration.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_controller.dart';

import '../utils/player.dart';
import '../playfield/stone.dart';
import '../ui/gameui/game_ui.dart';
import '../utils/position.dart';
import 'package:go/constants/constants.dart' as Constants;

// ignore: must_be_immutable
class GameData extends InheritedWidget {
  final List<Player> _players;
  Map<String, int> _turn;
  final Widget mChild;
  StreamController<List<TimeAndDuration>> updateController = StreamController<List<TimeAndDuration>>.broadcast();

  List<PlayerCountdownTimer?> timers = [null, null];
  final List<CountdownController>? _controller = [CountdownController(autoStart: false), CountdownController(autoStart: false)];
  GameData({
    required List<Player> pplayer,
    required int pturn,
    required this.mChild,
    required this.match,
  })  : _players = pplayer,
        _turn = {'val': pturn},
        super(child: mChild) {
    timers = [
      PlayerCountdownTimer(controller: _controller![0], time: Duration(seconds: match.time), player: 0),
      PlayerCountdownTimer(controller: _controller![1], time: Duration(seconds: match.time), player: 1)
    ];
  }

  final GameMatch match;

  correctRemoteUserTimeAndAddToUpdateController(context, lastMoveDateTime) {
    NTP.now().then((value) {
      //var updatedTime = calculateCorrectTime(lastMoveDateTime.data, widget.player, dateTimeNowsnapshot.data, context);
      // lastMoveDateTimeSnapshot.data[widget.player].difference(GameData.of(context)?.match.startTime)
      // (Duration(seconds: GameData.of(context)!.match.time) -
      //         (snapshot.data ?? DateTime.now()).difference(
      //             GameData.of(context)?.match.startTime ??
      //                 DateTime.now()))
      //     .inSeconds;
      Duration durationAfterTimeElapsedCorrection = calculateCorrectTime(lastMoveDateTime, GameData.of(context)?.getPlayerWithTurn.turn, value, context);

      lastMoveDateTime[GameData.of(context)?.getPlayerWithTurn.turn] =
          (TimeAndDuration(lastMoveDateTime[GameData.of(context)?.getPlayerWithTurn.turn]?.datetime, durationAfterTimeElapsedCorrection));

      GameData.of(context)!.updateController.add(List<TimeAndDuration>.from(lastMoveDateTime));
    });
  }

  bool movePlayed = false;
  newMovePlayed(BuildContext context, DateTime timeOfPlay, Position? playPosition) {
    assert(getPlayerWithTurn.turn == getclientPlayer(context)); // The rest of the function depends on it
    movePlayed = true;
    MultiplayerData.of(context)
        ?.database
        .child('game')
        .child(match.id as String)
        .child('lastTimeAndDuration')
        //.child(getPlayerWithoutTurn.toString())
        .orderByKey()
        .get()
        .then((dataEvent) {
      if (dataEvent.value != null) {
        List<TimeAndDuration?> lastMoveDateTime = [null, null];
        lastMoveDateTime[0] = TimeAndDuration.fromString((dataEvent.value as List)[0]);
        lastMoveDateTime[1] = TimeAndDuration.fromString((dataEvent.value as List)[1]);


        lastMoveDateTime[getclientPlayer(context)] = TimeAndDuration(timeOfPlay, lastMoveDateTime[getclientPlayer(context)]!.duration);
        Duration updatedTime = calculateCorrectTime(lastMoveDateTime, getclientPlayer(context), null, context);
        lastMoveDateTime[getclientPlayer(context)] = (TimeAndDuration(timeOfPlay, updatedTime));

        updateTimeInDatabase(lastMoveDateTime, context, timeOfPlay, getclientPlayer(context));
        updateDurationInDatabase(lastMoveDateTime, context, updatedTime, getclientPlayer(context));
        // FIXME? this was changed from turn % 2 idk if this breaks something
        updateMoveIntoDatabase(context, playPosition);


        lastMoveDateTime.forEach((element) {
          print(element.toString());
        });


        correctRemoteUserTimeAndAddToUpdateController(context, lastMoveDateTime);
      }
    });
  }

  updateMoveIntoDatabase(BuildContext context, Position? position){
    var thisGame = MultiplayerData.of(context)?.database.child('game').child(match.id as String);
    thisGame?.child('moves').update({(match.turn).toString(): position.toString()});
    thisGame?.update({'turn': (turn + 1).toString()});
  }


  toggleTurn(BuildContext context) {
    GameData.of(context)?.timerController[turn % 2]?.pause();

    turn += 1;
    // turn = turn %2 == 0 ? 1 : 0;
    GameData.of(context)?.timerController[turn % 2]?.start();
  }

  DatabaseReference? getMatch(BuildContext context) {
    return MultiplayerData.of(context)?.database.child('game').child(match.id as String);
  }

  get turn => match.turn;
  set turn(dynamic val) => match.turn = val;

  get gametime => match.time;
  // get turnPlayerColor => [_players[0].mColor, _players[1].mColor];
  // Gives color of player with turn
  get getPlayerWithTurn => _players[turn % 2];
  get getPlayerWithoutTurn => _players[turn % 2 == 0 ? 1 : 0];
  get timerController => _controller;

  getRemotePlayer(BuildContext context) {
    //   match.uid.(MultiplayerData.of(context)?.curUser);
    // return (GameData.of(context)?.match.uid[GameData.of(context)?.turn % 2]) == MultiplayerData.of(context)?.curUser.uid;
    try {
      return match.uid.keys.firstWhere((k) => match.uid[k] != MultiplayerData.of(context)?.curUser.uid, orElse: () {
        throw TypeError;
      });
    } on TypeError {
      throw ("current client not found");
    }
  }

  getclientPlayer(BuildContext context) {
    //   match.uid.(MultiplayerData.of(context)?.curUser);
    // return (GameData.of(context)?.match.uid[GameData.of(context)?.turn % 2]) == MultiplayerData.of(context)?.curUser.uid;
    try {
      return match.uid.keys.firstWhere((k) => match.uid[k] == MultiplayerData.of(context)?.curUser.uid, orElse: () {
        throw TypeError;
      });
    } on TypeError {
      throw ("current client not found");
    }
  }

  @override
  bool updateShouldNotify(GameData oldWidget) {
    return oldWidget.turn != turn;
  }

  static GameData? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<GameData>();
}

class MultiplayerData extends InheritedWidget {
  final Widget mChild;
  final DatabaseReference database;
  final moveRef;
  final gameRef;
  final firestoreInstance;
  final curUser;

  MultiplayerData({required this.curUser, required this.mChild, required this.database})
      : firestoreInstance = FirebaseFirestore.instance,
        moveRef = database.child('move'),
        gameRef = database.child('game'),
        super(child: mChild);
  get move_ref => moveRef;
  get game_ref => gameRef;

  getCurGameRef(String id) {
    return gameRef.child(id);
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }

  static MultiplayerData? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<MultiplayerData>();
}

// ignore: must_be_immutable
class StoneLogic extends InheritedWidget {
  final Widget mChild;
  final int rows;
  final int cols;
  Map<Position?, ValueNotifier<Stone?>> _playgroundMap = {};
  Stone? _teststone;
  Position? _position;

  Position? koDelete;
  Position? koInsert;

  ValueNotifier<Stone?> stoneNotifierAt(Position)
  {
    return playground_Map[Position]!;
  }


  Stone? stoneAt(Position pos)
  {
    return playground_Map[pos]?.value;
  }

  // Database update
  Map<int, Position?> tmpClusterRefer = {};
  int clusterTopTracker = 0;

  // Constructor
  StoneLogic({required Map<Position?, Stone?> playgroundMap, required this.mChild, required this.rows, required this.cols})
      // : _playgroundMap = Map.from(playgroundMap)
       : super(child: mChild)
        {_playgroundMap = Map<Position?, ValueNotifier<Stone?>>.from(playgroundMap.map((key, value) => MapEntry(key, ValueNotifier(value))));}

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
          if (traversed[curpos] == null)
            traversed[curpos] = [getClusterFromPosition(neighbor)];
          else
            traversed[curpos]!.add(getClusterFromPosition(neighbor));
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
      if (stoneAt(neighbor)== null &&
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

    var map_ref = MultiplayerData.of(context)?.database.child('game').child(GameData.of(context)!.match.id as String).child('playgroundMap');

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

      map_ref?.update(LinkedHashMap.from(playground_Map.map(
        (a, b) => MapEntry(
            a.toString(),
            () {
              return stoneAt(a!)?.color == null
                  ? null
                  : () {
                      int currentClusterTracker = 0;
                      int currentClusterFreedoms = 0;
                      for (var i in tmpClusterRefer.keys) {
                        if (!(playground_Map[tmpClusterRefer[i]]?.value?.cluster.data.contains(a) ?? false)) {
                          clusterTopTracker++;
                          currentClusterTracker = clusterTopTracker;
                        } else {
                          currentClusterTracker = i;
                          break;
                        }
                      }
                      clusterTopTracker = 0;
                      tmpClusterRefer[currentClusterTracker] = a;
                      return ((stoneAt(a)?.color == Colors.black ? 0 : 1).toString() + " $currentClusterTracker ${playground_Map[a]?.value?.cluster.freedoms}");
                    }.call();
            }.call()),
      )));
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
