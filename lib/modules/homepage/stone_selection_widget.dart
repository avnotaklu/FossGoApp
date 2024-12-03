
import 'package:flutter/material.dart';
import 'package:go/models/game.dart';

extension StoneSelectionTypeExtension on StoneSelectionType {
  StoneType? get type => switch (this) {
        StoneSelectionType.black => StoneType.black,
        StoneSelectionType.white => StoneType.white,
        StoneSelectionType.auto => null,
      };
}

enum StoneSelectionType { black, white, auto }

class StoneSelectionWidget extends StatelessWidget {
  final StoneSelectionType type;

  const StoneSelectionWidget(this.type, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: type == StoneSelectionType.white
                  ? Colors.white
                  : Colors.black,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(100),
                topLeft: Radius.circular(100),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: type == StoneSelectionType.black
                  ? Colors.black
                  : Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(100),
                bottomRight: Radius.circular(100),
              ),
            ),
          ),
        ),
      ],
    );
    // Container(
    //   decoration: BoxDecoration(color: type, shape: BoxShape.circle),
    // );
  }
}
