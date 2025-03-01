import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/models/game.dart';
import 'package:go/models/position.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/middleware/board_utility/stone.dart';
import 'package:go/modules/gameplay/middleware/board_utility/board_utilities.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';
import 'package:go/models/move_position.dart';

class BoardStateBloc extends ChangeNotifier {
  late BoardState board;
  final GameStateBloc gameState;

  MovePosition? _intermediate;
  bool intermediateIsPlayed = false;
  bool intermediateToBePlayed = false;

  // ignore: unnecessary_getters_setters
  MovePosition? get intermediate => _intermediate;

  set intermediate(MovePosition? pos) {
    _intermediate = pos;
    intermediateIsPlayed = false;
    intermediateToBePlayed = false;
    notifyListeners();
  }

  void updateBoard(BoardState b) {
    board = b;
    notifyListeners();
  }

  void resetToReal() {
    board = BoardStateUtilities(
      gameState.game.rows,
      gameState.game.columns,
    ).boardStateFromGame(gameState.game);

    intermediate = null;

    notifyListeners();
  }

  Stone? stoneAt(Position? pos) {
    return board.playgroundMap[pos];
  }

  BoardStateBloc(this.gameState, Game game) {
    setupGame(game);
  }

  void setupGame(Game game) {
    board = BoardStateUtilities(
      game.rows,
      game.columns,
    ).boardStateFromGame(game);
  }

  Either<AppError, MovePosition> placeStone(
      Position position, StoneLogic stoneLogic, StoneType newStone) {
    final tmpStoneLogic = stoneLogic.deepCopy();

    final canPlayMove =
        tmpStoneLogic.handleStoneUpdate(position, newStone).result;

    if (!canPlayMove) {
      return left(AppError(message: "You can't play here"));
    }

    // updateBoard(tmpStoneLogic.board);

    final move = MovePosition(
      x: position.x,
      y: position.y,
    );

    intermediate = move;

    return right(move);
  }
}
