import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart' as constants;

import 'package:flutter/services.dart';
import 'package:go/gameplay/create/create_game.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:provider/provider.dart';
import 'stone_widget.dart';
import '../models/position.dart';

class Cell extends StatefulWidget {
  Position position;
  // Map<Position?,Stone?> playgroundMap;
  // final VoidCallback cellChanged;
  Cell(this.position);

  @override
  State<Cell> createState() => _CellState();
}

class _CellState extends State<Cell> {
  // StoneWidget? tmp;
  @override
  Widget build(BuildContext context) {
    // final Stream<StoneWidget?> _bids = (() async* {
    //   yield StoneLogic.of(context)?.stoneAt(widget.position);
    // })();

    // return ValueListenableBuilder<StoneWidget?>(
    //   valueListenable: StoneLogic.of(context)!.stoneNotifierAt(widget.position),
    //   builder: (BuildContext context, dyn, wid) {
    final stone = StoneLogic.of(context)!.stoneAt(widget.position);
    return GestureDetector(
      onTap: () {
        setState(() {
          context
              .read<GameStateBloc>()
              .curStage
              .onClickCell(widget.position, context);
        });
      },
      child: context.read<GameStateBloc>().curStage.drawCell(
          widget.position,
          StoneWidget(
            constants.playerColors[stone!.player],
            stone.position,
          ),
          context),
    );
    //   },
    // );
  }
}
