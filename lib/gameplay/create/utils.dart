import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go/gameplay/logic.dart';
import 'package:go/playfield/game.dart';
import 'package:go/utils/models.dart';
import 'package:share/share.dart';

class BackgroundScreenWithDialog extends StatelessWidget {
  @override
  final Widget child;
  BackgroundScreenWithDialog({required this.child});

  Widget build(BuildContext context) {
    return Positioned.fill(
        child: Container(
      child: FractionallySizedBox(
        widthFactor: 0.9,
        heightFactor: 0.6,
        child: Dialog(backgroundColor: Colors.blue, child: child),
      ),
      decoration: BoxDecoration(color: Colors.green),
    ));
  }
}

/// This reads match from database and assigns it to match if all conditions of entering game are met returns true;
Stream<bool> checkGameEnterable(
    BuildContext context, GameMatch match, StreamController<bool> controller) {
  if (match.isComplete()) {
    bool gameEnterable = false;
    var changeStream = MultiplayerData.of(context)
        ?.getCurGameRef(match.id)
        .child('uid')
        .onValue
        .listen((event) {
      match.uid = Map<int?, String?>.from(event.snapshot.value
          .asMap()
          .map((i, element) => MapEntry(i as int, element.toString())));
      if (match.bothPlayers.contains(null) == false) {
        // gameEnterable = true;
        controller.add(true);
      } else {
        // gameEnterable = false;
        controller.add(false);
      }
    });
  }
  return controller.stream;
}