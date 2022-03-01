import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'stone.dart';
import '../utils/position.dart';

class Cell extends StatefulWidget {
  Position position;
  // Map<Position?,Stone?> playgroundMap;
  // final VoidCallback cellChanged;
  Cell(this.position);

  @override
  State<Cell> createState() => _CellState();
}

class _CellState extends State<Cell> {
  Stone? tmp;
  @override
  Widget build(BuildContext context) {
    final Stream<Stone?> _bids = (() async* {
      yield StoneLogic.of(context)?.stoneAt(widget.position);
    })();

    return ValueListenableBuilder<Stone?>(
      valueListenable: StoneLogic.of(context)!.stoneNotifierAt(widget.position),
      builder: (BuildContext context, dyn, wid) {
        return GestureDetector(
          onTap: () {
            setState(() {
              GameData.of(context)!.cur_stage.onClickCell(widget.position, context);
            });
          },
          child: GameData.of(context)!.cur_stage.drawCell(widget.position, dyn,context),
        );
      },
    );
  }
}
