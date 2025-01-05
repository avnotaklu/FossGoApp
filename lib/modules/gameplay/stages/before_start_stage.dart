import 'package:flutter/material.dart';
import 'package:go/models/game.dart';
import 'package:go/modules/gameplay/game_state/board_state_bloc.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';
import 'package:go/modules/gameplay/stages/gameplay_stage.dart';
import 'package:go/modules/gameplay/stages/stage.dart';
import 'package:go/modules/gameplay/playfield_interface/stone_widget.dart';
import 'package:go/modules/gameplay/playfield_interface/gameui/game_ui.dart';
import 'package:go/models/position.dart';
import 'package:go/modules/settings/settings_provider.dart';
import 'package:provider/provider.dart';

// class BeforeStartStage extends Stage<BeforeStartStage> {
class BeforeStartStage extends Stage {
  BeforeStartStage()
      : super(
          onCellTapDown: _onTapDown(),
          onCellTapUp: _onTapUp(),
          onBoardPanUpdate: _onBoardPanUpdate(),
          onBoardPanEnd: _onBoardPanEnd(),
        );

  @override
  Widget drawCell(Position position, StoneWidget? stone, BuildContext context) {
    return Container(
      color: Colors.transparent,
    );
  }

  static Function(Position? position, BuildContext context) _onTapDown() =>
      (position, context) {
        GameStateBloc gameStatBloc = context.read();
        BoardStateBloc boardBloc = context.read();

        if (position != null && gameStatBloc.game.bothPlayersIn()) {
          gameStatBloc.placeStone(position, boardBloc);
        }
      };

  static Function(Position? position, BuildContext context)
      _onBoardPanUpdate() => (position, context) {
            GameStateBloc gameStatBloc = context.read();
            BoardStateBloc boardBloc = context.read();

            if (position != null && gameStatBloc.game.bothPlayersIn()) {
              var move = gameStatBloc.placeStone(position, boardBloc);

              move.fold((l) {
                gameStatBloc.resetBoard(boardBloc);
              }, (r) {});
            } else {
              gameStatBloc.resetBoard(boardBloc);
            }
          };

  static Function(Position? position, BuildContext context) _onTapUp() =>
      (position, context) {
        GameStateBloc gameStatBloc = context.read();
        BoardStateBloc boardBloc = context.read();
        SettingsProvider settings = context.read();

        if (position != null && gameStatBloc.game.bothPlayersIn()) {
          if (settings.moveInput == MoveInputMode.immediate) {
            var move = gameStatBloc.placeStone(position, boardBloc);
            move.fold((l) {}, (r) {
              gameStatBloc.makeMove(r, boardBloc);
            });
          }
        }
      };

  static Function(Position? position, BuildContext context) _onBoardPanEnd() =>
      (position, context) {
        GameStateBloc gameStatBloc = context.read();
        BoardStateBloc boardBloc = context.read();
        SettingsProvider settings = context.read();

        if (position != null && gameStatBloc.game.bothPlayersIn()) {
          if (settings.moveInput == MoveInputMode.immediate) {
            var move = boardBloc.intermediate;

            if (move != null) gameStatBloc.makeMove(move, boardBloc);
          }
        }
      };

  @override
  disposeStage() {}

  @override
  void initializeWhenAllMiddlewareAvailable(context) {}

  @override
  StageType get getType => StageType.beforeStart;
}
