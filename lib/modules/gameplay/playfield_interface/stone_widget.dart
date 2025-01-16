import 'package:flutter/material.dart';
import 'package:go/models/game.dart';
import 'package:go/models/position.dart';
import 'package:go/modules/gameplay/playfield_interface/cell.dart';
import 'package:go/utils/stone_type.dart';

class StoneWidget extends StatelessWidget {
  // final Color? color;
  final StoneType stone;
  // Cluster cluster;
  final Position pos;
  final double opacity;

  const StoneWidget(this.stone, this.pos, {super.key, this.opacity = 1});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
            opacity: opacity,
            image: AssetImage(stone.imageFile),
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                blurRadius: 10,
                offset: Offset(4, 4),
                color: Colors.grey.shade900,
                spreadRadius: 0.1)
          ]),
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
