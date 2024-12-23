// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:go/constants/constants.dart' as constants;
import 'package:go/modules/gameplay/game_state/game_board_bloc.dart';
import 'package:go/modules/gameplay/stages/stage.dart';

import '../../../models/position.dart';
import 'stone_widget.dart';

class Cell extends StatelessWidget {
  final Position position;

  const Cell(this.position, {super.key});

  @override
  Widget build(BuildContext context) {
    GameBoardBloc gameBoard = context.read();
    final stone = gameBoard.stoneAt(position);
    final stage = context.read<Stage>();
    return GestureDetector(
      onTap: () {
        stage.onClickCell(position, context);
      },
      child: stage.drawCell(
          position,
          StoneWidget(
            stone == null ? null : constants.playerColors[stone.player],
            position,
          ),
          context),
    );
  }
}
