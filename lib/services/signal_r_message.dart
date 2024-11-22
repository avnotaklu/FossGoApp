// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/models/game.dart';
import 'package:go/models/position.dart';
import 'package:go/services/available_game.dart';
import 'package:go/services/edit_dead_stone_dto.dart';
import 'package:go/services/game_over_message.dart';

class SignalRMessage {
  final String type;
  final SignalRMessageType? data;

  SignalRMessage({
    required this.type,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'data': data?.toMap(),
    };
  }

  factory SignalRMessage.fromMap(Map<String, dynamic> map) {
    var type = map['type'] as String;
    return SignalRMessage(
      type: type,
      data: map['data'] == null
          ? null
          : getSignalRMessageTypeFromMap(
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

SignalRMessageType? getSignalRMessageTypeFromMap(
    Map<String, dynamic> map, String type) {
  switch (type) {
    case SignalRMessageTypes.gameJoin:
      return GameJoinMessage.fromMap(map);
    case SignalRMessageTypes.newGame:
      return NewGameCreatedMessage.fromMap(map);
    case SignalRMessageTypes.newMove:
      return NewMoveMessage.fromMap(map);
    case SignalRMessageTypes.continueGame:
      return ContinueGameMessage.fromMap(map);
    case SignalRMessageTypes.editDeadStone:
      return EditDeadStoneMessage.fromMap(map);
    case SignalRMessageTypes.gameOver:
      return GameOverMessage.fromMap(map);
    case SignalRMessageTypes.scoreCaculationStarted:
      return null;
    case SignalRMessageTypes.acceptedScores:
      return null;
    default:
      throw Exception('Unknown signalR message type: $type');
  }
}

SignalRMessageType? getSignalRMessageType(String json, String type) {
  switch (type) {
    case SignalRMessageTypes.gameJoin:
      return GameJoinMessage.fromJson(json);
    case SignalRMessageTypes.newGame:
      return NewGameCreatedMessage.fromJson(json);
    case SignalRMessageTypes.newMove:
      return NewMoveMessage.fromJson(json);
    case SignalRMessageTypes.continueGame:
      return ContinueGameMessage.fromJson(json);
    case SignalRMessageTypes.editDeadStone:
      return EditDeadStoneMessage.fromJson(json);
    case SignalRMessageTypes.gameOver:
      return GameOverMessage.fromJson(json);
    case SignalRMessageTypes.scoreCaculationStarted:
      return null;
    case SignalRMessageTypes.acceptedScores:
      return null;
    default:
      throw Exception('Unknown signalR message type: $type');
  }
}

class SignalRMessageTypes {
  static const String newGame = "NewGame";
  static const String gameJoin = "GameJoin";
  static const String newMove = "NewMove";
  static const String continueGame = "ContinueGame";
  static const String editDeadStone = "EditDeadStone";
  static const String scoreCaculationStarted = "ScoreCaculationStarted";
  static const String acceptedScores = "AcceptedScores";
  static const String gameOver = "GameOver";
}

abstract class SignalRMessageType {
  Map<String, dynamic> toMap();
  String toJson();
}

class EditDeadStoneMessage extends SignalRMessageType {
  final Position position;
  final DeadStoneState state;
  final Game game;
  EditDeadStoneMessage({
    required this.position,
    required this.state,
    required this.game,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'position': position.toMap(),
      'state': state.index,
      'game': game.toMap(),
    };
  }

  factory EditDeadStoneMessage.fromMap(Map<String, dynamic> map) {
    return EditDeadStoneMessage(
      position: Position.fromMap(map['position'] as Map<String, dynamic>),
      state: DeadStoneState.values[map['state'] as int],
      game: Game.fromMap(map['game'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory EditDeadStoneMessage.fromJson(String source) =>
      EditDeadStoneMessage.fromMap(json.decode(source) as Map<String, dynamic>);
}

class ContinueGameMessage extends SignalRMessageType {
  final Game game;
  ContinueGameMessage({
    required this.game,
  });

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'game': game.toMap(),
    };
  }

  factory ContinueGameMessage.fromMap(Map<String, dynamic> map) {
    return ContinueGameMessage(
      game: Game.fromMap(map['game'] as Map<String, dynamic>),
    );
  }

  @override
  String toJson() => json.encode(toMap());

  factory ContinueGameMessage.fromJson(String source) =>
      ContinueGameMessage.fromMap(json.decode(source) as Map<String, dynamic>);
}

class NewMoveMessage extends SignalRMessageType {
  final Game game;
  NewMoveMessage(this.game);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'game': game.toMap(),
    };
  }

  factory NewMoveMessage.fromMap(Map<String, dynamic> map) {
    return NewMoveMessage(
      Game.fromMap(map['game'] as Map<String, dynamic>),
    );
  }

  @override
  String toJson() => json.encode(toMap());

  factory NewMoveMessage.fromJson(String source) =>
      NewMoveMessage.fromMap(json.decode(source) as Map<String, dynamic>);
}

class NewGameCreatedMessage extends SignalRMessageType {
  final AvailableGame game;
  NewGameCreatedMessage(this.game);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'game': game.toMap(),
    };
  }

  factory NewGameCreatedMessage.fromMap(Map<String, dynamic> map) {
    return NewGameCreatedMessage(
      AvailableGame.fromMap(map['game']),
    );
  }

  @override
  String toJson() => json.encode(toMap());

  factory NewGameCreatedMessage.fromJson(String source) =>
      NewGameCreatedMessage.fromMap(
          json.decode(source) as Map<String, dynamic>);
}

class GameJoinMessage extends SignalRMessageType {
  final DateTime time;
  final PublicUserInfo? otherPlayerData;
  final Game game;
  GameJoinMessage({
    required this.time,
    required this.otherPlayerData,
    required this.game,
  });

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'time': time.toString(),
      'otherPlayerData': otherPlayerData?.toMap(),
      'game': game.toMap(),
    };
  }

  factory GameJoinMessage.fromMap(Map<String, dynamic> map) {
    return GameJoinMessage(
      time: DateTime.parse(map['time'] as String),
      otherPlayerData: map['otherPlayerData'] == null ? null : PublicUserInfo.fromMap(
          map['otherPlayerData'] as Map<String, dynamic>),
      game: Game.fromMap(map['game'] as Map<String, dynamic>),
    );
  }

  @override
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
