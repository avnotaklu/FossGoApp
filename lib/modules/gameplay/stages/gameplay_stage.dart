import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart' as constants;
import 'package:go/models/game.dart';
import 'package:go/models/game_move.dart';
import 'package:go/modules/gameplay/game_state/board_state_bloc.dart';
import 'package:go/modules/gameplay/middleware/board_utility/stone.dart';
import 'package:go/modules/gameplay/middleware/score_calculation.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';
import 'package:go/modules/gameplay/playfield_interface/board.dart';
import 'package:go/modules/gameplay/stages/stage.dart';
import 'package:go/modules/gameplay/playfield_interface/stone_widget.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/game_ui.dart';
import 'package:go/models/position.dart';
import 'package:go/modules/settings/settings_provider.dart';
import 'package:go/services/move_position.dart';
import 'package:go/utils/stone_type.dart';
import 'package:provider/provider.dart';

class GameplayStage extends Stage {
  final GameStateBloc gameStateBloc;
  final BoardStateBloc boardStateBloc;

  GameplayStage(this.boardStateBloc, this.gameStateBloc);

  @override
  void initializeWhenAllMiddlewareAvailable(BuildContext context) {
    final gameStateBloc = context.read<GameStateBloc>();
    gameStateBloc.startPausedTimerOfActivePlayer();
    boardStateBloc.resetToReal();
    context.read<ScoreCalculationBloc>().calculateScore();
  }

  @override
  Widget drawCell(Position position, StoneWidget? stone, BuildContext context) {
    BoardStateBloc gameBoard = context.read();
    final boardStone = gameBoard.stoneAt(position);

    var player = boardStone?.toStoneType();

    if (gameStateBloc.intermediate != null &&
        position == gameStateBloc.intermediate!.pos) {
      player = StoneTypeExt.fromMoveNumber(gameStateBloc.playerTurn);
    }

    GameMove? move = gameStateBloc.game.moves.lastOrNull;
    var board = gameStateBloc.game.getBoardSize();

    return Stack(
      children: [
        if (player != null)
          StoneWidget(
            constants.playerColors[player.index],
            position,
          ),
        if (move?.toPosition() == position)
          Center(
            child: Padding(
              padding: EdgeInsets.all(board.circleIconPaddingForCells),
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Icon(
                    Icons.circle_outlined,
                    color: player!.other.materialColor,
                  ),
                ),
              ),
            ),
          ),
        Container(
          decoration: const BoxDecoration(color: Colors.transparent),
        ),
      ],
    );
  }

  @override
  void onClickCell(Position? position, BuildContext context) {
    makeMove(context, position);
  }

  static void makeMove(BuildContext context, Position? position) {
    SettingsProvider settings = context.read();
    GameStateBloc gameStatBloc = context.read();
    BoardStateBloc boardBloc = context.read();

    if (position != null) {
      if (settings.moveInput == MoveInputMode.immediate) {
        var move = gameStatBloc.placeStone(position, boardBloc);
        move.fold((l) {}, (r) {
          gameStatBloc.makeMove(r);
        });
      } else if (settings.moveInput == MoveInputMode.submitButton) {
        var move = gameStatBloc.placeStone(position, boardBloc);

        move.fold((l) {}, (r) {
          gameStatBloc.intermediate = r;
        });
      }
    }
  }

  @override
  void disposeStage() {
    // Empty
  }

  @override
  StageType get getType => StageType.gameplay;
}
