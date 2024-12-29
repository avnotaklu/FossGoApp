import 'package:flutter/material.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/services/signal_r_message.dart';

class SignalIndicator extends StatelessWidget {
  final ConnectionStrength strength;

  const SignalIndicator({
    super.key,
    required this.strength,
  });

  Color blockColor(int myLevel, int actLevel) {
    final inactiveBlock = actLevel < myLevel;
    if (inactiveBlock) {
      return Colors.grey;
    }
    if (actLevel < 2) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = strength.level;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            4,
            (i) => SignalBlock(
              level: i,
              color: blockColor(i, level),
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          "Ping: ${strength.ping}",
          style: context.textTheme.labelSmall,
        ),
      ],
    );
  }
}

class SignalBlock extends StatelessWidget {
  final int level;
  final Color color;

  const SignalBlock({
    required this.color,
    required this.level,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 0.2,
        ),
        color: color,
      ),
      width: 6,
      height: (6.0 + (5 * level)),
    );
  }
}
