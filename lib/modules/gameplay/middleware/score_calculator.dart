import 'package:go/models/position.dart';
import 'package:go/modules/gameplay/middleware/board_utility/cluster.dart';
import 'package:go/modules/gameplay/middleware/board_utility/stone.dart';
import 'package:go/modules/gameplay/middleware/stone_logic.dart';

class ScoreCalculator {
  Map<Position, Area> areaMap = {};
  List<int> _territoryScores = [];
  List<int> get territoryScores => List.unmodifiable(_territoryScores);
  Map<Position, Stone> virtualPlaygroundMap = {};
  Set<Cluster> deadClusters = {};
  List<int> prisoners;
  List<Position> deadStones;
  int rows;
  int cols;
  double komi;

  ScoreCalculator({
    required this.rows,
    required this.cols,
    required this.komi,
    required this.prisoners,
    required this.deadStones,
    required Map<Position, Stone> playground,
  }) {
    virtualPlaygroundMap = playground;
    deadClusters = {};

    for (var pos in deadStones) {
      var stone = playground[pos];
      if (stone != null) {
        deadClusters.add(stone.cluster);
      }
    }

    _calculateScore();
  }

  int getWinner() {
    var blackScore = _territoryScores[0] + prisoners[0];
    var whiteScore = _territoryScores[1] + prisoners[1] + komi;
    return (blackScore > whiteScore) ? 0 : 1;
  }

  void _calculateScore() {
    for (var cluster in deadClusters) {
      for (var pos in cluster.data) {
        virtualPlaygroundMap.remove(pos);
      }
    }

    _territoryScores = [0, 0];

    for (var i = 0; i < rows; i++) {
      for (var j = 0; j < cols; j++) {
        var pos = Position(i, j);
        if (!areaMap.containsKey(pos) &&
            !virtualPlaygroundMap.containsKey(pos)) {
          _forEachEmptyPosition(pos, {pos}, null, false, []);
        }
      }
    }

    for (var area in areaMap.values) {
      if (area.owner != null) {
        _territoryScores[area.owner!] += 1;
      }
    }
  }

  bool _checkIfInsideBounds(Position pos) {
    return pos.x >= 0 && pos.x < rows && pos.y >= 0 && pos.y < cols;
  }

  ({
    Set<Position> positionsSeenSoFar,
    int? owner,
    bool isDame,
    List<Cluster> clusterEncountered
  }) _forEachEmptyPosition(
    Position startPos,
    Set<Position> positionsSeenSoFar,
    int? owner,
    bool isDame,
    List<Cluster> clusterEncountered,
  ) {
    if (_checkIfInsideBounds(startPos)) {
      var stone = virtualPlaygroundMap[startPos];
      if (stone != null) {
        if (!clusterEncountered.contains(stone.cluster)) {
          clusterEncountered.add(stone.cluster);
          return (
            positionsSeenSoFar: positionsSeenSoFar,
            owner: owner,
            isDame: isDame,
            clusterEncountered: clusterEncountered
          );
        }
      }

      StoneLogic.doActionOnNeighbors(startPos, (curpos, neighbor) {
        if (_checkIfInsideBounds(neighbor)) {
          if (!virtualPlaygroundMap.containsKey(neighbor)) {
            if (!positionsSeenSoFar.contains(neighbor)) {
              var result = _forEachEmptyPosition(
                neighbor,
                {...positionsSeenSoFar, neighbor},
                owner,
                isDame,
                clusterEncountered,
              );
              positionsSeenSoFar = result.positionsSeenSoFar;
              owner = result.owner;
              isDame = result.isDame;
              clusterEncountered = result.clusterEncountered;
            }
          } else {
            var neighborStone = virtualPlaygroundMap[neighbor];
            if (neighborStone != null) {
              if (!clusterEncountered.contains(neighborStone.cluster)) {
                clusterEncountered.add(neighborStone.cluster);
              }
              if (owner == null && !isDame) {
                owner = neighborStone.player;
              } else if (owner != null && neighborStone.player != owner) {
                owner = null;
                isDame = true;
              }
            }
          }
        }
      });

      for (var pos in positionsSeenSoFar) {
        areaMap[pos] = Area(owner, positionsSeenSoFar);
      }
    }

    return (
      positionsSeenSoFar: positionsSeenSoFar,
      owner: owner,
      isDame: isDame,
      clusterEncountered: clusterEncountered
    );
  }
}

class Area {
  final int? owner;
  final Set<Position> positions;

  Area(this.owner, this.positions);
}
