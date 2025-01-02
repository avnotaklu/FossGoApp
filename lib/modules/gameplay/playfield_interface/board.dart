import 'package:go/constants/constants.dart' as Constants;
import 'package:flutter/material.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/models/game.dart';
import 'package:go/models/variant_type.dart';
import 'package:go/modules/gameplay/middleware/analysis_bloc.dart';
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
  GridInfo(this.constraints, this.stoneSpacing, this.rows, this.cols,
      this.stoneInset);
}

class BorderGrid extends StatelessWidget {
  final GridInfo info;
  const BorderGrid(this.info, {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BorderPainter(info),
    );
  }
}

class BorderPainter extends CustomPainter {
  final GridInfo info;

  Color get myColor => Colors.black;

  BoardSize get board =>
      Constants.BoardSizeData(info.rows, info.cols).boardSize;

  List<Position> get myDecorations => Constants.boardCircleDecoration[board]!;

  BorderPainter(this.info);

  @override
  void paint(Canvas canvas, Size size) {
    final bWidth = 0.5;

    // ignore: prefer_const_declarations
    final showNotationLeftTop = true;
    // ignore: prefer_const_declarations
    final showNotationRightBottom = true;

    final lineSize = size / info.rows.toDouble();

    final grid = info.rows * info.cols;

    final w = size.width;
    final h = size.height;

    final vOff = info.stoneInset +
        (((info.constraints.maxWidth / info.rows) / 2) - info.stoneSpacing);

    // final vOff = 0.0;

    final hOff = vOff;

    // final vOff = info.stoneInset;
    // final hOff = info.stoneInset;

    final gw = size.width - (hOff * 2);
    final gh = size.height - (vOff * 2);

    final paint = Paint()
      ..color = myColor
      ..strokeWidth = bWidth
      ..style = PaintingStyle.stroke;

    var rowSep = (gh / info.rows);
    double extraRowSep = rowSep / (info.rows - 1);
    var totRowSep = rowSep + extraRowSep;

    for (var i = 0; i < info.rows; i++) {
      double thisRowY = i * totRowSep + vOff;
      canvas.drawLine(
          Offset(hOff, thisRowY), Offset(w - hOff, thisRowY), paint);
    }

    var colSep = (gw / info.cols);
    double extraColSep = colSep / (info.cols - 1);
    var totColSep = colSep + extraColSep;
    for (var i = 0; i < info.cols; i++) {
      var thisColX = i * totColSep + hOff;

      canvas.drawLine(
          Offset(thisColX, vOff), Offset(thisColX, h - vOff), paint);
    }

    for (var decPos in myDecorations) {
      drawDecoration(canvas, size,
          Offset(hOff + totColSep * decPos.x, vOff + totRowSep * decPos.y));
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

    if (showNotationRightBottom || showNotationLeftTop) {
      for (var i = 0; i < info.rows; i++) {
        final textPainter = getTextPainter(i.toString());

        final line = vOff + (i * totRowSep) - textPainter.height / 2;
        if (showNotationLeftTop) {
          textPainter.paint(
            canvas,
            Offset(textPainter.width / 2 + 2, line),
          );
        }
        if (showNotationRightBottom) {
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

        final line = hOff + (i * totColSep) - textPainter.width / 2;

        if (showNotationLeftTop) {
          textPainter.paint(
            canvas,
            Offset(
              line,
              0 + 2,
            ),
          );
        }
        if (showNotationRightBottom) {
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

  double get decorSize => switch (board) {
        BoardSize.nine => 7,
        BoardSize.thirteen => 5,
        BoardSize.nineteen => 4,
        BoardSize.other => throw Exception("Can't draw decor for other boards"),
      };

  double get fontSize => switch (board) {
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
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(widget.info.stoneInset),
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
    );
  }
}
