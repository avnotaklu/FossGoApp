import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/models/position.dart';
import 'package:go/models/variant_type.dart';

import 'package:go/constants/constants.dart' as Constants;
import 'package:go/modules/gameplay/playfield_interface/board.dart';
import 'package:go/modules/settings/settings_provider.dart';

extension GridInfoExt on GameBoardSpace {
  Position? from(Offset localPosition, EdgeInsets padding) {
    if (checkIfInsideBounds(localPosition, padding)) {
      localPosition = localPosition.translate(-padding.left, -padding.top);

      final width = stoneLayoutWidth(padding);
      final height = stoneLayoutHeight(padding);

      final cellWidth = (width / cols);
      final cellHeight = (height / rows);

      final x = (localPosition.dx + cellWidth / 2) ~/ cellWidth;
      final y = (localPosition.dy + cellHeight / 2) ~/ cellHeight;

      if (x >= 0 && x < cols && y >= 0 && y < rows) {
        var pos = Position(y, x);
        debugPrint('Position: $pos');
        return pos;
      }

      return null;
    }
    return null;
  }

  bool checkIfInsideBounds(Offset localPosition, EdgeInsets padding) {
    return localPosition.dx >= 0 &&
        localPosition.dx <= stoneLayoutWidth(padding) &&
        localPosition.dy >= 0 &&
        localPosition.dy <= stoneLayoutHeight(padding);
  }

  EdgeInsets boardPadding(NotationPosition notationPosition) {
    final edgeOffset = board.offsetEdgeLine;

    return EdgeInsets.only(
      top: notationPosition.showLeftTop ? edgeOffset : 0,
      left: notationPosition.showLeftTop ? edgeOffset : 0,
      right: notationPosition.showRightBottom ? edgeOffset : 0,
      bottom: notationPosition.showRightBottom ? edgeOffset : 0,
    );
  }

  double stoneLayoutWidth(EdgeInsets padding) {
    return constraints.maxWidth - padding.left - padding.right;
  }

  double stoneLayoutHeight(EdgeInsets padding) {
    return constraints.maxHeight - padding.top - padding.bottom;
  }
}

class GameBoardSpace {
  BoxConstraints constraints;
  double stoneSpacing;
  double stoneInset;
  int rows;
  int cols;

  BoardSize get board => Constants.BoardSizeData(rows, cols).boardSize;
  Constants.BoardSizeData get boardSize => Constants.BoardSizeData(rows, cols);

  GameBoardSpace(this.constraints, this.stoneSpacing, this.rows, this.cols,
      this.stoneInset);
}
