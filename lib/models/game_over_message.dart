// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/models/game.dart';
import 'package:go/models/signal_r_message.dart';

extension GameOverMethodExt on GameOverMethod {
  String get displayString => switch (this) {
        GameOverMethod.Timeout => 'Timeout',
        GameOverMethod.Resign => 'Resignation',
        GameOverMethod.Score => 'Score',
        GameOverMethod.Abandon => 'Abandonment',
      };

  String displayStringWithScoreForWinner(Game game) => switch (this) {
        GameOverMethod.Timeout => 'Timeout',
        GameOverMethod.Resign => 'Resignation',
        GameOverMethod.Score =>
          '${game.finalScoreDifferenceForWinner()} Points',
        GameOverMethod.Abandon => 'Abandonment',
      };
}

enum GameOverMethod {
  Timeout("Timeout"),
  Resign("Resignation"),
  Score("Score"),
  Abandon("Abandonment"),
  ;

  final String actualName;

  const GameOverMethod(this.actualName);
}

class GameOverMessage extends SignalRMessageType {
  final GameOverMethod method;
  final Game game;

  GameOverMessage(this.method, this.game);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'method': method.index,
      'game': game.toMap(),
    };
  }

  factory GameOverMessage.fromMap(Map<String, dynamic> map) {
    return GameOverMessage(
      GameOverMethod.values[map['method'] as int],
      Game.fromMap(map['game'] as Map<String, dynamic>),
    );
  }

  @override
  String toJson() => json.encode(toMap());

  factory GameOverMessage.fromJson(String source) =>
      GameOverMessage.fromMap(json.decode(source) as Map<String, dynamic>);
}
