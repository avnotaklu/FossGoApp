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
  static const double circle_dia = 32;
  static const double parent_child_dist = 30;

  static double get node_vertical_extent => circle_dia + parent_child_dist;

  static const double siblings_dist = 20;
  static const double selected_circle_dia = 38;

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
    return Scaffold(
      backgroundColor: context.theme.colorScheme.surfaceContainerLow,
      body: Consumer<AnalysisBloc>(
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
                      context.width,
                      calculateMaxWidth(bloc),
                    ),
                    max(
                      context.height * 0.5,
                      calculateMaxHeight(bloc),
                    )),
                painter: MoveCanvas(
                  root: root,
                  realMoves: bloc.realMoves,
                  currentMove: bloc.currentMove,

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

  Offset getNodeStartOffset(MoveBranch alt) {
    double v_node_extent = TreeDimens.node_vertical_extent;
    double h_node_extent = TreeDimens.node_horizontal_extent;

    double rad = TreeDimens.circle_dia / 2;

    int moveL = (moveLevel[alt.move] ?? 0);

    double gap_top = TreeDimens.top_relaxation + v_node_extent * alt.move;
    double gap_left = TreeDimens.left_relaxation + h_node_extent * moveL;

    return Offset(gap_left + rad, gap_top);
  }

  Offset getNodeEndOffset(MoveBranch alt) {
    var start = getNodeStartOffset(alt);
    return Offset(start.dx, start.dy + TreeDimens.circle_dia);
  }

  Offset getNodeCenterOffset(MoveBranch alt) {
    var start = getNodeStartOffset(alt);
    return Offset(start.dx, start.dy + TreeDimens.circle_dia / 2);
  }

  // Offset getRealNodeStartOffset(int move) {
  //   double node_extent = TreeDimens.node_vertical_extent;
  //   double gap_top = TreeDimens.top_relaxation + node_extent * move;

  //   return Offset(
  //       TreeDimens.left_relaxation + TreeDimens.circle_dia / 2, gap_top);
  // }

  // Offset getRealNodeEndOffset(int move) {
  //   var start = getRealNodeStartOffset(move);
  //   return Offset(start.dx, start.dy + TreeDimens.circle_dia);
  // }

  // Offset getRealNodeCenterOffset(int move) {
  //   var start = getRealNodeStartOffset(move);
  //   return Offset(start.dx, start.dy + TreeDimens.circle_dia / 2);
  // }

  void drawRealNodes(Canvas canvas, List<RealMoveBranch> reals) {
    var rev_reals = reals.reversed;

    for (var node in rev_reals.indexed) {
      var center = getNodeCenterOffset(node.$2);

      if (node.$2.parent != null) {
        var start = getNodeEndOffset(node.$2);
        var prevEnd = getNodeEndOffset(node.$2.parent!);
        drawStraightArrow(canvas, start, prevEnd);
      }

      drawMoveNode(canvas, center, node.$2);
      for (var child_branch in node.$2.alternativeChildren) {
        drawAlternativeMoveBranch(canvas, child_branch);
      }
    }
  }

  /// Returns the start of newly drawn branch
  void drawAlternativeMoveBranch(Canvas canvas, AlternativeMoveBranch branch) {
    final prevLevel = moveLevel[branch.move] ?? 0;
    moveLevel[branch.move] = prevLevel + 1;

    final center = getNodeCenterOffset(branch);

    if (branch.parent != null) {
      final start = getNodeStartOffset(branch);
      final parentEnd = getNodeEndOffset(branch.parent!);
      drawStraightArrow(canvas, parentEnd, start);
    }

    drawMoveNode(canvas, center, branch);

    for (var child_branch in branch.alternativeChildren) {
      drawAlternativeMoveBranch(canvas, child_branch);
    }
  }

  void drawStraightArrow(Canvas canvas, Offset start, Offset end) {
    canvas.drawLine(start, end, Paint()..color = surface);
  }

  void drawMoveNode(Canvas canvas, Offset pos, MoveBranch branch) {
    if (branch == currentMove) {
      canvas.drawCircle(pos, TreeDimens.selected_circle_dia / 2,
          Paint()..color = surfaceHighest);
    }

    final interactionRect =
        Rect.fromCircle(center: pos, radius: TreeDimens.circle_dia / 2);

    allInteractionRects.add(interactionRect);

    interactionRectForMoves[interactionRect] = branch;

    return canvas.drawCircle(
      pos,
      TreeDimens.circle_dia / 2,
      Paint()..color = Constants.playerColors[branch.move % 2],
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    moveLevel = {};
    return true;
  }
}
