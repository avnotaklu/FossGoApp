import 'package:flutter/material.dart';
import 'package:go/models/game.dart';
import 'package:go/models/position.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/middleware/board_utility/stone.dart';
import 'package:go/modules/gameplay/middleware/board_utility/board_utilities.dart';

class BoardStateBloc extends ChangeNotifier {
  late BoardState board;
  final GameStateBloc gameState;

  void updateBoard(BoardState b) {
    board = b;
    notifyListeners();
  }

  void resetToReal() {
    board = BoardStateUtilities(
      gameState.game.rows,
      gameState.game.columns,
    ).boardStateFromGame(gameState.game);

    gameState.intermediate = null;

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
}
