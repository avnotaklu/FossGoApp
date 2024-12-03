import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collection/collection.dart';
import 'package:go/models/game.dart';
import 'package:go/models/game_move.dart';
import 'package:go/models/position.dart';
import 'package:go/modules/gameplay/middleware/board_utility/board_utilities.dart';

void main() {
  group("Board Utilities", () {
    test("Simple board repr from high level repr", () {
      var boardState = BoardStateUtilities(5, 5);
      var board = boardState.simpleBoardRepresentation(
        _4_2_highLevelBoardRepresentation_5x5(),
      );

      var dp = DeepCollectionEquality();
      expect(true, dp.equals(board, _4_2_simpleBoardRepresentation_5x5()));
    });
  });
}

HighLevelBoardRepresentation _4_2_highLevelBoardRepresentation_5x5() {
  return {
    const Position(4, 2): StoneType.black,
  };
}

List<List<int>> _4_2_simpleBoardRepresentation_5x5() {
  return [
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 0, 1, 0, 0],
  ];
}


// Game gameConstructor(
//   List<List<int>> board,
//   DateTime startTime, [
//   List<GameMove> moves = const [],
//   List<int> scores = const [0, 0],
//   int timeInSeconds = 300,
// ]) {
//   var rows = board.length;
//   var cols = board[0].length;
//   var boardState = BoardStateUtilities(rows, cols);
//   Position? koPosition;
//   return Game(
//     gameId: "Test",
//     rows: rows,
//     columns: cols,
//     timeInSeconds: timeInSeconds, // 5 minutes
//     playgroundMap: boardState.MakeHighLevelBoardRepresentationFromBoardState(
//         boardState.BoardStateFromSimpleRepr(
//       board,
//       koPosition,
//     )),
//     moves: moves,
//     players: {"1": StoneType.black, "2": StoneType.white},
//     playerScores: {"1": scores[0], "2": scores[1]},
//     startTime: startTime,
//     koPositionInLastMove: koPosition,
//     gameState: GameState.playing,
//   );
// }

// final _1980Jan1_1_30PM = DateTime(1980, 1, 1, 13, 30);
