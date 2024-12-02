import 'dart:async';

import 'package:barebones_timer/timer_controller.dart';
import 'package:barebones_timer/timer_display.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go/core/foundation/duration.dart';
import 'package:go/core/utils/string_formatting.dart';
import 'package:go/gameplay/create/create_game_screen.dart';
import 'package:go/models/game.dart';
import 'package:go/models/game_move.dart';
import 'package:go/models/time_control.dart';
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
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.5),
          color: widget.isMyTurn
              ? Constants.defaultTheme.enabledColor
              : Constants.defaultTheme.disabledColor,
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: timer(
            color: Constants.playerColors[widget.player.index],
            timeControl: widget.timeControl,
            playerTimeSnapshot: widget.playerTimeSnapshot,
          ),
        ));
  }

  Widget timer({
    required TimeControl timeControl,
    required PlayerTimeSnapshot? playerTimeSnapshot,
    required Color color,
  }) {
    // var color = ;
    return TimerDisplay(
      controller: widget.controller,
      builder: (controller) {
        var time = controller.duration.inSeconds;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              (time.toInt() ~/ 60).toString(),
              style: TextStyle(
                fontSize: 20,
                color: color,
              ),
            ),
            Text(
              ':',
              style: TextStyle(
                fontSize: 20,
                color: color,
              ),
            ),
            Text((time.toInt() % 60).toString(),
                style: TextStyle(
                  fontSize: 20,
                  color: color,
                )),
            if (timeControl.byoYomiTime != null) ...[
              Text(
                ' + ',
                style: TextStyle(
                  fontSize: 20,
                  color: color,
                ),
              ),
              Text(
                playerTimeSnapshot != null
                    ? (playerTimeSnapshot.byoYomisLeft ?? "").toString()
                    : (timeControl.byoYomiTime?.byoYomis ?? "").toString(),
                style: TextStyle(
                  fontSize: 20,
                  color: color,
                ),
              ),
              Text(
                " x ${(Duration(seconds: timeControl.byoYomiTime!.byoYomiSeconds)).durationRepr()}",
                style: TextStyle(
                  fontSize: 20,
                  color: color,
                ),
              ),
            ]
          ],
        );
      },
    );
  }
}
