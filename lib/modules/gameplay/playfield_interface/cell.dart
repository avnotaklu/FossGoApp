// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:go/modules/gameplay/game_state/board_state_bloc.dart';
import 'package:go/modules/gameplay/stages/stage.dart';

import '../../../models/position.dart';
import 'stone_widget.dart';

class Cell extends StatelessWidget {
  final Position position;

  const Cell(this.position, {super.key});

  @override
  Widget build(BuildContext context) {
    BoardStateBloc gameBoard = context.read();
    final stone = gameBoard.stoneAt(position);
    final stage = context.read<Stage>();
    return Container(
      child: GestureDetector(
        onTap: stage.onCellTap == null
            ? null
            : () {
                stage.onCellTap!(position, context);
              },
        onTapUp: stage.onCellTapUp == null
            ? null
            : (details) {
                stage.onCellTapUp!(position, context);
              },
        onTapDown: stage.onCellTapDown == null
            ? null
            : (details) {
                stage.onCellTapDown!(position, context);
              },
        child: stage.drawCell(position, null, context),
      ),
    );
  }
}
