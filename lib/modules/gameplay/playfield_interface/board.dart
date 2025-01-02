import 'package:go/constants/constants.dart' as Constants;
import 'package:flutter/material.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/models/game.dart';
import 'package:go/models/variant_type.dart';
import 'package:go/modules/gameplay/middleware/analysis_bloc.dart';
import 'package:go/modules/settings/settings_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
            stoneType == StoneType.black ? Colors.black : Colors.white,
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
    double stoneInset = 10;
    double stoneSpacing =
        2; // Don't make spacing so large that to get that spacing Stones start to move out of position

    //double boardInset = stoneInsetstoneSpacing;
    return Stack(
      alignment: Alignment.center,
      children: [
        InteractiveViewer(
          child: Center(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // return StatefulBuilder(
                //   builder: (BuildContext context, StateSetter setState) {
                //     print("${constraints.maxHeight}, ${constraints.maxWidth}");
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Container(
                          height: constraints.maxHeight,
                          width: constraints.maxWidth,
                          //color: Colors.black,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(Constants.assets['board']!),
                                fit: BoxFit.fill),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: constraints.maxWidth,
                      width: constraints.maxWidth,
                      child: BorderGrid(
                        GridInfo(
                          constraints,
                          stoneSpacing,
                          widget.rows,
                          widget.cols,
                          stoneInset,
                        ),
                      ),
                    ),
                    Consumer<AnalysisBloc>(
                      builder: (context, bloc, child) => StoneLayoutGrid(
                        GridInfo(
                          constraints,
                          stoneSpacing,
                          widget.rows,
                          widget.cols,
                          stoneInset,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        // context.read<GameStateBloc>()
        // Center(
        //   child: Text(
        //     "3",
        //     style: context.textTheme.headlineLarge?.copyWith(
        //       fontSize: context.height * 0.15,
        //       // color: Colors.black,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

class GridInfo {
  BoxConstraints constraints;
  double stoneSpacing;
  double stoneInset;
  int rows;
  int cols;

  BoardSize get board => Constants.BoardSizeData(rows, cols).boardSize;

  GridInfo(this.constraints, this.stoneSpacing, this.rows, this.cols,
      this.stoneInset);
}

class BorderGrid extends StatelessWidget {
  final GridInfo info;
  const BorderGrid(this.info, {super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) => CustomPaint(
        painter: BorderPainter(
          info,
          showLeftTop: settings.notationPosition.showLeftTop,
          showRightBottom: settings.notationPosition.showRightBottom,
        ),
      ),
    );
  }
}

class BorderPainter extends CustomPainter {
  final GridInfo info;
  final bool showLeftTop;
  final bool showRightBottom;

  Color get myColor => Colors.black;

  List<Position> get myDecorations =>
      Constants.boardCircleDecoration[info.board]!;

  BorderPainter(
    this.info, {
    required this.showLeftTop,
    required this.showRightBottom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bWidth = 0.5;

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

    final paint = Paint()
      ..color = myColor
      ..strokeWidth = bWidth
      ..style = PaintingStyle.stroke;

    var rowSep = (gh / info.rows);
    double extraRowSep = rowSep / (info.rows - 1);
    var totRowSep = rowSep + extraRowSep;

    for (var i = 0; i < info.rows; i++) {
      double thisRowY = i * totRowSep + start_grid_y;
      canvas.drawLine(
        Offset(start_grid_x, thisRowY),
        Offset(start_grid_x + gw, thisRowY),
        paint,
      );
    }

    var colSep = (gw / info.cols);
    double extraColSep = colSep / (info.cols - 1);
    var totColSep = colSep + extraColSep;

    for (var i = 0; i < info.cols; i++) {
      var thisColX = i * totColSep + start_grid_x;

      canvas.drawLine(
        Offset(thisColX, start_grid_y),
        Offset(thisColX, start_grid_y + gh),
        paint,
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

    TextPainter getTextPainter(String text) {
      var painter = TextPainter(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.black,
            fontFamily: GoogleFonts.spaceMono().fontFamily,
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

    if (showRightBottom || showLeftTop) {
      for (var i = 0; i < info.rows; i++) {
        final textPainter = getTextPainter(i.toString());

        final line = start_grid_y + (i * totRowSep) - textPainter.height / 2;
        if (showLeftTop) {
          textPainter.paint(
            canvas,
            Offset(textPainter.width / 2 + 4, line),
          );
        }
        if (showRightBottom) {
          textPainter.paint(
            canvas,
            Offset(w - 10 - textPainter.width / 2, line),
          );
        }
      }
      for (var i = 0; i < info.rows; i++) {
        final char = String.fromCharCode('A'.runes.first + i);
        final iSkippedChar = String.fromCharCode(
            char.runes.first + ((char.runes.first >= 'I'.runes.first) ? 1 : 0));

        final textPainter = getTextPainter(iSkippedChar);

        final line = start_grid_x + (i * totColSep) - textPainter.width / 2;

        if (showLeftTop) {
          textPainter.paint(
            canvas,
            Offset(
              line,
              0 + 4,
            ),
          );
        }
        if (showRightBottom) {
          textPainter.paint(
            canvas,
            Offset(
              line,
              h - 10 - textPainter.height / 2,
            ),
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
        BoardSize.nine => 7,
        BoardSize.thirteen => 5,
        BoardSize.nineteen => 4,
        BoardSize.other => throw Exception("Can't draw decor for other boards"),
      };

  double get fontSize => switch (info.board) {
        BoardSize.nine => 14,
        BoardSize.thirteen => 10,
        BoardSize.nineteen => 7,
        BoardSize.other => throw Exception("Can't draw decor for other boards"),
      };

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class BorderGridS extends StatelessWidget {
  GridInfo info;
  BorderGridS(this.info, {super.key});

  @override
  Widget build(BuildContext context) {
    final bWidth = 2.0;
    final showNotation = true;

    final grid = (info.rows - 1) * (info.cols - 1);

    return GridView.builder(
      shrinkWrap: true,
      padding: /*EdgeInsets.all(0)*/ EdgeInsets.all(info.stoneInset +
          (((info.constraints.maxWidth / info.rows) / 2) - info.stoneSpacing)),
      itemCount: grid,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: info.rows - 1,
          childAspectRatio: 1,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            /*color: Colors.transparent,*/
            border: Border(
              right: BorderSide(color: Colors.red, width: bWidth),
              bottom: BorderSide(color: Colors.red, width: bWidth),
              left: (index % (info.rows - 1) == 0)
                  ? BorderSide(color: Colors.red, width: bWidth)
                  : BorderSide.none,
              top: (index < (info.rows - 1))
                  ? BorderSide(color: Colors.red, width: bWidth)
                  : BorderSide.none,
            ),
          ),
        );
      },
    );
  }
}

class StoneLayoutGrid extends StatefulWidget {
  final GridInfo info;

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
        builder: (context, settings, child) => GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.only(
            top: settings.notationPosition.showLeftTop ? edgeOffset : 0,
            left: settings.notationPosition.showLeftTop ? edgeOffset : 0,
            right: settings.notationPosition.showRightBottom ? edgeOffset : 0,
            bottom: settings.notationPosition.showRightBottom ? edgeOffset : 0,
          ),
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
        BoardSize.nine => 8,
        BoardSize.thirteen => 12,
        BoardSize.nineteen => 6,
        BoardSize.other => throw Exception("Can't draw decor for other boards"),
      };
}
