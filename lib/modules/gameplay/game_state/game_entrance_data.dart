// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/models/game.dart';
import 'package:go/modules/stats/stats_page.dart';
import 'package:go/services/game_and_opponent.dart';
import 'package:go/services/public_user_info.dart';
import 'package:go/services/signal_r_message.dart';

class GameEntranceData {
  final DateTime? joinTime;
  final PublicUserInfo? otherPlayerData;
  final Game game;

  GameEntranceData({
    required this.joinTime,
    this.otherPlayerData,
    required this.game,
  });

  factory GameEntranceData.fromGameAndOpponent(
      GameAndOpponent gameAndOpponent) {
    return GameEntranceData(
      joinTime: null,
      otherPlayerData: gameAndOpponent.opponent,
      game: gameAndOpponent.game,
    );
  }

  factory GameEntranceData.fromJoinMessage(GameJoinMessage joinMessage) {
    return GameEntranceData(
      joinTime: joinMessage.joinTime,
      otherPlayerData: joinMessage.otherPlayerData,
      game: joinMessage.game,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'joinTime': joinTime?.toIso8601String(),
      'otherPlayerData': otherPlayerData?.toMap(),
      'game': game.toMap(),
    };
  }

  factory GameEntranceData.fromMap(Map<String, dynamic> map) {
    return GameEntranceData(
      joinTime: map['joinTime'] != null
          ? DateTime.parse(map['joinTime'] as String)
          : null,
      otherPlayerData: map['otherPlayerData'] != null
          ? PublicUserInfo.fromMap(
              map['otherPlayerData'] as Map<String, dynamic>)
          : null,
      game: Game.fromMap(map['game'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory GameEntranceData.fromJson(String source) =>
      GameEntranceData.fromMap(json.decode(source) as Map<String, dynamic>);
}
