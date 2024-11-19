// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

final TimeControl blitz = TimeControl(
    suddenDeathSeconds: 300, incrementSeconds: 0, byoYomiTime: null);

final TimeControl rapid = TimeControl(
    suddenDeathSeconds: 1200, incrementSeconds: 0, byoYomiTime: null);

final TimeControl classical = TimeControl(
    suddenDeathSeconds: 3600, incrementSeconds: 0, byoYomiTime: null);

class TimeControl {
  final int suddenDeathSeconds;
  final int? incrementSeconds;
  final ByoYomiTime? byoYomiTime;

  TimeControl({
    required this.suddenDeathSeconds,
    this.incrementSeconds,
    this.byoYomiTime,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'suddenDeathSeconds': suddenDeathSeconds,
      'incrementSeconds': incrementSeconds,
      'byoYomiTime': byoYomiTime?.toMap(),
    };
  }

  factory TimeControl.fromMap(Map<String, dynamic> map) {
    return TimeControl(
      suddenDeathSeconds: map['suddenDeathSeconds'] as int,
      incrementSeconds: map['incrementSeconds'] != null
          ? map['incrementSeconds'] as int
          : null,
      byoYomiTime: map['byoYomiTime'] != null
          ? ByoYomiTime.fromMap(map['byoYomiTime'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TimeControl.fromJson(String source) =>
      TimeControl.fromMap(json.decode(source) as Map<String, dynamic>);
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
