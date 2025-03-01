// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/models/position.dart';

enum DeadStoneState { Dead, Alive }

class EditDeadStoneClusterDto {
  final Position position;
  final DeadStoneState state;
  EditDeadStoneClusterDto({
    required this.position,
    required this.state,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'position': position.toMap(),
      'state': state.index,
    };
  }

  factory EditDeadStoneClusterDto.fromMap(Map<String, dynamic> map) {
    return EditDeadStoneClusterDto(
      position: Position.fromMap(map['position'] as Map<String, dynamic>),
      state: DeadStoneState.values[map['state'] as int],
    );
  }

  String toJson() => json.encode(toMap());

  factory EditDeadStoneClusterDto.fromJson(String source) =>
      EditDeadStoneClusterDto.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
