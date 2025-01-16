// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:go/models/game.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/middleware/analysis_bloc.dart';
import 'package:go/modules/gameplay/stages/analysis_stage.dart';
import 'package:go/modules/gameplay/stages/gameplay_stage.dart';
import 'package:go/utils/stone_type.dart';
import 'package:provider/provider.dart';

import 'package:go/modules/gameplay/game_state/board_state_bloc.dart';
import 'package:go/modules/gameplay/stages/stage.dart';

import '../../../models/position.dart';
import 'stone_widget.dart';

class Cell extends StatefulWidget {
  final Position position;

  const Cell(this.position, {super.key});

  @override
  State<Cell> createState() => _CellState();
}

class _CellState extends State<Cell> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    BoardStateBloc gameBoard = context.read();
    GameStateBloc gameState = context.read();
    AnalysisBloc analysisBloc = context.read();

    StoneType? stone;

    //   stone = StoneTypeExt.fromMoveNumber(gameState.playerTurn);
    if (context.read<Stage>() is AnalysisStage) {
      stone = StoneTypeExt.fromMoveNumber(analysisBloc.currentLine.length);
    }

    final stage = context.read<Stage>();
    return MouseRegion(
      onEnter: (det) {
        if (context.read<Stage>() is GameplayStage) {
          if (!gameBoard.intermediateToBePlayed) {
            gameState.placeStone(widget.position, gameBoard);
          }
        } else if (context.read<Stage>() is AnalysisStage) {
          setState(() {
            hovered = true;
          });
        }
      },
      onExit: (d) {
        setState(() {
          hovered = false;
        });
      },
      child: Container(
        child: GestureDetector(
          onTap: stage.onCellTap == null
              ? null
              : () {
                  stage.onCellTap!(widget.position, context);
                },
          onTapUp: stage.onCellTapUp == null
              ? null
              : (details) {
                  stage.onCellTapUp!(widget.position, context);
                },
          onTapDown: stage.onCellTapDown == null
              ? null
              : (details) {
                  stage.onCellTapDown!(widget.position, context);
                },
          child: stage.drawCell(
              widget.position,
              stone != null && hovered
                  ? StoneWidget(
                      stone,
                      opacity: 0.6,
                      widget.position,
                    )
                  : null,
              context),
        ),
      ),
    );
  }
}
