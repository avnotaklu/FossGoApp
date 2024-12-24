import 'package:flutter/material.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/modules/gameplay/middleware/analysis_bloc.dart';

class MoveTree extends StatelessWidget {
  final RootMove root;

  const MoveTree({required this.root, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InteractiveViewer(
        constrained: false,
        child: SizedBox(
          child: CustomPaint(
            size: Size(context.width + 50, 3000),
            painter: MoveCanvas(
                root: root,
                // ignore: deprecated_member_use
                surface: context.theme.colorScheme.surfaceVariant,
                onSurface: context.theme.colorScheme.onSurface),
          ),
        ),
      ),

      // body: TwoDimensionalScrollable(
      //   viewportBuilder: (context, vertPos, horPos) {
      //     return SizedBox.expand(
      //       child: CustomPaint(
      //         size: Size(context.width + 60, 3000),
      //         painter: MoveCanvas(
      //             root: root,
      //             // ignore: deprecated_member_use
      //             surface: context.theme.colorScheme.surfaceVariant,
      //             onSurface: context.theme.colorScheme.onSurface),
      //       ),
      //     );
      //   },
      //   horizontalDetails: ScrollableDetails(
      //     direction: AxisDirection.right,
      //   ),
      //   verticalDetails: ScrollableDetails(
      //     direction: AxisDirection.down,
      //   ),
      // ),
    );
  }
}

class MoveCanvas extends CustomPainter {
  final RootMove root;
  final Color surface;
  final Color onSurface;

  MoveCanvas({
    required this.root,
    required this.surface,
    required this.onSurface,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final _xcenter = size.width / 2;
    final _ytop = 30.0;

    // draw circle
    for (var i = 0; i < 20; i++) {
      canvas.drawCircle(
        Offset(_xcenter, (_ytop ) * i ),
        16,
        Paint()..color = surface,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
