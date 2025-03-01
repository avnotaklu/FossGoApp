// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:go/models/variant_type.dart';
import 'package:go/models/time_control_dto.dart';

extension MatchableBoardSizesExtension on MatchableBoardSizes {
  String get boardName {
    switch (this) {
      case MatchableBoardSizes.nine:
        return '9x9';
      case MatchableBoardSizes.thirteen:
        return '13x13';
      case MatchableBoardSizes.nineteen:
        return '19x19';
    }
  }
}

extension BoardSizesExtensionForMatcheable on BoardSize {
  MatchableBoardSizes? get matchableBoardSize {
    switch (this) {
      case BoardSize.nine:
        return MatchableBoardSizes.nine;
      case BoardSize.thirteen:
        return MatchableBoardSizes.thirteen;
      case BoardSize.nineteen:
        return MatchableBoardSizes.nineteen;
      case BoardSize.other:
        return null;
    }
  }
}

enum MatchableBoardSizes {
  nine,
  thirteen,
  nineteen,
}

class FindMatchDto {
  final List<MatchableBoardSizes> boardSizes;
  final List<TimeControlDto> timeStandards;

  FindMatchDto({
    required this.boardSizes,
    required this.timeStandards,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'boardSizes': boardSizes.map((x) => x.index).toList(),
      'timeStandards': timeStandards.map((x) => x.toMap()).toList(),
    };
  }

  factory FindMatchDto.fromMap(Map<String, dynamic> map) {
    return FindMatchDto(
      boardSizes: List<MatchableBoardSizes>.from(
        (map['boardSizes'] as List<int>).map(
          (x) => MatchableBoardSizes.values[x],
        ),
      ),
      timeStandards: List<TimeControlDto>.from(
        (map['timeStandards'] as List<int>)
            .map<TimeControlDto>((x) => TimeControlDto.fromMap(map)),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory FindMatchDto.fromJson(String source) =>
      FindMatchDto.fromMap(json.decode(source) as Map<String, dynamic>);
}
