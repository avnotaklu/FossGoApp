import 'package:flutter/material.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/models/cluster.dart';
import 'package:go/models/position.dart';
import 'package:flutter/foundation.dart';


class StoneWidget extends StatelessWidget {
  final Color? color;
  // Cluster cluster;
  final Position pos;

  const StoneWidget(this.color, this.pos, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}
