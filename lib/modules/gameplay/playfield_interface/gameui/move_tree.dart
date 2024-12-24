import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/constants/constants.dart' as Constants;
import 'package:go/modules/gameplay/middleware/analysis_bloc.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class TreeDimens {
  static const double circle_dia = 26;
  static const double parent_child_dist = 24;

  static double get node_vertical_extent => circle_dia + parent_child_dist;

  static const double siblings_dist = 16;
  static const double selected_circle_dia = 30;

  static double get node_horizontal_extent => circle_dia + siblings_dist;

  static const double bottom_relaxation = 50;
  static const double top_relaxation = 10;
  static const double left_relaxation = 10;
  static const double right_relaxation = 10;
}

class MoveTree extends StatelessWidget {
  final RootMove root;
  final TransformationController _transformationController =
      TransformationController();

  final Map<Rect, MoveBranch> interactionRectForMoves = {};
  final List<Rect> allInteractionRects = [];

  MoveTree({required this.root, super.key});

  Offset transformPosToInteractiveViewerViewport(Offset pos) {
    final mat = _transformationController.value;
    final vec = vector.Vector3(pos.dx, pos.dy, 0);

    final transformed = mat.transformed3(vec);

    return Offset(transformed.x, transformed.y);
  }

  Rect transformRectToInteractiveViewerViewport(Rect rec) {
    var center = rec.center;
    final mat = _transformationController.value;
    final vec = vector.Vector3(center.dx, center.dy, 0);

    final transformed = mat.transformed3(vec);

    return Rect.fromCenter(
      center: Offset(transformed.x, transformed.y),
      width: rec.width,
      height: rec.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // backgroundColor: context.theme.colorScheme.surfaceContainerLow,
      color: context.theme.colorScheme.surfaceContainerHigh,
      child: Consumer<AnalysisBloc>(
        builder: (context, bloc, child) => InteractiveViewer(
          transformationController: _transformationController,
          constrained: false,
          child: SizedBox(
            child: GestureDetector(
              onTapDown: (details) {
                final box = context.findRenderObject() as RenderBox;
                final offset = box.globalToLocal(details.globalPosition);
                final tOffset = offset;
                // final tOffset = transformPosToInteractiveViewerViewport(offset);
                // final offset = details.globalPosition;

                // final tOffset = transformPosToInteractiveViewerViewport(offset);

                final index = allInteractionRects.indexWhere((rect) =>
                    transformRectToInteractiveViewerViewport(rect)
                        .contains(tOffset));
                if (index != -1) {
                  bloc.setCurrentMove(
                      interactionRectForMoves[allInteractionRects[index]]!);
                  return;
                }
                // onSelected(-1);
              },
              child: CustomPaint(
                size: Size(
                    max(
                      context.width * 0.6,
                      calculateMaxWidth(bloc),
                    ),
                    max(
                      context.height * 0.8,
                      calculateMaxHeight(bloc),
                    )),
                painter: MoveCanvas(
                  root: root,
                  realMoves: bloc.realMoves,
                  currentMove: bloc.currentMove,
                  currentLine: bloc.currentLine,

                  interactionRectForMoves: interactionRectForMoves,
                  allInteractionRects: allInteractionRects,

                  // colors
                  surfaceHighest:
                      context.theme.colorScheme.surfaceContainerHighest,
                  // ignore: deprecated_member_use
                  surface: context.theme.colorScheme.surfaceVariant,
                  onSurface: context.theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double calculateMaxWidth(AnalysisBloc bloc) {
    return TreeDimens.node_horizontal_extent * bloc.highestMoveLevel +
        TreeDimens.left_relaxation +
        TreeDimens.right_relaxation /* relaxation */;
  }

  double calculateMaxHeight(AnalysisBloc bloc) {
    return TreeDimens.node_vertical_extent * bloc.highestLineDepth +
        TreeDimens.top_relaxation +
        TreeDimens.bottom_relaxation /* relaxation */;
  }
}

class MoveCanvas extends CustomPainter {
  final RootMove root;
  final List<RealMoveBranch> realMoves;
  final MoveBranch? currentMove;
  final List<MoveBranch> currentLine;

  final Color surfaceHighest;
  final Color surface;
  final Color onSurface;

  Map<int, int> moveLevel = {};

  final Map<Rect, MoveBranch> interactionRectForMoves;
  final List<Rect> allInteractionRects;

  MoveCanvas({
    required this.root,
    required this.realMoves,
    required this.currentMove,
    required this.currentLine,
    required this.surfaceHighest,
    required this.surface,
    required this.onSurface,
    required this.interactionRectForMoves,
    required this.allInteractionRects,
  });

  @override
  void paint(Canvas canvas, Size size) {
    moveLevel = {};
    drawRealNodes(canvas, realMoves);
  }

  Offset toTopLeft(Offset start) {
    return Offset(start.dx - TreeDimens.circle_dia / 2, start.dy);
  }

  Offset getNodeStartOffset(MoveBranch alt, [int? parentLevel]) {
    double v_node_extent = TreeDimens.node_vertical_extent;
    double h_node_extent = TreeDimens.node_horizontal_extent;

    double rad = TreeDimens.circle_dia / 2;

    int moveL = max(parentLevel ?? 0, (moveLevel[alt.move] ?? 0));

    double gap_top = TreeDimens.top_relaxation + v_node_extent * alt.move;
    double gap_left = TreeDimens.left_relaxation + h_node_extent * moveL;

    return Offset(gap_left + rad, gap_top);
  }

  Offset toNodeEnd(Offset start) {
    return Offset(start.dx, start.dy + TreeDimens.circle_dia);
  }

  Offset toNodeCenter(Offset start) {
    return Offset(start.dx, start.dy + TreeDimens.circle_dia / 2);
  }

  void drawRealNodes(Canvas canvas, List<RealMoveBranch> reals) {
    var rev_reals = reals.reversed;

    for (var node in rev_reals.indexed) {
      var start = getNodeStartOffset(node.$2);
      var center = toNodeCenter(start);

      if (node.$2.parent != null) {
        var parentStart = getNodeStartOffset(node.$2.parent!);
        var parentEnd = toNodeEnd(parentStart);
        drawArrow(canvas, start, parentEnd, node.$2);
      }

      drawMoveNode(canvas, start, node.$2);

      for (var child_branch in node.$2.alternativeChildren) {
        drawAlternativeMoveBranch(canvas, child_branch, 0);
      }
    }
  }

  /// Returns the start of newly drawn branch
  void drawAlternativeMoveBranch(
      Canvas canvas, AlternativeMoveBranch branch, int parentLevel) {
    final prevLevel = moveLevel[branch.move] ?? 0;
    moveLevel[branch.move] = prevLevel + 1;

    final start = getNodeStartOffset(branch, parentLevel);
    final center = toNodeCenter(start);

    if (branch.parent != null) {
      final parentStart = getNodeStartOffset(branch.parent!, parentLevel);
      final parentEnd = toNodeEnd(parentStart);
      drawArrow(canvas, parentEnd, start, branch);
    }

    drawMoveNode(canvas, start, branch);

    for (var child_branch in branch.alternativeChildren) {
      drawAlternativeMoveBranch(
        canvas,
        child_branch,
        max(moveLevel[branch.move]!, parentLevel),
      );
    }
  }

  void drawArrow(Canvas canvas, Offset start, Offset end, MoveBranch endNode) {
    final path = Path();

    path.moveTo(start.dx, start.dy);

    path.quadraticBezierTo(
      start.dx + (end.dx - start.dx) / 2,
      start.dy,
      end.dx,
      end.dy,
    );

    final normalPaint = Paint()
      ..color = surface
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final mainLinePaint = Paint()
      ..color = surfaceHighest.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      path,
      currentLine.contains(endNode) ? mainLinePaint : normalPaint,
    );
  }

  void drawText(
      Canvas canvas, String text, Offset offset, Size size, Color color) {
    final textStyle = TextStyle(
      color: color,
      fontSize: 12,
    );

    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout(
      minWidth: size.width,
      maxWidth: size.width,
    );

    var textOffset = Offset(
      offset.dx - textPainter.width / 2,
      offset.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  void drawMoveNode(Canvas canvas, Offset startPos, MoveBranch branch) {
    final center = toNodeCenter(startPos);

    if (branch == currentMove) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCircle(
                  center: center,
                  radius: TreeDimens.selected_circle_dia / 2 + 2),
              Radius.circular(4)),
          Paint()..color = onSurface);
    } else if (currentLine.contains(branch)) {
      canvas.drawCircle(center, TreeDimens.selected_circle_dia / 2 + 2,
          Paint()..color = surfaceHighest.withOpacity(0.5));
    }

    final interactionRect =
        Rect.fromCircle(center: center, radius: TreeDimens.circle_dia / 2);

    allInteractionRects.add(interactionRect);

    interactionRectForMoves[interactionRect] = branch;

    canvas.drawCircle(
      center,
      TreeDimens.circle_dia / 2,
      Paint()..color = Constants.playerColors[branch.move % 2],
    );

    drawText(
      canvas,
      branch.move.toString(),
      center,
      Size(TreeDimens.circle_dia, TreeDimens.circle_dia),
      Constants.playerColors[1 - branch.move % 2],
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    moveLevel = {};
    return true;
  }
}
