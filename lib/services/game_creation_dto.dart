import 'dart:convert';

import 'package:go/gameplay/create/stone_selection_widget.dart';
import 'package:go/models/game.dart';
import 'package:go/models/time_control.dart';
import 'package:go/services/time_control_dto.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class GameCreationDto {
  final int rows;
  final int columns;
  final TimeControlDto timeControl;
  final StoneSelectionType firstPlayerStone;

  GameCreationDto({
    required this.rows,
    required this.columns,
    required this.timeControl,
    required this.firstPlayerStone,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'rows': rows,
      'columns': columns,
      'timeControl': timeControl.toMap(),
      'firstPlayerStone': firstPlayerStone.index,
    };
  }

  factory GameCreationDto.fromMap(Map<String, dynamic> map) {
    return GameCreationDto(
      rows: map['rows'] as int,
      columns: map['columns'] as int,
      timeControl: TimeControlDto.fromMap(map['timeControl']),
      firstPlayerStone: StoneSelectionType.values[map['firstPlayerStone'] as int],
    );
  }

  String toJson() => json.encode(toMap());

  factory GameCreationDto.fromJson(String source) =>
      GameCreationDto.fromMap(json.decode(source) as Map<String, dynamic>);
}
