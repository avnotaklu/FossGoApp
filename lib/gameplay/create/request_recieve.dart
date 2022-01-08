import 'package:flutter/material.dart';
import 'package:go/gameplay/create/utils.dart';
import 'package:go/gameplay/logic.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/utils/models.dart';
import 'package:go/utils/position.dart';
import 'create_game.dart';
import 'package:go/constants/constants.dart' as Constants;

class RequestRecieve extends StatelessWidget {
  GameMatch match;
  final newPlace;
  RequestRecieve({required this.match, required this.newPlace});
  @override
  Widget build(BuildContext context) {
    int recieversTurn = (() {
      if (match.uid[0] == null)
        return 0;
      else
        return 1;
    }).call();

    // assert(match.uid[recieversTurn] == null);

    match.uid[recieversTurn] =
        MultiplayerData.of(context)?.curUser.uid.toString();

    return BackgroundScreenWithDialog(
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Expanded(
        flex: 3,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("You are playing"),
            Expanded(
              child: Stone(
                  Constants.players[recieversTurn].mColor, Position(0, 0)),
            ),
          ],
        ),
      ),
      Expanded(flex: 4, child: Container()),
      Expanded(flex: 3, child: EnterGameButton(match, newPlace)),
    ]));
  }
}
