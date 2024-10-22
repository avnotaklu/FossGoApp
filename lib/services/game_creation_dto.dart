import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class GameCreationDto {
  final int rows;
  final int columns;
  final int timeInSeconds;

  GameCreationDto({
    required this.rows,
    required this.columns,
    required this.timeInSeconds,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'rows': rows,
      'columns': columns,
      'timeInSeconds': timeInSeconds,
    };
  }

  factory GameCreationDto.fromMap(Map<String, dynamic> map) {
    return GameCreationDto(
      rows: map['rows'] as int,
      columns: map['columns'] as int,
      timeInSeconds: map['timeInSeconds'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory GameCreationDto.fromJson(String source) => GameCreationDto.fromMap(json.decode(source) as Map<String, dynamic>);
}
