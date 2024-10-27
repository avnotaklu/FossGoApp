import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go/gameplay/create/create_game_screen.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/models/game_move.dart';
import 'package:go/playfield/game_widget.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/services/auth_provider.dart';
import 'package:go/utils/core_utils.dart';
import 'package:go/models/position.dart';
import 'package:go/utils/player.dart';
import 'package:go/utils/time_and_duration.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:go/constants/constants.dart' as Constants;

// class TimeUpdateHandler {
//   Stream<TimeAndDuration> changeStream;
//   final StreamController<TimeAndDuration> _updateController;
//   TimeUpdateHandler(this.changeStream) : _updateController = StreamController<TimeAndDuration>.broadcast();

//   streamUpdatedTime(TimeAndDuration val) {
//     changeStream.listen((event) {
//       _updateController.add(event);
//     });
//   }
// }

class GameTimer extends StatefulWidget {
  final CountdownController mController;
  final Player player;
  final Duration time;

  @override
  State<GameTimer> createState() => _GameTimerState();
  const GameTimer(this.time, controller, {super.key, required pplayer})
      : mController = controller,
        player = pplayer;
}

class _GameTimerState extends State<GameTimer> {
  // @override
  // initState() {
  //   super.initState();
  // }

  // FIXME: this doesn't update time when moves are played too fast
  // streamUpdatedTime() {
  //   MultiplayerData.of(context)
  //       ?.database
  //       .child('game')
  //       .child(GameData.of(context)?.match.id as String)
  //       .child('lastTimeAndDuration')
  //       .child(GameData.of(context)?.getClientPlayerIndex(context) == 0 ? 1.toString() : 0.toString())
  //       .onValue
  //       .listen((changeEvent) {
  //     MultiplayerData.of(context)
  //         ?.database
  //         .child('game')
  //         .child(GameData.of(context)!.match.id)
  //         .child('lastTimeAndDuration')
  //         .orderByKey()
  //         .get()
  //         .then((dataEvent) {
  //       if (changeEvent.snapshot.value != null) {
  //         if (dataEvent.value != null) {
  //           if (GameData.of(context)!.turn % 2 != widget.player) {
  //             List<TimeAndDuration> lastMoveDateTime = [];
  //             for (var element in (dataEvent.value as List)) {
  //               lastMoveDateTime.add(TimeAndDuration.fromString(element));
  //             }

  //             GameData.of(context)!
  //                 .correctTurnPlayerTimeAndAddToUpdateController(GameData.of(context)!.getPlayerWithTurn.turn, context, lastMoveDateTime);

  //             GameData.of(context)?.match.lastTimeAndDate = [...lastMoveDateTime];
  //             // GameData.of(context)!.updateController.add(lastMoveDateTime);
  //           }
  //         }
  //       }
  //     });
  //     //   .onValue
  //     //   .listen((dataEvent) {
  //     // if (changeEvent.snapshot.value != null) {
  //     //   if (dataEvent.snapshot.value != null) {
  //     //     if (GameData.of(context)?.turn % 2 != widget.player) {
  //     //       List<TimeAndDuration> lastMoveDateTime = [];
  //     //       (dataEvent.snapshot.value as List).forEach((element) {
  //     //         lastMoveDateTime.add(TimeAndDuration.fromString(element));
  //     //       });

  //     //       widget._updateController.add(lastMoveDateTime);
  //     //     }
  //     //   }
  //     // }
  //     // });
  //   });
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // streamUpdatedTime();
    //streamUpdatedTime();
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

    // return StreamBuilder<GameMove>(
    //   stream: context.read<GameStateBloc>().listenFromMove,
    // stream: MultiplayerData.of(context)
    // ?.getCurGameRef(GameData.of(context)?.match.id as String)
    // ?.game_ref
    // .child('lastTimeAndDuration')
    // .onValue,
    // builder: (context, AsyncSnapshot<GameMove> move) {
    //   if (move.connectionState == ConnectionState.active) {
    //     assert(
    //       move.data!.playerId ==
    //           context.read<AuthProvider>().currentUserRaw!.id,
    //       "Shouldn't be listening to other players moves",
    //     );
    // WidgetsBinding.instance?.addPostFrameCallback((__) {
    //   // after seconds have been modified then do the stuff
    //   GameData.of(context)?.timerController[widget.player].reset(); // This restarts with new seconds widget.value
    // });
    // List<DateTime> lastMoveDateTimes = List.castFrom(
    //   lastMoveDateTimeSnapshot.data?.snapshot.value as List);
    // print("value changed in timewatch");
    // return FutureBuilder<DateTime>(
    //     future: NTP.now(),
    //     builder: (context, dateTimeNowsnapshot) {
    //       if (dateTimeNowsnapshot.connectionState == ConnectionState.done) {
    //var updatedTime = calculateCorrectTime(lastMoveDateTime.data, widget.player, dateTimeNowsnapshot.data, context);
    // lastMoveDateTimeSnapshot.data[widget.player].difference(GameData.of(context)?.match.startTime)
    // (Duration(seconds: GameData.of(context)!.match.time) -
    //         (snapshot.data ?? DateTime.now()).difference(
    //             GameData.of(context)?.match.startTime ??
    //                 DateTime.now()))
    //     .inSeconds;
    // if(widget.player == GameData.of(context)?.getPlayerWithTurn.turn)
    // {
    //   Duration durationAfterTimeElapsedCorrection = calculateCorrectTime(lastMoveDateTime.data, widget.player, dateTimeNowsnapshot.data, context);
    // return PlayerCountdownTimer( controller: widget.mController, time: durationAfterTimeElapsedCorrection , player: widget.player);

