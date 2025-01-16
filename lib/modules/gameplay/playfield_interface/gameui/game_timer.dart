import 'package:barebones_timer/timer_controller.dart';
import 'package:barebones_timer/timer_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go/core/foundation/duration.dart';
import 'package:go/core/utils/system_utilities.dart';
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

class MyTimeDisplay extends StatefulWidget {
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
  State<MyTimeDisplay> createState() => _MyTimeDisplayState();
}

class _MyTimeDisplayState extends State<MyTimeDisplay> {
  @override
  Widget build(BuildContext context) {
    final sys = SystemUtilities();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: !widget.compactUi ? 0 : 4,
      ),
      child: TimerDisplay(
        controller: widget.controller,
        builder: (controller) {
          var parts = controller.duration.getDurationReprParts();
          final dur = controller.duration;

          return Theme(
            data: controller.duration.inSeconds < 10
                ? context.theme.copyWith(
                    textTheme: Constants.buildTextTheme(
                      Colors.red,
                      weight: FontWeight.w600,
                    ),
                  )
                : context.theme,
            child: Builder(
              builder: (context) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.ideographic,
                    children: [
                      if (parts.h > 0) ...[
                        largeTimeStepText(
                            context, parts.h.timeStepPadded(), dur),
                        largeTimeStepText(context, ":", dur)
                      ],
                      largeTimeStepText(context, parts.m.timeStepPadded(), dur),
                      if (parts.h == 0) ...[
                        largeTimeStepText(context, ":", dur),
                        largeTimeStepText(
                            context, parts.s.timeStepPadded(), dur),
                      ],
                      SizedBox(
                        width: 4,
                      ),
                      if (parts.h > 0)
                        smallTimeStepText(
                            context, parts.s.timeStepPadded(), dur),
                      if (parts.h == 0 && parts.m == 0 && parts.s < 10)
                        smallTimeStepText(
                            context, parts.d.timeStepPadded(), dur),
                      if (widget.timeControl.byoYomiTime != null) ...[
                        Spacer(),
                        extraText(context, " +", dur),
                        extraText(
                          context,
                          widget.playerTimeSnapshot != null
                              ? (widget.playerTimeSnapshot!.byoYomisLeft ?? "")
                                  .toString()
                              : (widget.timeControl.byoYomiTime?.byoYomis ?? "")
                                  .toString(),
                          dur,
                        ),
                        extraText(
                          context,
                          "x${(Duration(seconds: widget.timeControl.byoYomiTime!.byoYomiSeconds)).smallRepr()}",
                          dur,
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Text largeTimeStepText(BuildContext context, String text, Duration dur) {
    return Text(text,
        style: dur.inSeconds < 10
            ? (context.textTheme.titleSmall)
            : (context.textTheme.bodyLarge)
        // ?.copyWith(
        //   fontFamily: GoogleFonts.notoSans().fontFamily,
        // ),
        );
  }

  Text smallTimeStepText(BuildContext context, String text, Duration dur) {
    return Text(text,
        style: dur.inSeconds < 10
            ? (context.textTheme.bodyLarge)
            : (context.textTheme.bodySmall)
        // ?.copyWith(
        //   fontFamily: GoogleFonts.notoSans().fontFamily,
        // ),
        );
  }

  Text extraText(BuildContext context, String text, Duration dur) {
    return Text(text,
        style: dur.inSeconds < 10
            ? (context.textTheme.bodyLarge)
            : (context.textTheme.bodySmall)
        // ?.copyWith(
        // fontFamily: GoogleFonts.spaceMono().fontFamily,
        // ),
        );
  }
}
