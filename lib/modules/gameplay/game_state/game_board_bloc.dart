
import 'package:flutter/material.dart';
import 'package:go/models/game.dart';
import 'package:go/models/position.dart';
import 'package:go/modules/gameplay/middleware/board_utility/stone.dart';
import 'package:go/modules/gameplay/middleware/board_utility/board_utilities.dart';

class GameBoardBloc extends ChangeNotifier {
  final Map<Position, Stone> _stones = {};
  Map<Position, Stone> get stones => Map.from(_stones);

  late Position? koDelete;
  late List<int> prisoners;

  final int rows;
  final int cols;

  Stone? stoneAt(Position? pos) {
    if (pos == null) {
      return null;
    }

    return _stones[pos];
  }

  void setStoneAt(Position pos, Stone stone) {
    _stones[pos] = stone;
    notifyListeners();
  }

  void removeStoneAt(Position pos) {
    _stones.remove(pos);
    notifyListeners();
  }

  bool checkIfInsideBounds(Position pos) {
    return pos.x > -1 && pos.x < rows && pos.y < cols && pos.y > -1;
  }

  GameBoardBloc(Game game)
      : rows = game.rows,
        cols = game.columns {
    setupGame(game);
  }

  void setupGame(Game game) {
    koDelete = game.koPositionInLastMove;
    prisoners = game
        .prisoners; //  game.playerIdsSorted.map((e) => game.prisoners[e]!).toList();

    var board = BoardStateUtilities(
      game.rows,
      game.columns,
    ).boardStateFromGame(game);

    _stones.clear();
    _stones.addAll(board.playgroundMap);
  }
}
