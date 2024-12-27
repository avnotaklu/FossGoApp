import 'package:go/models/position.dart';

class Cluster {
  Set<Position> data;
  Set<Position> freedomPositions;
  int freedoms;
  int player;
  Cluster(this.data, this.freedomPositions, this.freedoms, this.player);

  @override
  bool operator ==(other) {
    if (other is! Cluster) {
      return false;
    }
    return other.data == data &&
        other.freedoms == freedoms &&
        other.player == player &&
        other.freedomPositions == freedomPositions;
  }

  @override
  int get hashCode =>
      data.hashCode ^
      freedoms.hashCode ^
      player.hashCode ^
      freedomPositions.hashCode;

  Position smallestPosition() {
    Position smallest = data.first;
    for (Position pos in data) {
      smallest = smallest < pos ? pos : smallest;
    }
    return smallest;
  }
}
