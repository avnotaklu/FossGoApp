import 'package:flutter/material.dart';
import 'package:go/models/position.dart';

class StoneWidget extends StatelessWidget {
  final Color? color;
  // Cluster cluster;
  final Position pos;

  const StoneWidget(this.color, this.pos, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      // child: CustomPaint(
      //   painter: CrossPainter(),
      // ),
    );
  }
}

class CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final m = size.width / 2;

    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;

    canvas.drawLine(Offset(m, 0), Offset(m, size.height), paint);
    canvas.drawLine(Offset(0, m), Offset(size.width, m), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
