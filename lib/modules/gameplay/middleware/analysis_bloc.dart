// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go/models/game.dart';
import 'package:go/models/game_move.dart';

import 'package:go/models/position.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/middleware/board_utility/board_utilities.dart';
import 'package:go/modules/gameplay/middleware/board_utility/stone.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';

abstract interface class PrimaryChildWithAlternatives {
  MoveBranch? get primary;
  List<MoveBranch> get alternatives;
}

abstract class MoveBranch implements PrimaryChildWithAlternatives {
  Position? get position;
  List<AlternativeMoveBranch> get alternativeChildren;
  MoveBranch? get parent;
  int get move;
}

class AlternativeMoveBranch extends MoveBranch {
  @override
  Position? position;
  @override
  List<AlternativeMoveBranch> alternativeChildren;
  @override
  MoveBranch? parent;
  @override
  int move;

  // PrimaryLeafWithAlternatives
  @override
  MoveBranch? get primary => alternativeChildren.firstOrNull;
  @override
  List<MoveBranch> get alternatives => alternativeChildren;

  AlternativeMoveBranch({
    required this.position,
    required this.parent,
    required this.alternativeChildren,
    required this.move,
  });
}

class RealMoveBranch extends MoveBranch {
  @override
  Position? position;
  @override
  List<AlternativeMoveBranch> alternativeChildren;
  @override
  MoveBranch? parent;
  @override
  int move;

  RealMoveBranch? child;

  // PrimaryLeafWithAlternatives
  @override
  MoveBranch? get primary => child;
  @override
  List<MoveBranch> get alternatives => alternativeChildren;

  RealMoveBranch(
      {required this.position,
      required this.move,
      required this.parent,
      required this.alternativeChildren,
      required this.child});
}

class RootMove implements PrimaryChildWithAlternatives {
  RealMoveBranch? child;
  List<AlternativeMoveBranch> alternativesChildren;

  // PrimaryLeafWithAlternatives
  MoveBranch? get primary => child;
  List<MoveBranch> get alternatives => alternativesChildren;

  RootMove({
    required this.child,
    required this.alternativesChildren,
  });
}

class AnalysisBloc extends ChangeNotifier {
  List<RealMoveBranch> realMoves = [];
  RootMove start = RootMove(child: null, alternativesChildren: []);

  final GameStateBloc gameStateBloc;

  int highestLineDepth = 0;
  int highestMoveLevel = 0;
  final Map<int, int> moveLevel = {};

  MoveBranch? currentMove;
  StoneLogic stoneLogic;

  Game get game => gameStateBloc.game;

  AnalysisBloc(this.gameStateBloc)
      : stoneLogic = StoneLogic(gameStateBloc.game) {
    gameStateBloc.gameMoveStream.listen((event) {
      addReal(event.toPosition());
    });

    RealMoveBranch? parent;
    for (var (idx, move) in game.moves.indexed) {
      addReal(move.toPosition());
    }
  }

  bool updateBoard(Position? position, int move) {
    var stone = move % 2 == 0 ? StoneType.black : StoneType.white;

    var res = stoneLogic.handleStoneUpdate(position, stone);
    return res.result;
  }

  void addAlternative(Position? position) {
    final move = ((currentMove?.move ?? -1) + 1); // null makes 0;

    moveLevel[move] = (moveLevel[move] ?? 0) + 1;
    highestMoveLevel = max(highestMoveLevel, moveLevel[move]!);
    highestLineDepth = max(highestLineDepth, move);

    if (!updateBoard(position, move)) {
      return;
    }

    final newMove = AlternativeMoveBranch(
        position: position,
        parent: currentMove,
        alternativeChildren: [],
        move: move);
    if (currentMove == null) {
      start.alternativesChildren.add(newMove);
    } else {
      currentMove!.alternativeChildren.add(newMove);
    }
    notifyListeners();
  }

  void addReal(Position? position) {
    final move = realMoves.length;

    highestLineDepth = max(highestLineDepth, move);

    // NOTE: We don't update board on real move, we should keep state of analyzed line
    // final res = updateBoard(position, move);
    // assert(res); // This is external stuff, so we assume it's correct

    var newMove = RealMoveBranch(
      move: move,
      position: position,
      alternativeChildren: [],
      child: null,
      parent: realMoves.lastOrNull,
    );

    if (move == 0) {
      start.child = newMove;
    } else {
      realMoves.last.child = newMove;
    }

    realMoves.add(newMove);

    // NOTE: We don't update current move, we should keep state of analyzed line
    // currentMove = realMoves[move];

    notifyListeners();
  }

  List<MoveBranch> get currentLine {
    final List<MoveBranch> line = [];
    MoveBranch? current = currentMove;

    while (current != null) {
      line.add(current);
      current = current.parent;
    }

    return line.reversed.toList();
  }

  void setCurrentMove(MoveBranch? move) {
    currentMove = move;

    var curLine = currentLine;

    stoneLogic = StoneLogic.fromBoardState(
        BoardStateUtilities(game.rows, game.columns)
            .constructBoard(game.rows, game.columns, []));

    for (var pos in curLine) {
      final res = stoneLogic.handleStoneUpdate(
          pos.position, StoneTypeExt.fromMoveNumber(pos.move));
      assert(
        res.result,
      ); // This method sets an already existing valid move, stone logic can't fail
    }

    notifyListeners();
  }

  void backward() {
    if (currentMove != null) {
      setCurrentMove(currentMove!.parent);
    }
  }

  void forward() {
    PrimaryChildWithAlternatives cur = currentMove ?? start;
    if (cur.primary != null) {
      setCurrentMove(cur.primary!);
    }
  }

  StoneType? stoneAt(Position position) {
    return stoneLogic.stoneAt(position);
  }
}
