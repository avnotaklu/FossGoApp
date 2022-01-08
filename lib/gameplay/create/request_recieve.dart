import 'package:flutter/material.dart';
import 'package:go/gameplay/logic.dart';
import 'package:go/playfield/stone.dart';
import 'package:go/utils/models.dart';
import 'package:go/utils/position.dart';
import 'request_send.dart';
import 'package:go/constants/constants.dart' as Constants;

class GameRecieve extends StatelessWidget {
  GameMatch match;
  final newPlace;
  GameRecieve({required this.match, required this.newPlace});
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

    return Positioned.fill(
        child: Container(
      child: FractionallySizedBox(
          widthFactor: 0.9,
          heightFactor: 0.6,
          child: Dialog(
              backgroundColor: Colors.blue,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("You are playing"),
                          Expanded(
                            child: Stone(Constants.players[recieversTurn].mColor,
                                Position(0, 0)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(flex : 4, child: Container()),
                    Expanded(flex : 3, child: EnterAndShareMatchButton(match, newPlace)),
                  ]))),
      decoration: BoxDecoration(color: Colors.green),
    ));
  }
}
