// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:go/models/game.dart';
import 'package:go/models/game_move.dart';

import 'package:go/models/position.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/middleware/board_utility/board_utilities.dart';
import 'package:go/modules/gameplay/middleware/board_utility/stone.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';

abstract interface class PrimaryLeafWithAlternatives {
  MoveLeaf? get primary;
  List<MoveLeaf> get alternatives;
}

abstract class MoveLeaf implements PrimaryLeafWithAlternatives {
  Position? get position;
  List<AlternativeMoveLeaf> get alternativeChildren;
  MoveLeaf? get parent;
  int get move;
}

class AlternativeMoveLeaf extends MoveLeaf {
  @override
  Position? position;
  @override
  List<AlternativeMoveLeaf> alternativeChildren;
  @override
  MoveLeaf? parent;
  @override
  int move;

  // PrimaryLeafWithAlternatives
  @override
  MoveLeaf? get primary => alternativeChildren.firstOrNull;
  @override
  List<MoveLeaf> get alternatives => alternativeChildren;

  AlternativeMoveLeaf({
    required this.position,
    required this.parent,
    required this.alternativeChildren,
    required this.move,
  });
}

class RealMoveLeaf extends MoveLeaf {
  @override
  Position? position;
  @override
  List<AlternativeMoveLeaf> alternativeChildren;
  @override
  MoveLeaf? parent;
  @override
  int move;

  RealMoveLeaf? child;

  // PrimaryLeafWithAlternatives
  @override
  MoveLeaf? get primary => child;
  @override
  List<MoveLeaf> get alternatives => alternativeChildren;

  RealMoveLeaf(
      {required this.position,
      required this.move,
      required this.parent,
      required this.alternativeChildren,
      required this.child});
}

class RootMove implements PrimaryLeafWithAlternatives {
  RealMoveLeaf? child;
  List<AlternativeMoveLeaf> alternativesChildren;

  // PrimaryLeafWithAlternatives
  MoveLeaf? get primary => child;
  List<MoveLeaf> get alternatives => alternativesChildren;

  RootMove({
    required this.child,
    required this.alternativesChildren,
  });
}

class AnalysisBloc extends ChangeNotifier {
  List<RealMoveLeaf> realMoves = [];
  RootMove start = RootMove(child: null, alternativesChildren: []);

  final GameStateBloc gameStateBloc;

  MoveLeaf? currentMove;
  StoneLogic stoneLogic;

  Game get game => gameStateBloc.game;

  AnalysisBloc(this.gameStateBloc)
      : stoneLogic = StoneLogic(gameStateBloc.game) {
    gameStateBloc.gameMoveStream.listen((event) {
      addReal(event.toPosition());
    });

    RealMoveLeaf? parent;
    for (var (idx, move) in game.moves.indexed) {
      final leaf = RealMoveLeaf(
        move: idx,
        position: move.toPosition(),
        alternativeChildren: [],
        parent: parent,
        child: null,
      );
      if (parent == null) {
        start.child = leaf;
      } else {
        parent.child = leaf;
      }
      parent = leaf;
    }
  }

  bool updateBoard(Position? position, int move) {
    var stone = move % 2 == 0 ? StoneType.black : StoneType.white;

    var res = stoneLogic.handleStoneUpdate(position, stone);
    return res.result;
  }

  void addAlternative(Position? position) {
    final move = ((currentMove?.move ?? -1) + 1); // null makes 0;
    if (!updateBoard(position, move)) {
      return;
    }

    final newMove = AlternativeMoveLeaf(
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

    // NOTE: We don't update board on real move, we should keep state of analyzed line
    // final res = updateBoard(position, move);
    // assert(res); // This is external stuff, so we assume it's correct

    var newMove = RealMoveLeaf(
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

  List<MoveLeaf> get currentLine {
    final List<MoveLeaf> line = [];
    MoveLeaf? current = currentMove;

    while (current != null) {
      line.add(current);
      current = current.parent;
    }

    return line.reversed.toList();
  }

  void setCurrentMove(MoveLeaf? move) {
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
    PrimaryLeafWithAlternatives cur = currentMove ?? start;
    if (cur.primary != null) {
      setCurrentMove(cur.primary!);
    }
  }

  StoneType? stoneAt(Position position) {
    return stoneLogic.stoneAt(position);
  }
}
