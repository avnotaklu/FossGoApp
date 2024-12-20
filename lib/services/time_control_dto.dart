import 'dart:convert';

import 'package:go/core/foundation/duration.dart';
import 'package:go/models/game.dart';
import 'package:go/models/time_control.dart';
import 'package:go/models/variant_type.dart';

extension TimeControlDtoExt on TimeControlDto {
  TimeControl getTimeControl() {
    return TimeControl(
      mainTimeSeconds: mainTimeSeconds,
      incrementSeconds: incrementSeconds,
      byoYomiTime: byoYomiTime,
      timeStandard: TimeStandard.blitz,
    );
  }
}

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

  String simpleRepr() {
    final ms = mainTimeSeconds;
    final ins = incrementSeconds;
    final bys = byoYomiTime?.byoYomiSeconds;
    final byc = byoYomiTime?.byoYomis;

    if (ins == null && bys == null) {
      return '$ms';
    } else if (ins == null) {
      return '$ms+$bys x $byc';
    } else if (bys == null) {
      return '$ms+$ins';
    } else {
      throw Exception('Invalid time control');
    }
  }

  static TimeControlDto fromSimpleRepr(String repr) {
    final parts = repr.split('+');
    final mainTimeSeconds = int.parse(parts[0]);
    int? incrementSeconds;
    ByoYomiTime? byoYomiTime;

    if (parts.length == 1) {
      incrementSeconds = null;
      byoYomiTime = null;
    } else {
      final secondPart = parts[1].split('x');
      if (secondPart.length == 1) {
        incrementSeconds = int.parse(secondPart[0]);
        byoYomiTime = null;
      } else {
        incrementSeconds = null;
        byoYomiTime = ByoYomiTime(
          byoYomis: int.parse(secondPart[0]),
          byoYomiSeconds: int.parse(secondPart[1]),
        );
      }
    }

    return TimeControlDto(
      mainTimeSeconds: mainTimeSeconds,
      incrementSeconds: incrementSeconds,
      byoYomiTime: byoYomiTime,
    );
  }
}
