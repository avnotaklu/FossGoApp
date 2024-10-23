import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go/gameplay/create/create_game.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/game_end_stage.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/ui/gameui/time_watch.dart';
import 'package:go/constants/constants.dart' as Constants;
import 'package:go/utils/core_utils.dart';
import 'package:provider/provider.dart';

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
      // decoration: BoxDecoration(
      //   // borderRadius: BorderRadius.circular(10.5),
      //   color: Constants.playerColors[widget.player],
      // ),
      child: Row(
        children: [
          Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.lightGreenAccent),
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Container(
                            child: Text(
                              "${widget.player == 0 ? 'Sukhmander' : 'avnotaklu'}",
                              style: TextStyle(
                                  color: Constants.defaultTheme.mainTextColor,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Spacer(
                          flex: 1,
                        ),
                        context.read<GameStateBloc>()!.curStage.stage is GameEndStage
                            ? Expanded(
                                flex: 2,
                                child: Text(
                                  "${ScoreCalculation.of(context)!.scores(context)[widget.player]} + ",
                                  style: TextStyle(
                                      color:
                                          Constants.defaultTheme.mainTextColor),
                                ),
                              )
                            : Spacer(
                                flex: 1,
                              ),
                        Expanded(
                          flex: 5,
                          child: Container(
                            child: ValueListenableBuilder(
                                valueListenable: StoneLogic.of(context)!
                                    .prisoners[widget.player],
                                builder: (context, snapshot, child) {
                                  return Text(
                                    "Prisoners ${snapshot}",
                                    style: TextStyle(
                                        color: Constants
                                            .defaultTheme.mainTextColor),
                                  );
                                }),
                          ),
                        ),
                        widget.player == 1
                            ? Expanded(
                                flex: 2,
                                child: Container(
                                    child: Text(
                                  "+ 6.5",
                                  style: TextStyle(
                                      color:
                                          Constants.defaultTheme.mainTextColor),
                                )),
                              )
                            : Spacer(
                                flex: 2,
                              ),
                        Spacer(
                          flex: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          Expanded(
            flex: 2,
            child:
                //  GameData.of(context)?.match.uid[widget.player] == null
                //     ? const Center(child: CircularProgressIndicator())
                //     :
                GameTimer(
              context.read<GameStateBloc>()?.timerController[widget.player],
              pplayer: widget.player,
            ),
          ),
        ],
      ),
    );
  }
}
