import 'package:go/models/cluster.dart';
import 'package:go/models/game.dart';
import 'package:go/models/position.dart';
import 'package:go/models/stone.dart';
import 'package:go/playfield/board_utilities.dart';

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
}

class BoardStateUtilities {
  final int rows;
  final int cols;
  BoardStateUtilities(this.rows, this.cols);

  BoardState BoardStateFromGame(Game game) {
    var map = game.playgroundMap;

    var simpleB = SimpleBoardRepresentation(map);
    var clusters = GetClusters(simpleB);
    var stones = GetStones(clusters);
    var board = ConstructBoard(rows, cols, stones, game.koPositionInLastMove);

    return board;
  }

  BoardState BoardStateFromSimpleRepr(
      List<List<int>> simpleB, Position? koPosition) {
    var clusters = GetClusters(simpleB);
    var stones = GetStones(clusters);
    var board = ConstructBoard(rows, cols, stones, koPosition);

    return board;
  }

  List<List<int>> SimpleBoardRepresentation(HighLevelBoardRepresentation map) {
    List<List<int>> board = [];

    for (var item in map.entries) {
      var position = item.key;
      board[position.x][position.y] = item.value.index + 1;
    }

    return board;
  }

  List<Cluster> GetClusters(List<List<int>> board) {
    Map<Position, Cluster> clusters = {};

    void MergeClusters(Cluster a, Cluster b) {
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
        var curpos = new Position(i, j);

        List<Position> neighbors = [
          new Position(i - 1, j),
          new Position(i, j - 1),
          new Position(i, j + 1),
          new Position(i + 1, j),
        ];

        neighbors.removeWhere((p) => !checkIfInsideBounds(p));

        if (board[i][j] != 0) {
          for (var n in neighbors) {
            if (!clusters.containsKey(curpos)) {
              clusters[curpos] =
                  new Cluster({new Position(i, j)}, {}, 0, board[i][j] - 1);
            }
            if (board[n.x][n.y] == 0) {
              clusters[curpos]!.freedomPositions.add(n);
              clusters[curpos]!.freedoms =
                  clusters[curpos]!.freedomPositions.length;
            }

            if (board[i][j] == board[n.x][n.y] && clusters.containsKey(n)) {
              MergeClusters(clusters[curpos]!, clusters[n]!);
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

    // for (var cluster in clustersList)
    // {
    //     HashSet<Position> freedomPositions = [];
    //     for (var pos in cluster.data)
    //     {
    //         if ()

    //     }
    // }
    return clustersList;
  }

  List<Stone> GetStones(List<Cluster> clusters) {
    List<Stone> stones = [];
    for (var cluster in clusters) {
      for (var position in cluster.data) {
        stones.add(Stone(
            position: position, player: cluster.player, cluster: cluster));
      }
    }
    return stones;
  }

  BoardState ConstructBoard(int rows, int cols, List<Stone> stones,
      [Position? koDelete = null]) {
    return BoardState(
        rows: rows,
        cols: cols,
        koDelete: koDelete,
        playgroundMap:
            Map.fromEntries(stones.map((e) => MapEntry(e.position, e))),
        prisoners: [0, 0]);
  }

  HighLevelBoardRepresentation MakeHighLevelBoardRepresentationFromBoardState(
      BoardState boardState) {
    return boardState.playgroundMap
        .map((e, v) => MapEntry(e, StoneType.values[v.player]));
  }

  bool checkIfInsideBounds(Position pos) {
    return pos.x > -1 && pos.x < rows && pos.y < cols && pos.y > -1;
  }
}
