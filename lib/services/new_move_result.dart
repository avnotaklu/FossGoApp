import 'dart:convert';

import 'package:go/models/game.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class NewMoveResult {
  final Game game;
  final bool result;
  NewMoveResult({
    required this.game,
    required this.result,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'game': game.toMap(),
      'result': result,
    };
  }

  factory NewMoveResult.fromMap(Map<String, dynamic> map) {
    return NewMoveResult(
      game: Game.fromMap(map['game'] as Map<String, dynamic>),
      result: map['result'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory NewMoveResult.fromJson(String source) =>
      NewMoveResult.fromMap(json.decode(source) as Map<String, dynamic>);
}
