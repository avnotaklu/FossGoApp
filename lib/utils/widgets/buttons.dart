import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart' as Constants;
import 'package:go/gameplay/middleware/multiplayer_data.dart';

class BadukButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Text child;

  const BadukButton({required this.onPressed, required this.child});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        child: Text(
          child.data!,
          // TODO: make BadukText widget to avoid this crap
        //   style: TextStyle(
        //       color: Constants.defaultTheme.mainTextColor, fontSize: 15),
        )

        // Container(
        //   color: Constants.defaultTheme.mainHighlightColor,
        //   child: ,
        // ),
        // style: ButtonStyle(
        //     backgroundColor: MaterialStateProperty.all(
        //   Constants.defaultTheme.mainHighlightColor,
        // )),
        );
  }
}
