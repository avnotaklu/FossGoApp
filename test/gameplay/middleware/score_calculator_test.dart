import 'package:go/constants/constants.dart';
import 'package:go/modules/gameplay/middleware/board_utility/board_utilities.dart';
import 'package:go/modules/gameplay/middleware/score_calculator.dart';
import 'package:test/test.dart';

void main() {
  group('Score Calculation Tests', () {
    test('Test Simple Score Calculation', () {
      final board = [
        [0, 0, 0, 0, 0],
        [0, 0, 0, 0, 1],
        [0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0],
      ];

      const rows = 5;
      const cols = 5;

      final bSize = BoardSizeData(rows, cols);

      final boardCons = BoardStateUtilities(rows, cols);

      final clusters = boardCons.getClusters(
        board,
      );
      final stones = boardCons.getStones(clusters);
      final boardState = BoardState.simplePositionalBoard(rows, cols, stones);

      final scoreCalc = ScoreCalculator(
        rows: rows,
        cols: cols,
        komi: 6.5, // Komi
        prisoners: [0, 0], // Initial scores
        deadStones: [], // Additional parameters, if needed
        playground: boardState.playgroundMap,
      );

      final score = scoreCalc.score;

      expect(score[0], equals(25));
      expect(score[1], equals(0));
    });

    test('Test Simple Score Calculation 2', () {
      final board = [
        [0, 0, 0, 1, 0],
        [0, 0, 1, 1, 1],
        [0, 0, 2, 1, 0],
        [0, 2, 0, 2, 0],
        [0, 0, 2, 0, 0],
      ];

      const rows = 5;
      const cols = 5;

      final bSize = BoardSizeData(rows, cols);

      final boardCons = BoardStateUtilities(rows, cols);

      final clusters = boardCons.getClusters(
        board,
      );
      final stones = boardCons.getStones(clusters);
      final boardState = BoardState.simplePositionalBoard(rows, cols, stones);

      final scoreCalc = ScoreCalculator(
        rows: rows,
        cols: cols,
        komi: 6.5, // Komi
        prisoners: [0, 0], // Initial scores
        deadStones: [], // Additional parameters, if needed
        playground: boardState.playgroundMap,
      );

      final score = scoreCalc.score;

      expect(score[0], equals(6));
      expect(score[1], equals(5));
    });

    test('Test Seki Score Calculation 2', () {
      // Define the board as a 2D list
      final board = [
        [1, 0, 2, 0, 2, 0],
        [0, 1, 2, 2, 2, 0],
        [2, 2, 1, 1, 1, 1],
        [0, 2, 1, 0, 0, 0],
        [2, 2, 1, 0, 0, 0],
        [1, 1, 1, 0, 0, 0],
      ];

      // Define board dimensions
      final boardSize = const BoardSizeData(6, 6);

      // Instantiate BoardStateUtilities and perform operations
      final boardCons = BoardStateUtilities(6, 6);

      final clusters = boardCons.getClusters(board);
      final stones = boardCons.getStones(clusters);
      final boardState = BoardState.simplePositionalBoard(
        boardSize.rows,
        boardSize.cols,
        stones,
      );

      final scoreCalc = ScoreCalculator(
        rows: boardSize.rows,
        cols: boardSize.cols,
        komi: 6.5,
        prisoners: [0, 0],
        deadStones: [],
        playground: boardState.playgroundMap,
      );

      // Get the calculated scores
      final score = scoreCalc.score;

      // Assertions to check correctness
      expect(score[0], equals(20));
      expect(score[1], equals(12));
    });
  });
}
