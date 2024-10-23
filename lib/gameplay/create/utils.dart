import 'dart:async';

import 'package:go/constants/constants.dart' as Constants;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
import 'package:go/playfield/game_widget.dart';
import 'package:go/models/game_match.dart';

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

/// This reads match from database and assigns it to match if all conditions of entering game are met returns true;
// Stream<bool> checkGameEnterable(BuildContext context, GameMatch match, StreamController<bool> controller) {
//   if (match.isComplete()) {
//     bool gameEnterable = false;
//     var changeStream = MultiplayerData.of(context)?.game_ref.child(match.id).child('uid').onValue.listen((event) {
//       match.uid = GameMatch.uidFromJson(event.snapshot.value as List<Object?>);
//       if (match.bothPlayers.contains(null) == false) {
//         // gameEnterable = true;
//         controller.add(true);
//       } else {
//         // gameEnterable = false;
//         controller.add(false);
//       }
//     });
//   }
//   return controller.stream;
// }
