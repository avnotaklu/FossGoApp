import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/models/cluster.dart';
import 'package:go/models/game.dart';
import 'package:go/models/position.dart';
import 'package:go/models/stone.dart';
import 'package:go/playfield/board_utilities.dart';
import 'package:go/providers/create_game_provider.dart';
import 'package:go/providers/game_state_bloc.dart';

class GameBoardBloc extends ChangeNotifier {
  final Map<Position, Stone> _stones = {};
  Map<Position, Stone> get stones => Map.from(_stones);

  Game get game => gameStateBloc.game;
  final GameStateBloc gameStateBloc;

  late Position? koDelete;
  late List<int> prisoners;

  int get rows => game.rows;
  int get cols => game.columns;

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

  GameBoardBloc(this.gameStateBloc) {
    setupGame(game);
  }

  void setupGame(Game game) {
    koDelete = gameStateBloc.game.koPositionInLastMove;
    prisoners = game.playerIdsSorted.map((e) => game.prisoners[e]!).toList();

    var board = BoardStateUtilities(
      game.rows,
      game.columns,
    ).BoardStateFromGame(game);

    _stones.clear();
    _stones.addAll(board.playgroundMap);
  }
}
