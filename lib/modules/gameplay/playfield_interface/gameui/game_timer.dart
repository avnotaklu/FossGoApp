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
import 'package:google_fonts/google_fonts.dart';

class GameTimer extends StatefulWidget {
  const GameTimer({
    super.key,
    required this.controller,
    required this.player,
    required this.isMyTurn,
    required this.timeControl,
    required this.playerTimeSnapshot,
    this.compactUi = false,
  });

  final StoneType player;
  final TimeControl timeControl;
  final PlayerTimeSnapshot? playerTimeSnapshot;
  final TimerController controller;
  final bool isMyTurn;
  final bool compactUi;

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
          compactUi: widget.compactUi,
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
  final bool compactUi;

  const MyTimeDisplay({
    required this.controller,
    required this.timeControl,
    required this.playerTimeSnapshot,
    this.compactUi = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: !compactUi ? 0 : 4,
      ),
      child: TimerDisplay(
        controller: controller,
        builder: (controller) {
          var parts = controller.duration.getDurationReprParts();

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.ideographic,
                children: [
                  if (parts.h > 0) ...[
                    largeTimeStepText(context, parts.h.timeStepPadded()),
                    largeTimeStepText(context, ":")
                  ],
                  largeTimeStepText(context, parts.m.timeStepPadded()),
                  if (parts.h == 0) ...[
                    largeTimeStepText(context, ":"),
                    largeTimeStepText(context, parts.s.timeStepPadded()),
                  ],
                  SizedBox(
                    width: 4,
                  ),
                  if (parts.h > 0 || parts.m > 0)
                    smallTimeStepText(context, parts.s.timeStepPadded()),
                  if (parts.h == 0 && parts.m == 0 && parts.s < 10)
                    smallTimeStepText(context, parts.d.timeStepPadded()),
                  if (timeControl.byoYomiTime != null) ...[
                    Spacer(),
                    extraText(context, " +"),
                    extraText(
                      context,
                      playerTimeSnapshot != null
                          ? (playerTimeSnapshot!.byoYomisLeft ?? "").toString()
                          : (timeControl.byoYomiTime?.byoYomis ?? "")
                              .toString(),
                    ),
                    extraText(
                      context,
                      " x ${(Duration(seconds: timeControl.byoYomiTime!.byoYomiSeconds)).smallRepr()}",
                    ),
                  ]
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Text largeTimeStepText(BuildContext context, String text) {
    return Text(
      text,
      style: (context.textTheme.bodyLarge)?.copyWith(
        fontFamily: GoogleFonts.spaceMono().fontFamily,
      ),
    );
  }

  Text smallTimeStepText(BuildContext context, String text) {
    return Text(
      text,
      style: (context.textTheme.bodySmall)?.copyWith(
        fontFamily: GoogleFonts.spaceMono().fontFamily,
      ),
    );
  }

  Text extraText(BuildContext context, String text) {
    return Text(
      text,
      style: (context.textTheme.bodySmall)?.copyWith(
          // fontFamily: GoogleFonts.spaceMono().fontFamily,
          ),
    );
  }
}
