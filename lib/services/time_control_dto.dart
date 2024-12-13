import 'dart:convert';

import 'package:go/core/foundation/duration.dart';
import 'package:go/models/game.dart';
import 'package:go/models/time_control.dart';

class TimeControlDto {
  final int mainTimeSeconds;
  final int? incrementSeconds;
  final ByoYomiTime? byoYomiTime;

  TimeControlDto({
    required this.mainTimeSeconds,
    this.incrementSeconds,
    this.byoYomiTime,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      GameFieldNames.MainTimeSeconds: mainTimeSeconds,
      GameFieldNames.IncrementSeconds: incrementSeconds,
      GameFieldNames.ByoYomiTime: byoYomiTime?.toMap(),
    };
  }

  factory TimeControlDto.fromMap(Map<String, dynamic> map) {
    return TimeControlDto(
      mainTimeSeconds: map[GameFieldNames.MainTimeSeconds] as int,
      incrementSeconds: map[GameFieldNames.IncrementSeconds] as int?,
      byoYomiTime: map[GameFieldNames.ByoYomiTime] != null
          ? ByoYomiTime.fromMap(
              map[GameFieldNames.ByoYomiTime] as Map<String, dynamic>)
          : null,
    );
  }
  String toJson() => json.encode(toMap());
  factory TimeControlDto.fromJson(String source) =>
      TimeControlDto.fromMap(json.decode(source) as Map<String, dynamic>);

  String repr() {
    var repr = "";
    final mainTimeString = Duration(seconds: mainTimeSeconds).smallRepr();
    repr += mainTimeString;
    if (incrementSeconds != null) {
      final incrementTimeString =
          Duration(seconds: incrementSeconds!).smallRepr();
      repr += " + $incrementTimeString";
    }

    if (byoYomiTime != null) {
      repr += " + ${byoYomiTime!.byoYomis} x ${byoYomiTime!.byoYomiSeconds}s";
    }
    return repr;
  }
}
