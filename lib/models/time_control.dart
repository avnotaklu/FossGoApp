// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/core/utils/string_formatting.dart';
import 'package:go/models/game.dart';

final TimeControl blitz =
    TimeControl(mainTimeSeconds: 300, incrementSeconds: 0, byoYomiTime: null);

final TimeControl rapid =
    TimeControl(mainTimeSeconds: 1200, incrementSeconds: 0, byoYomiTime: null);

final TimeControl classical =
    TimeControl(mainTimeSeconds: 3600, incrementSeconds: 0, byoYomiTime: null);

class TimeControl {
  final int mainTimeSeconds;
  final int? incrementSeconds;
  final ByoYomiTime? byoYomiTime;

  TimeControl({
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

  factory TimeControl.fromMap(Map<String, dynamic> map) {
    return TimeControl(
      mainTimeSeconds: map[GameFieldNames.MainTimeSeconds] as int,
      incrementSeconds: map[GameFieldNames.IncrementSeconds] as int?,
      byoYomiTime: map[GameFieldNames.ByoYomiTime] != null
          ? ByoYomiTime.fromMap(
              map[GameFieldNames.ByoYomiTime] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TimeControl.fromJson(String source) =>
      TimeControl.fromMap(json.decode(source) as Map<String, dynamic>);

  String repr() {
    var repr = "";
    final mainTimeString =
        StringFormatting.totalSecondsToDurationRepr(mainTimeSeconds);
    repr += mainTimeString;
    if (incrementSeconds != null) {
      final incrementTimeString =
          StringFormatting.totalSecondsToDurationRepr(incrementSeconds!);
      repr += " + $incrementTimeString";
    }

    if (byoYomiTime != null) {
      repr += " + ${byoYomiTime!.byoYomis} x ${byoYomiTime!.byoYomiSeconds}s";
    }
    return repr;
  }
}

class ByoYomiTime {
  final int byoYomis;
  final int byoYomiSeconds;
  ByoYomiTime({
    required this.byoYomis,
    required this.byoYomiSeconds,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'byoYomis': byoYomis,
      'byoYomiSeconds': byoYomiSeconds,
    };
  }

  factory ByoYomiTime.fromMap(Map<String, dynamic> map) {
    return ByoYomiTime(
      byoYomis: map['byoYomis'] as int,
      byoYomiSeconds: map['byoYomiSeconds'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ByoYomiTime.fromJson(String source) =>
      ByoYomiTime.fromMap(json.decode(source) as Map<String, dynamic>);
}
