import 'package:barebones_timer/timer_controller.dart';
import 'package:barebones_timer/timer_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go/core/foundation/duration.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/models/game.dart';
import 'package:go/models/time_control.dart';

import 'package:go/constants/constants.dart' as Constants;
import 'package:go/widgets/stateful_card.dart';

class GameTimer extends StatefulWidget {
  const GameTimer({
    super.key,
    required this.controller,
    required this.player,
    required this.isMyTurn,
    required this.timeControl,
    required this.playerTimeSnapshot,
  });

  final StoneType player;
  final TimeControl timeControl;
  final PlayerTimeSnapshot? playerTimeSnapshot;
  final TimerController controller;
  final bool isMyTurn;

  @override
  State<GameTimer> createState() => _GameTimerState();
}

class _GameTimerState extends State<GameTimer> {
  @override
  Widget build(BuildContext context) {
    return StatefulCard(
      state: widget.isMyTurn
          ? StatefulCardState.enabled
          : StatefulCardState.disabled,
      builder: (c) => Align(
        alignment: Alignment.centerRight,
        child: MyTimeDisplay(
          controller: widget.controller,
          timeControl: widget.timeControl,
          playerTimeSnapshot: widget.playerTimeSnapshot,
        ),
      ),
    );
  }
}

class MyTimeDisplay extends StatelessWidget {
  final TimeControl timeControl;
  final PlayerTimeSnapshot? playerTimeSnapshot;
  final TimerController controller;

  const MyTimeDisplay({
    required this.controller,
    required this.timeControl,
    required this.playerTimeSnapshot,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TimerDisplay(
        controller: controller,
        builder: (controller) {
          var time = controller.duration.inSeconds;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                (time.toInt() ~/ 60).toString(),
                style: context.textTheme.titleLarge,
              ),
              Text(
                ':',
                style: context.textTheme.titleLarge,
              ),
              Text(
                (time.toInt() % 60).toString(),
                style: context.textTheme.titleLarge,
              ),
              if (timeControl.byoYomiTime != null) ...[
                Text(
                  ' + ',
                  style: context.textTheme.titleLarge,
                ),
                Text(
                  playerTimeSnapshot != null
                      ? (playerTimeSnapshot!.byoYomisLeft ?? "").toString()
                      : (timeControl.byoYomiTime?.byoYomis ?? "").toString(),
                  style: context.textTheme.titleLarge,
                ),
                Text(
                  " x ${(Duration(seconds: timeControl.byoYomiTime!.byoYomiSeconds)).smallRepr()}",
                  style: context.textTheme.titleLarge,
                ),
              ]
            ],
          );
        },
      ),
    );
  }
}
