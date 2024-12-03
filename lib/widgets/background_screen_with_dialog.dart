import 'dart:async';

import 'package:go/constants/constants.dart' as Constants;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go/modules/gameplay/playfield_interface/game_widget.dart';


class BackgroundScreenWithDialog extends StatelessWidget {
  @override
  final Widget child;
  const BackgroundScreenWithDialog({required this.child});

  @override
  Widget build(BuildContext context) {
    return
        // Positioned.fill(
        //     child:
        Container(
      decoration: BoxDecoration(color: Constants.defaultTheme.backgroundColor),
      child: FractionallySizedBox(
        widthFactor: 0.9,
        heightFactor: 0.6,
        child: Dialog(
            backgroundColor: Constants.defaultTheme.mainHighlightColor,
            child: child),
      ),
      // )
    );
  }
}
