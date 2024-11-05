// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'x': x,
      'y': y,
    };
  }

  factory Position.fromMap(Map<String, dynamic> map) {
    return Position(
      map['x'] as int,
      map['y'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Position.fromJson(String source) => Position.fromMap(json.decode(source) as Map<String, dynamic>);
}
