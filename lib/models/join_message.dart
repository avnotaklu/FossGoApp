import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class JoinMessage {
  final String gameId;
  final String time;
  JoinMessage({
    required this.gameId,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'gameId': gameId,
      'time': time,
    };
  }

  factory JoinMessage.fromMap(Map<String, dynamic> map) {
    return JoinMessage(
      gameId: map['gameId'] as String,
      time: map['time'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory JoinMessage.fromJson(String source) => JoinMessage.fromMap(json.decode(source) as Map<String, dynamic>);
}
