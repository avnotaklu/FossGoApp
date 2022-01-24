import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:go/gameplay/logic.dart';
import 'package:go/playfield/game.dart';
import 'package:go/utils/position.dart';
import 'package:ntp/ntp.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:go/constants/constants.dart' as Constants;

Stream<Position?> lastMove(BuildContext context) async* {
  yield GameData.of(context)?.match.moves.last;
}

Stream<bool> hasLastChanged(context) {
  StreamController<bool> lastMoveChanged = StreamController<bool>();
  StreamController<Position?> lastmove = StreamController<Position?>();
  //var position = GameData.of(context)?.match.moves.last as Position;

  lastMove(context).listen((position) {
    lastMoveChanged.add(true);
  });
  return lastMoveChanged.stream;
}

class TimeWatch extends StatefulWidget {
  CountdownController mController;
  @override
  State<TimeWatch> createState() => _TimeWatchState();
  TimeWatch(controller, {required pplayer})
      : mController = controller,
        player = pplayer;
  int player;
  ValueNotifier<Position?> lastMoveNotifier = ValueNotifier<Position?>(null);
}

fn(ValueNotifier<Position?> val, context) {
  if (!val.hasListeners) {
    val.addListener(() {
      //setState(() {
      WidgetsBinding.instance?.addPostFrameCallback((__) {
        // after seconds have been modified then do the stuff
        GameData.of(context)
            ?.timerController[0]
            .restart(); // This restarts with new seconds widget.value
        GameData.of(context)?.timerController[1].restart();
      });
    });
    //});
  }
}

class _TimeWatchState extends State<TimeWatch> {
  @override
  Widget build(BuildContext context) {
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
    // }
    return ValueListenableBuilder<Position?>(
      valueListenable:
          GameData.of(context)?.lastMoveNotifier as ValueNotifier<Position?>,
      // valueListenable: widget.lastMoveNotifier,
      builder: (context, pos, a) {
        //return StreamBuilder<List.filled(2, GameData.of(context)?.match.startTime)>(
        return StreamBuilder<DatabaseEvent>(
          stream: MultiplayerData.of(context)
              ?.getCurGameRef(GameData.of(context)?.match.id as String)
              //?.game_ref
              .child('lastMoveDateTime')
              .onValue,
          builder:
              (context, AsyncSnapshot<DatabaseEvent> lastMoveDateTimeSnapshot) {
            if (lastMoveDateTimeSnapshot.connectionState ==
                ConnectionState.active) {
              WidgetsBinding.instance?.addPostFrameCallback((__) {
                // after seconds have been modified then do the stuff
                GameData.of(context)
                    ?.timerController[widget.player]
                    .restart(); // This restarts with new seconds widget.value
              });
              List<DateTime> lastMoveDateTime = [];
              (lastMoveDateTimeSnapshot.data?.snapshot.value as List)
                  .forEach((element) {
                lastMoveDateTime.add(DateTime.parse(element));
              });
              //List<DateTime> lastMoveDateTimes = List.castFrom(
              //   lastMoveDateTimeSnapshot.data?.snapshot.value as List);
              print("value changed in timewatch");
              return FutureBuilder<DateTime>(
                  future: NTP.now(),
                  builder: (context, dateTimeNowsnapshot) {
                    if (dateTimeNowsnapshot.connectionState ==
                        ConnectionState.done) {
                      Duration updatedTimeBeforeNewMoveForBothPlayers =
                          Duration(seconds: 0);
                      try {
                        updatedTimeBeforeNewMoveForBothPlayers =
                            lastMoveDateTime[widget.player].difference(
                          lastMoveDateTime[widget.player == 0 ? 1 : 0],
                        );
                      } catch (err) {}

                      int updatedTime = GameData.of(context)?.match.time as int;
                      try {
                        updatedTime = ((GameData.of(context)?.turn % 2) == 0
                                    ? 1
                                    : 0) ==
                                widget
                                    .player // FIXME This is async so turn can probably change in different order which will cause issues
                            ? (GameData.of(context)?.match.time as int) -
                                updatedTimeBeforeNewMoveForBothPlayers.inSeconds
                            : (GameData.of(context)?.match.time as int) -
                                ((dateTimeNowsnapshot.data?.difference(
                                            lastMoveDateTime[
                                                widget.player == 0 ? 1 : 0]) ??
                                        updatedTimeBeforeNewMoveForBothPlayers))
                                    .inSeconds;
                      } catch (err) {}
                      // lastMoveDateTimeSnapshot.data[widget.player].difference(GameData.of(context)?.match.startTime)
                      // (Duration(seconds: GameData.of(context)!.match.time) -
                      //         (snapshot.data ?? DateTime.now()).difference(
                      //             GameData.of(context)?.match.startTime ??
                      //                 DateTime.now()))
                      //     .inSeconds;
                      return Countdown(
                        controller: widget.mController,
                        // seconds: GameData.of(context)!.match.time,
                        seconds: updatedTime > 0 ? updatedTime : 0,
                        build: (BuildContext context, double time) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                (time.toInt() ~/ 60).toString(),
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Constants
                                      .players[widget.player == 0 ? 1 : 0]
                                      .mColor,
                                ),
                              ),
                              Text(
                                ':',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Constants
                                      .players[widget.player == 0 ? 1 : 0]
                                      .mColor,
                                ),
                              ),
                              Text((time.toInt() % 60).toString(),
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Constants
                                        .players[widget.player == 0 ? 1 : 0]
                                        .mColor,
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
      },
    );
  }
}
