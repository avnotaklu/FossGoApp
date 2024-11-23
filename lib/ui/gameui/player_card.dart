// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go/services/game_over_message.dart';
import 'package:provider/provider.dart';

import 'package:go/constants/constants.dart' as Constants;
import 'package:go/gameplay/create/create_game_screen.dart';
import 'package:go/gameplay/middleware/score_calculation.dart';
import 'package:go/gameplay/middleware/stone_logic.dart';
import 'package:go/gameplay/stages/game_end_stage.dart';
import 'package:go/gameplay/stages/stage.dart';
import 'package:go/providers/game_state_bloc.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:go/ui/gameui/time_watch.dart';
import 'package:go/utils/core_utils.dart';
import 'package:go/utils/player.dart';

enum PlayerCardType { my, other }

class DisplayablePlayerData {
  final String? email;
  DisplayablePlayerData({
    required this.email,
  });
}

class PlayerDataUi extends StatefulWidget {
  final DisplayablePlayerData playerInfo;
  final Player player;
  final PlayerCardType type;
  @override
  State<PlayerDataUi> createState() => _PlayerDataUiState();
  const PlayerDataUi(this.playerInfo, this.player, this.type, {super.key});
}

class _PlayerDataUiState extends State<PlayerDataUi> {
  @override
  Widget build(BuildContext context) {
    final game = context.read<GameStateBloc>().game;
    final size = MediaQuery.of(context).size;
    return Container(
      child: Row(
        children: [
          Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: size.width * 0.09,
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
                      Container(
                        child: Text(
                          // "${widget.player == 0 ? 'Sukhmander' : 'avnotaklu'}",
                          widget.playerInfo?.email ?? "Unknown",
                          style: TextStyle(
                              color: Constants.defaultTheme.mainTextColor,
                              fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: size.width * 0.09,
                      ),
                      ValueListenableBuilder(
                          valueListenable: context
                              .read<StoneLogic>()
                              .prisoners[widget.player.turn],
                          builder: (context, snapshot, child) {
                            return Text(
                              " + $snapshot Prisoners",
                              style: TextStyle(
                                  color: Constants.defaultTheme.mainTextColor),
                            );
                          }),
                      widget.player.turn == 1
                          ? Text(
                              " + ${game.komi} komi",
                              style: TextStyle(
                                  color: Constants.defaultTheme.mainTextColor),
                            )
                          : const Spacer(
                              flex: 2,
                            ),
                      const Spacer(
                        flex: 3,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: size.width * 0.09,
                      ),
                      context.read<GameStateBloc>().game.gameOverMethod ==
                              GameOverMethod.Score
                          ? Text(
                              " = ${game.finalTerritoryScores[widget.player.turn] + game.prisoners[widget.player.turn] + (widget.player.turn * game.komi)}",
                              style: TextStyle(
                                  color: Constants.defaultTheme.mainTextColor),
                            )
                          : const SizedBox.shrink(),
                    ],
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
