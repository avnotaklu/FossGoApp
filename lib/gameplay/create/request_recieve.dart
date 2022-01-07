import 'package:flutter/material.dart';
import 'package:go/gameplay/logic.dart';
import 'package:go/utils/models.dart';
import 'request_send.dart';

class GameRecieve extends StatelessWidget {
  GameMatch match;
  final newPlace;
  GameRecieve({required this.match, required this.newPlace});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    int? recieversTurn = (() {
      if (match.uid[0] == null) return 0;
      if (match.uid[1] == null) return 1;
    }).call();

    if (recieversTurn == null) {}

    match.uid[recieversTurn] =
        MultiplayerData.of(context)?.curUser.uid.toString();

    return Positioned.fill(
        child: Container(
            child: EnterAndShareMatchButton(match, newPlace),
            decoration: BoxDecoration(color: Colors.green)));
  }
}
