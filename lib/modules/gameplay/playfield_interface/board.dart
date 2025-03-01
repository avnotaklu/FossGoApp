import 'dart:math';

import 'package:go/constants/constants.dart' as Constants;
import 'package:flutter/material.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/models/game.dart';
import 'package:go/models/variant_type.dart';
import 'package:go/modules/gameplay/game_state/board_state_bloc.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/middleware/analysis_bloc.dart';
import 'package:go/modules/gameplay/stages/stage.dart';
import 'package:go/modules/settings/settings_provider.dart';
import 'package:go/models/move_position.dart';
import 'package:go/utils/board_size_data.dart';
import 'package:provider/provider.dart';
import 'package:test/test.dart';
import 'stone_widget.dart';
import '../../../models/position.dart';

import 'cell.dart';

class Board extends StatefulWidget {
  late int rows, cols;
  Map<Position?, StoneWidget?> playgroundMap = {};

  Board(this.rows, this.cols, Map<Position, StoneType> stonePos, {super.key}) {
    for (var i = 0; i < rows; i++) {
      for (var j = 0; j < cols; j++) {
        // playgroundMap[Position(i, j)] = Player(Colors.black);
        var tmpPos = Position(i, j);
        if (stonePos.keys.contains(tmpPos)) {
          final stoneType = stonePos[tmpPos]!;
          playgroundMap[Position(i, j)] = StoneWidget(
            stoneType,
            tmpPos,
          );
        } else {
          playgroundMap[Position(i, j)] = null;
        }
      }
    }
  }

  @override
  State<Board> createState() => _BoardState();
}

GlobalKey _boardKey = GlobalKey();

