import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go/ui/gameui/time_watch.dart';
import 'package:go/constants/constants.dart' as Constants;

import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/multiplayer_data.dart';
class PlayerDataUi extends StatefulWidget {
  int player;
  @override
  State<PlayerDataUi> createState() => _PlayerDataUiState();
  PlayerDataUi({required pplayer}) : player = pplayer;
}

class _PlayerDataUiState extends State<PlayerDataUi> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Expanded(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.5),
            color: Constants.playerColors[widget.player],
          ),
          child: Column(
            children: [
              GameData.of(context)?.match.uid[widget.player] == null
                  ? Center(child: CircularProgressIndicator())
                  : GameTimer(
                      GameData.of(context)?.timerController[widget.player],
                      pplayer: widget.player,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
