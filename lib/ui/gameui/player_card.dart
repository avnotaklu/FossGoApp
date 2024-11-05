import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go/gameplay/create/create_game_screen.dart';
import 'package:go/gameplay/middleware/game_data.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/game_end_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:go/ui/gameui/time_watch.dart';
import 'package:go/constants/constants.dart' as Constants;
import 'package:go/utils/core_utils.dart';
import 'package:go/utils/player.dart';
import 'package:provider/provider.dart';

enum PlayerCardType { my, other }

class PlayerDataUi extends StatefulWidget {
  final PublicUserInfo? playerInfo;
  final Player player;
  final PlayerCardType type;
  @override
  State<PlayerDataUi> createState() => _PlayerDataUiState();
  const PlayerDataUi(this.playerInfo, this.player, this.type, {super.key});
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
                          child: widget.playerInfo?.email == null
                              ? const Center(
                                  child: SizedBox(
                                      width: 25,
                                      height: 25,
                                      child: CircularProgressIndicator()),
                                )
                              : Container(
                                  width: 15,
                                  height: 15,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: widget.playerInfo?.email == null
                                          ? Colors.grey
                                          : Colors.lightGreenAccent),
                                ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Container(
                            child: Text(
                              // "${widget.player == 0 ? 'Sukhmander' : 'avnotaklu'}",
                              widget.playerInfo?.email ?? "Unknown",
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
                        const Spacer(
                          flex: 1,
                        ),
                        context.read<Stage>() is GameEndStage
                            ? Expanded(
                                flex: 2,
                                child: Text(
                                  "${context.read<ScoreCalculationBloc>().scores(context)[widget.player.turn]} + ",
                                  style: TextStyle(
                                      color:
                                          Constants.defaultTheme.mainTextColor),
                                ),
                              )
                            : const Spacer(
                                flex: 1,
                              ),
                        Expanded(
                          flex: 5,
                          child: Container(
                            child: ValueListenableBuilder(
                                valueListenable: context
                                    .read<StoneLogic>()
                                    .prisoners[widget.player.turn],
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
                            : const Spacer(
                                flex: 2,
                              ),
                        const Spacer(
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
                ValueListenableBuilder(
              valueListenable:
                  // widget.type == PlayerCardType.my
                  // ?
                  context.read<GameStateBloc>().times[widget.player.turn],
              // : context
              //     .read<GameStateBloc>()
              //     .times[context.read<GameStateBloc>().otherStone.index],
              builder: (context, value, child) {
                return GameTimer(
                  value,
                  context
                      .read<GameStateBloc>()
                      .timerController[widget.player.turn],
                  pplayer: widget.player,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