class _BoardState extends State<Board> {
  @override
  Widget build(BuildContext context) {
    double stoneInset = context.width / 35;
    double stoneSpacing = context.width /
        300; // Don't make spacing so large that to get that spacing Stones start to move out of position

    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final cons = BoxConstraints(
                maxWidth: min(constraints.maxWidth, constraints.maxHeight),
                maxHeight: min(constraints.maxWidth, constraints.maxHeight),
              );

              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        height: cons.maxHeight,
                        width: cons.maxWidth,
                        color: const Color(0xffE7A65A),
                      ),
                    ),
                  ),
                  Container(
                    height: cons.maxHeight,
                    width: cons.maxWidth,
                    child: BorderGrid(
                      GameBoardSpace(
                        cons,
                        stoneSpacing,
                        widget.rows,
                        widget.cols,
                        stoneInset,
                      ),
                    ),
                  ),
                  Consumer<BoardStateBloc>(
                    builder: (context, bloc, child) => Consumer<AnalysisBloc>(
                      builder: (context, bloc, child) => StoneLayoutGrid(
                        GameBoardSpace(
                          cons,
                          stoneSpacing,
                          widget.rows,
                          widget.cols,
                          stoneInset,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class BorderGrid extends StatelessWidget {
  final GameBoardSpace info;
  const BorderGrid(this.info, {super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BoardStateBloc>(
      builder: (context, boardState, child) => Consumer<SettingsProvider>(
        builder: (context, settings, child) => CustomPaint(
          painter: BorderPainter(
            info,
            showLeftTop: settings.notationPosition.showLeftTop,
            showRightBottom: settings.notationPosition.showRightBottom,
            intermediatePosition: boardState.intermediate,
            primaryColor: context.theme.colorScheme.primary,
            showCrosshair: settings.showCrosshair,
          ),
        ),
      ),
    );
  }
}

class BorderPainter extends CustomPainter {
  final GameBoardSpace info;
  final bool showLeftTop;
  final bool showRightBottom;
  final Color primaryColor;
  final MovePosition? intermediatePosition;
  final bool showCrosshair;

  Color get myColor => Colors.black;

  List<Position> get myDecorations =>
      Constants.boardCircleDecoration[info.board]!;

  BorderPainter(
    this.info, {
    required this.showLeftTop,
    required this.showRightBottom,
    required this.primaryColor,
    required this.intermediatePosition,
    required this.showCrosshair,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const bWidth = 0.5;

    // ignore: prefer_const_declarations

    final lineSize = size / info.rows.toDouble();

    final grid = info.rows * info.cols;

    final w = size.width;
    final h = size.height;

    final vOff = info.stoneInset +
        (((info.constraints.maxWidth / info.rows) / 2) - info.stoneSpacing);
    final hOff = vOff;

    var top = showLeftTop ? info.board.offsetEdgeLine : 0;
    var left = showLeftTop ? info.board.offsetEdgeLine : 0;
    var right = showRightBottom ? info.board.offsetEdgeLine : 0;
    var bottom = showRightBottom ? info.board.offsetEdgeLine : 0;

    // double vOff = (top - bottom).toDouble();
    // double hOff = (left - right).toDouble();

    final gw = size.width - hOff * 2 - top - bottom;
    final gh = size.height - vOff * 2 - left - right;

    final start_grid_x = hOff + left;
    final start_grid_y = vOff + top;

    var rowSep = (gh / info.rows);
    double extraRowSep = rowSep / (info.rows - 1);
    var totRowSep = rowSep + extraRowSep;

    for (var i = 0; i < info.rows; i++) {
      double thisRowY = i * totRowSep + start_grid_y;
      var isIntermediate =
          intermediatePosition != null && intermediatePosition!.x == i;

      var crosshairVisible = showCrosshair && isIntermediate;

      var color = crosshairVisible ? primaryColor : myColor;

      var strokeWidth = crosshairVisible
          ? bWidth * 5 * max(1, (size.width - 400) / 400) * 1.12
          : bWidth;

      var startX = crosshairVisible ? hOff : start_grid_x;

      var endX =
          crosshairVisible ? start_grid_x + gw + right : start_grid_x + gw;

      canvas.drawLine(
        Offset(startX, thisRowY),
        Offset(endX, thisRowY),
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke,
      );
    }

    var colSep = (gw / info.cols);
    double extraColSep = colSep / (info.cols - 1);
    var totColSep = colSep + extraColSep;

    for (var i = 0; i < info.cols; i++) {
      var thisColX = i * totColSep + start_grid_x;

      var isIntermediate =
          intermediatePosition != null && intermediatePosition!.y == i;

      var crosshairVisible = showCrosshair && isIntermediate;

      var color = crosshairVisible ? primaryColor : myColor;

      var strokeWidth = crosshairVisible
          ? bWidth * 5 * max(1, (size.width - 400) / 400) * 1.12
          : bWidth;

      var startY = crosshairVisible ? vOff : start_grid_y;

      var endY =
          crosshairVisible ? start_grid_y + gh + bottom : start_grid_y + gh;

      canvas.drawLine(
        Offset(thisColX, startY),
        Offset(thisColX, endY),
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke,
      );
    }

    for (var decPos in myDecorations) {
      drawDecoration(
        canvas,
        size,
        Offset(
          start_grid_x + totColSep * decPos.x,
          start_grid_y + totRowSep * decPos.y,
        ),
      );
    }

    var scaleAvailableWidth = max(1,
        ((size.width - 400) / 1200) + 1); // This stuff so text scales nicely;

    var fontSize =
        fontSizeFactor * size.width * 0.3 / info.rows / scaleAvailableWidth;

    TextPainter getTextPainter(String text) {
      var painter = TextPainter(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: myColor,
            fontSize: fontSize,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      painter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );

      return painter;
    }

    void paintNotationText(
        bool isIntermediate, Offset off, TextPainter textPainter) {
      if (isIntermediate && showCrosshair) {
        canvas.drawCircle(
            off +
                Offset(
                  textPainter.width / 2,
                  textPainter.height / 2,
                ),
            fontSize,
            Paint()..color = primaryColor);
      }

      textPainter.paint(
        canvas,
        Offset(
          off.dx,
          off.dy,
        ),
      );
    }

    if (showRightBottom || showLeftTop) {
      for (var i = 0; i < info.rows; i++) {
        var isIntermediate = intermediatePosition != null &&
            intermediatePosition!.x! == (i - info.rows + 1).abs();

        final textPainter = getTextPainter((i + 1).toString());

        final line = start_grid_y +
            ((info.rows - i - 1) * totRowSep) -
            textPainter.height / 2;
        if (showLeftTop) {
          paintNotationText(
            isIntermediate,
            Offset(textPainter.width / 2 + 4, line),
            textPainter,
          );
        }
        if (showRightBottom) {
          paintNotationText(
            isIntermediate,
            Offset(w - textPainter.width * 2, line),
            textPainter,
          );
        }
      }
      for (var i = 0; i < info.rows; i++) {
        var isIntermediate =
            intermediatePosition != null && intermediatePosition!.y == i;

        final char = String.fromCharCode('A'.runes.first + i);
        final iSkippedChar = String.fromCharCode(
            char.runes.first + ((char.runes.first >= 'I'.runes.first) ? 1 : 0));

        final textPainter = getTextPainter(iSkippedChar);

        final line = start_grid_x + (i * totColSep) - textPainter.width / 2;

        if (showLeftTop) {
          paintNotationText(
            isIntermediate,
            Offset(line, 0 + 4),
            textPainter,
          );
        }
        if (showRightBottom) {
          paintNotationText(
            isIntermediate,
            Offset(line, h - textPainter.height - 5),
            textPainter,
          );
        }
      }
    }
  }

  void drawDecoration(Canvas canvas, Size size, Offset center) {
    var paint = Paint()
      ..color = myColor
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, decorSize, paint);
  }

  double get decorSize => switch (info.board) {
        BoardSize.nine => 5,
        BoardSize.thirteen => 3,
        BoardSize.nineteen => 2,
        BoardSize.other => throw Exception("Can't draw decor for other boards"),
      };

  double get fontSizeFactor => switch (info.board) {
        BoardSize.nine => 1,
        BoardSize.thirteen => 1.2,
        BoardSize.nineteen => 1.4,
        BoardSize.other => throw Exception("Can't draw decor for other boards"),
      };

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class StoneLayoutGrid extends StatefulWidget {
  final GameBoardSpace info;

  const StoneLayoutGrid(this.info, {super.key} /*, this.playgroundMap*/);
  @override
  State<StoneLayoutGrid> createState() => _StoneLayoutGridState();
}

class _StoneLayoutGridState extends State<StoneLayoutGrid> {
  @override
  Widget build(BuildContext context) {
    var edgeOffset = widget.info.board.offsetEdgeLine;

    return Padding(
      padding: EdgeInsets.all(widget.info.stoneInset),
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          var boardSize = widget.info.board;

          var padding = widget.info.boardPadding(settings.notationPosition);

          var boardPanUpdateCallback = context.read<Stage>().onBoardPanUpdate;

          var boardPanEndCallback = context.read<Stage>().onBoardPanEnd;

          return GestureDetector(
            onPanEnd: boardPanEndCallback == null
                ? null
                : (loc) {
                    final pos = widget.info.from(loc.localPosition, padding);
                    boardPanEndCallback.call(pos, context);
                  },
            onPanUpdate: boardPanUpdateCallback == null
                ? null
                : (loc) {
                    final pos = widget.info.from(loc.localPosition, padding);
                    boardPanUpdateCallback.call(pos, context);
                  },
            child: Padding(
              padding: padding,
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: (widget.info.rows) * (widget.info.cols),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (widget.info.rows),
                  childAspectRatio: 1,
                  crossAxisSpacing: widget.info.stoneSpacing,
                  mainAxisSpacing: widget.info.stoneSpacing,
                ),
                itemBuilder: (context, index) => SizedBox(
                  child: Stack(
                    children: [
                      Cell(Position(((index) ~/ widget.info.cols),
                          ((index) % widget.info.rows).toInt())),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

extension NotationExts on NotationPosition {
  bool get showLeftTop =>
      this == NotationPosition.both || this == NotationPosition.onlyLeftTop;
  bool get showRightBottom =>
      this == NotationPosition.both || this == NotationPosition.onlyRightBotton;
}

extension BoardParams on BoardSize {
  double get offsetEdgeLine => switch (this) {
        BoardSize.nine => 14,
        BoardSize.thirteen => 12,
        BoardSize.nineteen => 6,
        BoardSize.other => throw Exception("Can't draw decor for other boards"),
      };

  double get crossIconPaddingForCells => switch (this) {
        BoardSize.nine => 0,
        BoardSize.thirteen => 0,
        BoardSize.nineteen => 0,
        BoardSize.other => throw Exception("Can't draw decor for other boards"),
      };

  double get circleIconPaddingForCells => switch (this) {
        BoardSize.nine => 6,
        BoardSize.thirteen => 4,
        BoardSize.nineteen => 2,
        BoardSize.other => throw Exception("Can't draw decor for other boards"),
      };

  double get notationHighlightCrosshairSize => switch (this) {
        BoardSize.nine => 12,
        BoardSize.thirteen => 8,
        BoardSize.nineteen => 6,
        BoardSize.other => throw Exception("Can't figure out highlight size"),
      };
}

extension BoardSizeDataExt on Constants.BoardSizeData {
  BoardSize get nonOtherBoardSize {
    var bSize = boardSize;

    if (bSize != BoardSize.other) {
      if ((rows + cols) / 2 < 9) {
        return BoardSize.nine;
      }

      if ((rows + cols) / 2 < 13) {
        return BoardSize.thirteen;
      }

      if ((rows + cols) / 2 < 19) {
        return BoardSize.nineteen;
      }

      return BoardSize.nineteen;
    }
    return bSize;
  }
}
