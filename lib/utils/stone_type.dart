import 'package:flutter/material.dart';
import 'package:go/models/game.dart';

import 'package:go/constants/constants.dart' as Constants;

extension StoneTypeExtPlus on StoneType {
  Color get materialColor {
    return this == StoneType.black
        ? Constants.playerColors[0]
        : Constants.playerColors[1];
  }

  String get imageFile {
    return this == StoneType.black
        ? Constants.stoneImages[0]
        : Constants.stoneImages[1];
  }
}