    // }

    // print(
    //     "${move.data?[widget.player].duration.toString()} = ${widget.player.toString()}");
    // GameData.of(context)!.timers[widget.player]!.time = lastMoveDateTime.data?[widget.player].duration;
    // return GameData.of(context)!.timers[widget.player]!;
    return PlayerCountdownTimer(
      controller: widget.mController,
      // TODO: should use NTP time??
      time: widget.time,
      player: widget.player,
    );
    // } else
    // // if(lastMoveDateTimeSnapshot.connectionState == ConnectionState.waiting)
    // {
    //   // return SizedBox.shrink();
    //   // GameData.of(context)!.timers[widget.player]!.time = Duration(seconds:  GameData.of(context)!.match.time - 5);
    //   return PlayerCountdownTimer( controller: widget.mController, time: Duration(seconds: GameData.of(context)!.match.time), player: widget.player);
    //   // return GameData.of(context)!.timers[widget.player]!;
    // }
    // });
    // } else
    //if(lastMoveDateTimeSnapshot.connectionState == ConnectionState.waiting)
    // {
    // return SizedBox.shrink();
    //GameData.of(context)!.timers[widget.player]!.time = Duration(seconds:  GameData.of(context)!.match.time - 5);
    // return PlayerCountdownTimer(
    //   controller: widget.mController,
    //   time: Duration(
    //       seconds: context.read<GameStateBloc>().game.timeInSeconds),
    //   player: widget.player,
    // );

    /// return GameData.of(context)!.timers[widget.player]!;
    // return PlayerCountdownTimer(
    //     controller: widget.mController, time: Duration(seconds: GameData.of(context)!.match.time), player: widget.player);
    //     }
    //   },
    // );
    //   },
    // );
  }
}

class PlayerCountdownTimer extends StatefulWidget {
  const PlayerCountdownTimer({
    super.key,
    required this.controller,
    required this.time,
    required this.player,
  });

  final Player player;
  final Duration time;
  final CountdownController controller;

  @override
  State<PlayerCountdownTimer> createState() => _PlayerCountdownTimerState();
}

class _PlayerCountdownTimerState extends State<PlayerCountdownTimer> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((__) {
      // after seconds have been modified then do the stuff
      context
          .read<GameStateBloc>()
          .timerController[widget.player.turn]
          .reset(); // This restarts with new seconds value
    });

    return Container(
        color:
            context.read<GameStateBloc>().turn.player_turn == widget.player.turn
                ? Constants.defaultTheme.mainHighlightColor
                : Colors.transparent,
        child: Align(
          alignment: Alignment.centerRight,
          child: Countdown(
            controller: widget.controller,
            // seconds: GameData.of(context)!.match.time,
            duration: widget.time > const Duration(seconds: 0)
                ? widget.time
                : const Duration(seconds: 0),
            build: (BuildContext context, double time) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    (time.toInt() ~/ 60).toString(),
                    style: TextStyle(
                      fontSize: 25,
                      color: Constants.playerColors[widget.player.turn],
                    ),
                  ),
                  Text(
                    ':',
                    style: TextStyle(
                      fontSize: 25,
                      color: Constants.playerColors[widget.player.turn],
                    ),
                  ),
                  Text((time.toInt() % 60).toString(),
                      style: TextStyle(
                        fontSize: 25,
                        color: Constants.playerColors[widget.player.turn],
                      )),
                ],
              );
            },

            interval: const Duration(milliseconds: 100),

            onFinished: () {
              print('Timer is done!');
            },
          ),
        ));
  }
}
