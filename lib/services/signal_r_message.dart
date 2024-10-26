// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/models/game.dart';

class SignalRMessage {
  final String type;
  final SignalRMessageType data;

  SignalRMessage({
    required this.type,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'data': data.toMap(),
    };
  }

  factory SignalRMessage.fromMap(Map<String, dynamic> map) {
    var type = map['type'] as String;
    return SignalRMessage(
      type: type,
      data: getSignalRMessageTypeFromMap(
        map['data'] as Map<String, dynamic>,
        type,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory SignalRMessage.fromJson(String source) =>
      SignalRMessage.fromMap(json.decode(source) as Map<String, dynamic>);
}

typedef SignalRMessageListRaw = List<Object?>;
typedef SignalRMessageList = List<SignalRMessage>;

extension SignalRMessageListExtension on SignalRMessageListRaw {
  SignalRMessageList get signalRMessageList {
    return map((e) => SignalRMessage.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}

SignalRMessageType getSignalRMessageTypeFromMap(
    Map<String, dynamic> map, String type) {
  switch (type) {
    case 'GameJoin':
      return GameJoinMessage.fromMap(map);
    case 'NewGame':
      return NewGameCreatedMessage.fromMap(map);
    default:
      throw Exception('Unknown signalR message type: $type');
  }
}

SignalRMessageType getSignalRMessageType(String json, String type) {
  switch (type) {
    case 'GameJoin':
      return GameJoinMessage.fromJson(json);
    default:
      throw Exception('Unknown signalR message type: $type');
  }
}

abstract class SignalRMessageType {
  Map<String, dynamic> toMap();
  String toJson();
}

class NewGameCreatedMessage extends SignalRMessageType {
  final Game game;
  NewGameCreatedMessage(this.game);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'game': game.toMap(),
    };
  }

  factory NewGameCreatedMessage.fromMap(Map<String, dynamic> map) {
    return NewGameCreatedMessage(
      Game.fromMap(map['game']),
    );
  }

  @override
  String toJson() => json.encode(toMap());

  factory NewGameCreatedMessage.fromJson(String source) =>
      NewGameCreatedMessage.fromMap(
          json.decode(source) as Map<String, dynamic>);
}

class GameJoinMessage extends SignalRMessageType {
  final String time;
  final List<PublicUserInfo> players;
  final Game game;
  GameJoinMessage({
    required this.time,
    required this.players,
    required this.game,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'time': time,
      'players': players.map((x) => x.toMap()).toList(),
      'game': game.toMap(),
    };
  }

  factory GameJoinMessage.fromMap(Map<String, dynamic> map) {
    return GameJoinMessage(
      time: map['time'] as String,
      players: List<PublicUserInfo>.from(
        (map['players']).map<PublicUserInfo>(
          (x) => PublicUserInfo.fromMap(x as Map<String, dynamic>),
        ),
      ),
      game: Game.fromMap(map['game'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory GameJoinMessage.fromJson(String source) =>
      GameJoinMessage.fromMap(json.decode(source) as Map<String, dynamic>);
}

class PublicUserInfo {
  final String email;
  final String id;

  PublicUserInfo(this.email, this.id);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'id': id,
    };
  }

  factory PublicUserInfo.fromMap(Map<String, dynamic> map) {
    return PublicUserInfo(
      map['email'] as String,
      map['id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory PublicUserInfo.fromJson(String source) =>
      PublicUserInfo.fromMap(json.decode(source) as Map<String, dynamic>);
}
