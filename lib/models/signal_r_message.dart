// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/models/game.dart';
import 'package:go/models/position.dart';
import 'package:go/models/available_game.dart';
import 'package:go/models/edit_dead_stone_dto.dart';
import 'package:go/models/find_match_result.dart';
import 'package:go/models/game_and_opponent.dart';
import 'package:go/models/game_over_message.dart';
import 'package:go/models/public_user_info.dart';
import 'package:go/models/stat_update_message.dart';

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
    case SignalRMessageTypes.matchFound:
      return GameJoinMessage.fromMap(map);
    case SignalRMessageTypes.gameStart:
      return GameStartMessage.fromMap(map);
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
    case SignalRMessageTypes.gameTimerUpdate:
      return GameTimerUpdateMessage.fromMap(map);
    case SignalRMessageTypes.statUpdate:
      return StatUpdateMessage.fromMap(map);
    case SignalRMessageTypes.opponentConnection:
      return ConnectionStrength.fromMap(map);
    case SignalRMessageTypes.scoreCaculationStarted:
      return null;
    case SignalRMessageTypes.acceptedScores:
      return null;
    case SignalRMessageTypes.pong:
      return null;
    default:
      throw Exception('Unknown signalR message type: $type');
  }
}

SignalRMessageType? getSignalRMessageType(String json, String type) {
  switch (type) {
    case SignalRMessageTypes.gameJoin:
      return GameJoinMessage.fromJson(json);
    case SignalRMessageTypes.matchFound:
      return GameJoinMessage.fromJson(json);
    case SignalRMessageTypes.gameStart:
      return GameStartMessage.fromJson(json);
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
    case SignalRMessageTypes.gameTimerUpdate:
      return GameTimerUpdateMessage.fromJson(json);
    case SignalRMessageTypes.statUpdate:
      return StatUpdateMessage.fromJson(json);
    case SignalRMessageTypes.opponentConnection:
      return ConnectionStrength.fromJson(json);
    case SignalRMessageTypes.scoreCaculationStarted:
      return null;
    case SignalRMessageTypes.acceptedScores:
      return null;
    case SignalRMessageTypes.pong:
      return null;
    default:
      throw Exception('Unknown signalR message type: $type');
  }
}

class SignalRMessageTypes {
  static const String newGame = "NewGame";
  static const String gameJoin = "GameJoin";
  static const String gameStart = "GameStart";
  static const String newMove = "NewMove";
  static const String continueGame = "ContinueGame";
  static const String editDeadStone = "EditDeadStone";
  static const String scoreCaculationStarted = "ScoreCaculationStarted";
  static const String acceptedScores = "AcceptedScores";
  static const String gameOver = "GameOver";
  static const String gameTimerUpdate = "GameTimerUpdate";
  static const String matchFound = "MatchFound";
  static const String statUpdate = "StatUpdate";
  static const String opponentConnection = "OpponentConnection";
  static const String pong = "Pong";
}

abstract class SignalRMessageType {
  Map<String, dynamic> toMap();
  String toJson();
}

class GameTimerUpdateMessage extends SignalRMessageType {
  final PlayerTimeSnapshot currentPlayerTime;
  final StoneType player;
  GameTimerUpdateMessage({
    required this.currentPlayerTime,
    required this.player,
  });

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'currentPlayerTime': currentPlayerTime.toMap(),
      'player': player.index,
    };
  }

  factory GameTimerUpdateMessage.fromMap(Map<String, dynamic> map) {
    return GameTimerUpdateMessage(
      currentPlayerTime: PlayerTimeSnapshot.fromMap(
          map['currentPlayerTime'] as Map<String, dynamic>),
      player: StoneType.values[map['player'] as int],
    );
  }

  @override
  String toJson() => json.encode(toMap());

  factory GameTimerUpdateMessage.fromJson(String source) =>
      GameTimerUpdateMessage.fromMap(
          json.decode(source) as Map<String, dynamic>);
}

extension ConnectionStrengthExt on ConnectionStrength {
  bool get isStrong => ping < 500;

  int get level {
    if (ping < 300) {
      return 3;
    } else if (ping < 400) {
      return 2;
    } else if (ping < 500) {
      return 1;
    } else {
      return 0;
    }
  }
}

class ConnectionStrength extends SignalRMessageType {
  final int ping;
  ConnectionStrength({
    required this.ping,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ping': ping,
    };
  }

  factory ConnectionStrength.fromMap(Map<String, dynamic> map) {
    return ConnectionStrength(
      ping: map['ping'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ConnectionStrength.fromJson(String source) =>
      ConnectionStrength.fromMap(json.decode(source) as Map<String, dynamic>);
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

  @override
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

  @override
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

class GameStartMessage extends SignalRMessageType {
  final Game game;
  GameStartMessage({
    required this.game,
  });

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'game': game.toMap(),
    };
  }

  factory GameStartMessage.fromMap(Map<String, dynamic> map) {
    return GameStartMessage(
      game: Game.fromMap(map['game'] as Map<String, dynamic>),
    );
  }

  @override
  String toJson() => json.encode(toMap());

  factory GameStartMessage.fromJson(String source) =>
      GameStartMessage.fromMap(json.decode(source) as Map<String, dynamic>);
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

extension GameJoinMessageExt on GameJoinMessage {
  GameAndOpponent? getGameAndOpponent() {
    return otherPlayerData == null
        ? null
        : GameAndOpponent(
            game: game,
            opponent: otherPlayerData!,
          );
  }
}

class GameJoinMessage extends SignalRMessageType {
  final DateTime joinTime;
  final PublicUserInfo? otherPlayerData;
  final Game game;
  GameJoinMessage({
    required this.joinTime,
    required this.otherPlayerData,
    required this.game,
  });

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'joinTime': joinTime.toString(),
      'otherPlayerData': otherPlayerData?.toMap(),
      'game': game.toMap(),
    };
  }

  factory GameJoinMessage.fromMap(Map<String, dynamic> map) {
    return GameJoinMessage(
      joinTime: DateTime.parse(map['joinTime'] as String).toLocal(),
      otherPlayerData: map['otherPlayerData'] == null
          ? null
          : PublicUserInfo.fromMap(
              map['otherPlayerData'] as Map<String, dynamic>),
      game: Game.fromMap(map['game'] as Map<String, dynamic>),
    );
  }

  @override
  String toJson() => json.encode(toMap());

  factory GameJoinMessage.fromJson(String source) =>
      GameJoinMessage.fromMap(json.decode(source) as Map<String, dynamic>);
}
