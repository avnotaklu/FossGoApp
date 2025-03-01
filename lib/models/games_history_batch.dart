// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/models/game.dart';
import 'package:go/models/game_and_opponent.dart';

extension GamesHistoryExt on GamesHistoryBatch {
  int get maxLength => 12;
  int get length => games.length;
}

class GamesHistoryBatch {
  final List<Game> games;
  GamesHistoryBatch({
    required this.games,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'games': games.map((x) => x.toMap()).toList(),
    };
  }

  factory GamesHistoryBatch.fromMap(Map<String, dynamic> map) {
    return GamesHistoryBatch(
      games: List<Game>.from(
        (map['games'] as List).map<Game>(
          (x) => Game.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory GamesHistoryBatch.fromJson(String source) =>
      GamesHistoryBatch.fromMap(json.decode(source) as Map<String, dynamic>);
}
