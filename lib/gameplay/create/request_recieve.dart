import 'package:flutter/material.dart';
import 'package:go/gameplay/logic.dart';
import 'package:go/utils/models.dart';

class GameRecieve extends StatelessWidget {
  GameMatch match;
  GameRecieve({required this.match});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    int? recieversTurn = (() {
      if (match.uid[0] == null) return 0;
      if (match.uid[1] == null) return 1;
    }).call();

    if (recieversTurn == null) {}

    match.uid[recieversTurn] = MultiplayerData.of(context)?.curUser.uid.toString();

    return Positioned.fill(
        child: Container(decoration: BoxDecoration(color: Colors.green)));
  }
}
