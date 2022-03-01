import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/stages/game_end_stage.dart';
import 'package:go/ui/gameui/time_watch.dart';
import 'package:go/constants/constants.dart' as Constants;

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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.5),
        color: Constants.playerColors[widget.player],
      ),
      child: Column(
        children: [
          GameData.of(context)?.match.uid[widget.player] == null
              ? const Center(child: CircularProgressIndicator())
              : GameTimer(
                  GameData.of(context)?.timerController[widget.player],
                  pplayer: widget.player,
                ),
          GameData.of(context)!.cur_stage.stage is GameEndStage
              ? Text(
                  "${ScoreCalculation.of(context)!.scores(context)[widget.player]}",
                  style: TextStyle(color: Constants.playerColors[widget.player == 0 ? 1 : 0], fontSize: 25),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
