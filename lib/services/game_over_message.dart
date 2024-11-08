// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/services/signal_r_message.dart';

enum GameOverMethod {
  Timeout,
  Resign,
  Score,
  Abandon,
}

class GameOverMessage extends SignalRMessageType {
  final GameOverMethod method;
  final String? winnerId;

  GameOverMessage(this.method, this.winnerId);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'method': method.index,
      'winnerId': winnerId,
    };
  }

  factory GameOverMessage.fromMap(Map<String, dynamic> map) {
    return GameOverMessage(
      GameOverMethod.values[map['method'] as int],
      map['winnerId'] != null ? map['winnerId'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory GameOverMessage.fromJson(String source) =>
      GameOverMessage.fromMap(json.decode(source) as Map<String, dynamic>);
}
