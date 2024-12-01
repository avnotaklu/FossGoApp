import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go/core/foundation/duration.dart';
import 'package:go/core/utils/string_formatting.dart';
import 'package:go/gameplay/create/create_game_screen.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/models/game_move.dart';
import 'package:go/playfield/game_widget.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/services/auth_provider.dart';
import 'package:go/utils/core_utils.dart';
import 'package:go/models/position.dart';
import 'package:go/utils/player.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:go/constants/constants.dart' as Constants;

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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PlayerCountdownTimer(
      controller: widget.mController,
      time: widget.time,
      player: widget.player,
    );
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
    // WidgetsBinding.instance?.addPostFrameCallback((__) {
    //   // after seconds have been modified then do the stuff
    //   context
    //       .read<GameStateBloc>()
    //       .timerController[widget.player.turn]
    //       .reset(); // This restarts with new seconds value
    // });

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.5),
          color: context.read<GameStateBloc>().turn.player_turn ==
                  widget.player.turn
              ? Constants.defaultTheme.enabledColor
              : Constants.defaultTheme.disabledColor,
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: timer(),
        ));
  }

  Countdown timer() {
    debugPrint("Building with time : ${widget.time.durationRepr()}");
    return Countdown(
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
                fontSize: 20,
                color: Constants.playerColors[widget.player.turn],
              ),
            ),
            Text(
              ':',
              style: TextStyle(
                fontSize: 20,
                color: Constants.playerColors[widget.player.turn],
              ),
            ),
            Text((time.toInt() % 60).toString(),
                style: TextStyle(
                  fontSize: 20,
                  color: Constants.playerColors[widget.player.turn],
                )),
            if (context.read<GameStateBloc>().game.timeControl.byoYomiTime !=
                null) ...[
              Text(
                ' + ',
                style: TextStyle(
                  fontSize: 20,
                  color: Constants.playerColors[widget.player.turn],
                ),
              ),
              Text(
                context.read<GameStateBloc>().game.startTime != null
                    ? context
                        .read<GameStateBloc>()
                        .game
                        .playerTimeSnapshots[widget.player.turn]
                        .byoYomisLeft!
                        .toString()
                    : (context
                                .read<GameStateBloc>()
                                .game
                                .timeControl
                                .byoYomiTime
                                ?.byoYomis ??
                            "")
                        .toString(),
                style: TextStyle(
                  fontSize: 20,
                  color: Constants.playerColors[widget.player.turn],
                ),
              ),
              Text(
                " x ${(Duration(seconds: context.read<GameStateBloc>().game.timeControl.byoYomiTime!.byoYomiSeconds)).durationRepr()}",
                style: TextStyle(
                  fontSize: 20,
                  color: Constants.playerColors[widget.player.turn],
                ),
              ),
            ]
          ],
        );
      },

      interval: const Duration(milliseconds: 100),

      onFinished: () {
        print('Timer is done!');
      },
    );
  }
}
