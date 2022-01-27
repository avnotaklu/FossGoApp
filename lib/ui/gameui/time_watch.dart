import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:go/gameplay/logic.dart';
import 'package:go/playfield/game.dart';
import 'package:go/utils/position.dart';
import 'package:go/utils/time_and_duration.dart';
import 'package:ntp/ntp.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:go/constants/constants.dart' as Constants;

class TimeUpdateHandler {
  Stream<TimeAndDuration> changeStream;
  StreamController<TimeAndDuration> _updateController;
  TimeUpdateHandler(this.changeStream) : _updateController = StreamController<TimeAndDuration>.broadcast();

  streamUpdatedTime(TimeAndDuration val) {
    changeStream.listen((event) {
      _updateController.add(event);
    });
  }
}

class TimeWatch extends StatefulWidget {
  StreamController<List<TimeAndDuration>> _updateController = StreamController<List<TimeAndDuration>>.broadcast();

  StreamController<List<TimeAndDuration>> changeController = StreamController.broadcast();

  CountdownController mController;
  @override
  State<TimeWatch> createState() => _TimeWatchState();
  TimeWatch(controller, {required pplayer})
      : mController = controller,
        player = pplayer;
  int player;
  ValueNotifier<TimeAndDuration?> lastMoveNotifier = ValueNotifier<TimeAndDuration?>(null);
}

class _TimeWatchState extends State<TimeWatch> {
  streamUpdatedTime() {
    MultiplayerData.of(context)
        ?.database
        .child('game')
        .child(GameData.of(context)?.match.id as String)
        .child('lastTimeAndDuration')
        .child(GameData.of(context)?.getclientPlayer(context) == 0 ? 1.toString() : 0.toString())

        .onValue
        .listen((changeEvent) {
      MultiplayerData.of(context)
          ?.database
          .child('game')
          .child(GameData.of(context)!.match.id as String)
          .child('lastTimeAndDuration')
          .onValue
          .listen((dataEvent) {
        if (changeEvent.snapshot.value != null) {
          if (dataEvent.snapshot.value != null) {
            if (GameData.of(context)?.turn % 2 != widget.player) {
              List<TimeAndDuration> lastMoveDateTime = [];
              (dataEvent.snapshot.value as List).forEach((element) {
                lastMoveDateTime.add(TimeAndDuration.fromString(element));
              });

              widget._updateController.add(lastMoveDateTime);
            }
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    streamUpdatedTime();
    // try {
    //   widget.val.value = GameData.of(context)?.match.moves.last;
    //   if (!widget.val.hasListeners) {
    //     widget.val.addListener(() {
    //       setState(() {

    //         });
    //       });
    //     });
    //   }
    // } catch (StateError) {
    //   if (!widget.val.hasListeners) {
    //     widget.val.addListener(() {
    //       setState(() {
    //         WidgetsBinding.instance?.addPostFrameCallback((__) {
    //           // after seconds have been modified then do the stuff
    //           GameData.of(context)
    //               ?.timerController[0]
    //               .restart(); // This restarts with new seconds widget.value
    //           GameData.of(context)?.timerController[1].restart();
    //         });
    //       });
    //     });
    //   }
    // // }
    // return ValueListenableBuilder<Position?>(
    //   valueListenable: GameData.of(context)?.lastMoveNotifier as ValueNotifier<Position?>,
    //   // valueListenable: widget.lastMoveNotifier,
    //   builder: (context, pos, a) {
    //     //return StreamBuilder<List.filled(2, GameData.of(context)?.match.startTime)>(

    return StreamBuilder<List<TimeAndDuration>>(
      stream: widget._updateController.stream,
      // stream: MultiplayerData.of(context)
      // ?.getCurGameRef(GameData.of(context)?.match.id as String)
      // ?.game_ref
      // .child('lastTimeAndDuration')
      // .onValue,
      builder: (context, AsyncSnapshot<List<TimeAndDuration>> lastMoveDateTime) {
        if (lastMoveDateTime.connectionState == ConnectionState.active) {
          WidgetsBinding.instance?.addPostFrameCallback((__) {
            // after seconds have been modified then do the stuff
            GameData.of(context)?.timerController[widget.player].restart(); // This restarts with new seconds widget.value
          });
          //List<DateTime> lastMoveDateTimes = List.castFrom(
          //   lastMoveDateTimeSnapshot.data?.snapshot.value as List);
          print("value changed in timewatch");
          return FutureBuilder<DateTime>(
              future: NTP.now(),
              builder: (context, dateTimeNowsnapshot) {
                if (dateTimeNowsnapshot.connectionState == ConnectionState.done) {
                  Duration updatedTimeBeforeNewMoveForBothPlayers = Duration(seconds: 0);
                  try {
                    updatedTimeBeforeNewMoveForBothPlayers = lastMoveDateTime.data?[widget.player].datetime.difference(
                      lastMoveDateTime.data?[widget.player == 0 ? 1 : 0].datetime,
                    );
                  } catch (err) {}

                  Duration updatedTime = (lastMoveDateTime.data?[widget.player].duration);
                  try {
                    updatedTime = ((GameData.of(context)?.turn % 2) == 0 ? 1 : 0) ==
                            widget.player // FIXME This is async so turn can probably change in different order which will cause issues
                        ? (lastMoveDateTime.data?[widget.player].duration) - updatedTimeBeforeNewMoveForBothPlayers
                        : (lastMoveDateTime.data?[widget.player].duration) -
                            ((dateTimeNowsnapshot.data?.difference(lastMoveDateTime.data?[widget.player == 0 ? 1 : 0].datetime) ??
                                updatedTimeBeforeNewMoveForBothPlayers));
                  } catch (err) {}
                  // lastMoveDateTimeSnapshot.data[widget.player].difference(GameData.of(context)?.match.startTime)
                  // (Duration(seconds: GameData.of(context)!.match.time) -
                  //         (snapshot.data ?? DateTime.now()).difference(
                  //             GameData.of(context)?.match.startTime ??
                  //                 DateTime.now()))
                  //     .inSeconds;

                  DatabaseReference thisGame = MultiplayerData.of(context)!.database.child('game').child(GameData.of(context)?.match.id as String);
                  updateDurationInDatabase(thisGame, updatedTime, GameData.of(context)?.turn % 2);
                  return Countdown(
                    controller: widget.mController,
                    // seconds: GameData.of(context)!.match.time,
                    seconds: updatedTime.inSeconds > 0 ? updatedTime.inSeconds : 0,
                    build: (BuildContext context, double time) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            (time.toInt() ~/ 60).toString(),
                            style: TextStyle(
                              fontSize: 25,
                              color: Constants.playerColors[widget.player == 0 ? 1 : 0],
                            ),
                          ),
                          Text(
                            ':',
                            style: TextStyle(
                              fontSize: 25,
                              color: Constants.playerColors[widget.player == 0 ? 1 : 0],
                            ),
                          ),
                          Text((time.toInt() % 60).toString(),
                              style: TextStyle(
                                fontSize: 25,
                                color: Constants.playerColors[widget.player == 0 ? 1 : 0],
                              )),
                        ],
                      );
                    },
                    interval: const Duration(milliseconds: 100),
                    onFinished: () {
                      print('Timer is done!');
                    },
                  );
                } else
                //if(lastMoveDateTimeSnapshot.connectionState == ConnectionState.waiting)
                {
                  return SizedBox.shrink();
                }
              });
        } else
        //if(lastMoveDateTimeSnapshot.connectionState == ConnectionState.waiting)
        {
          return SizedBox.shrink();
        }
      },
    );
    //   },
    // );
  }
}
