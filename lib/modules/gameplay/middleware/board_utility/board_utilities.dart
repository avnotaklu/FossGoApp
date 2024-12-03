// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:go/modules/gameplay/middleware/board_utility/cluster.dart';
import 'package:go/models/game.dart';
import 'package:go/models/position.dart';
import 'package:go/modules/gameplay/middleware/board_utility/stone.dart';
import 'package:go/modules/gameplay/middleware/board_utility/board_utilities.dart';

typedef HighLevelBoardRepresentation = Map<Position, StoneType>;

class BoardState {
  final int rows;
  final int cols;
  // koDelete assumes that this position was deleted in the last move by the opposing player
  final Position? koDelete;
  final List<int> prisoners;
  final Map<Position, Stone> playgroundMap;

  BoardState(
      {required this.rows,
      required this.cols,
      required this.koDelete,
      required this.prisoners,
      required this.playgroundMap});

  BoardState copyWith({
    int? rows,
    int? cols,
    Position? koDelete,
    List<int>? prisoners,
    Map<Position, Stone>? playgroundMap,
  }) {
    return BoardState(
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      koDelete: koDelete ?? this.koDelete,
      prisoners: prisoners ?? this.prisoners,
      playgroundMap: playgroundMap ?? this.playgroundMap,
    );
  }
}

class BoardStateUtilities {
  final int rows;
  final int cols;
  BoardStateUtilities(this.rows, this.cols);

  BoardState boardStateFromGame(Game game) {
    var map = game.playgroundMap;

    var simpleB = simpleBoardRepresentation(map);
    var clusters = getClusters(simpleB);
    var stones = getStones(clusters);
    var board = constructBoard(rows, cols, stones, game.koPositionInLastMove);

    return board;
  }

  BoardState boardStateFromSimpleRepr(
      List<List<int>> simpleB, Position? koPosition) {
    var clusters = getClusters(simpleB);
    var stones = getStones(clusters);
    var board = constructBoard(rows, cols, stones, koPosition);

    return board;
  }

  List<List<int>> simpleBoardRepresentation(HighLevelBoardRepresentation map) {
    List<List<int>> board =
        List.generate(cols, (i) => List.generate(rows, (i) => 0));
    // List<List<int>> board = List.filled(cols, List.filled(rows, 0));

    for (var item in map.entries) {
      var position = item.key;
      board[position.x][position.y] = item.value.index + 1;
    }

    return board;
  }

  List<Cluster> getClusters(List<List<int>> board) {
    Map<Position, Cluster> clusters = {};

    void mergeClusters(Cluster a, Cluster b) {
      a.data.addAll(b.data);
      a.freedomPositions.addAll(b.freedomPositions);
      a.freedoms = a.freedomPositions.length;
      // b.data = a.data;
      for (var pos in a.data) {
        clusters[pos] = a;
      }
    }

    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[i].length; j++) {
        var curpos = Position(i, j);

        List<Position> neighbors = [
          Position(i - 1, j),
          Position(i, j - 1),
          Position(i, j + 1),
          Position(i + 1, j),
        ];

        neighbors.removeWhere((p) => !checkIfInsideBounds(p));

        if (board[i][j] != 0) {
          for (var n in neighbors) {
            if (!clusters.containsKey(curpos)) {
              clusters[curpos] =
                  Cluster({Position(i, j)}, {}, 0, board[i][j] - 1);
            }
            if (board[n.x][n.y] == 0) {
              clusters[curpos]!.freedomPositions.add(n);
              clusters[curpos]!.freedoms =
                  clusters[curpos]!.freedomPositions.length;
            }

            if (board[i][j] == board[n.x][n.y] && clusters.containsKey(n)) {
              mergeClusters(clusters[curpos]!, clusters[n]!);
            }
          }
        }
      }
    }

    List<Cluster> clustersList = [];
    List<Position> traversed = [];

    for (var position in clusters.keys) {
      var cluster = clusters[position];
      if (!traversed.contains(position)) {
        traversed.addAll(cluster!.data);
        clustersList.add(cluster);
      }
    }
    return clustersList;
  }

  List<Stone> getStones(List<Cluster> clusters) {
    List<Stone> stones = [];
    for (var cluster in clusters) {
      for (var position in cluster.data) {
        stones.add(Stone(
            position: position, player: cluster.player, cluster: cluster));
      }
    }
    return stones;
  }

  BoardState constructBoard(int rows, int cols, List<Stone> stones,
      [Position? koDelete]) {
    return BoardState(
        rows: rows,
        cols: cols,
        koDelete: koDelete,
        playgroundMap:
            Map.fromEntries(stones.map((e) => MapEntry(e.position, e))),
        prisoners: [0, 0]);
  }

  HighLevelBoardRepresentation makeHighLevelBoardRepresentationFromBoardState(
      BoardState boardState) {
    return boardState.playgroundMap
        .map((e, v) => MapEntry(e, StoneType.values[v.player]));
  }

  bool checkIfInsideBounds(Position pos) {
    return pos.x > -1 && pos.x < rows && pos.y < cols && pos.y > -1;
  }
}
