class Position {
  // Position(this.x,this.y);
  const Position(this.x, this.y);

  Position.fromString(String val)
      : x = int.parse(val.split(' ')[0]),
        y = int.parse(val.split(' ')[1]);

  bool operator <(Position other) {
    return other.x < x || other.y < y;
  }

  @override
  bool operator ==(other) {
    if (other is! Position) {
      return false;
    }
    return other.x == x && other.y == y;
  }

  @override
  String toString() {
    return "$x $y";
  }

  @override
  String toHighLevelRepr() {
    return "$x $y";
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
  final int x;
  final int y;
}
