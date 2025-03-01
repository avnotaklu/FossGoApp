import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go/core/foundation/string.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/core/utils/theme_helpers/text_theme_helper.dart';
import 'package:go/models/game.dart';
import 'package:go/models/time_control.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/modules/gameplay/game_state/game_state_bloc.dart';
import 'package:go/modules/gameplay/game_state/oracle/game_state_oracle.dart';
import 'package:go/modules/homepage/create_game_screen.dart';
import 'package:go/modules/stats/stats_repository.dart';
import 'package:go/models/find_match_dto.dart';
import 'package:go/models/time_control_dto.dart';
import 'package:go/widgets/loader_basic_button.dart';
import 'package:provider/provider.dart';
import 'package:go/constants/constants.dart' as Constants;

class GameOverCard extends StatefulWidget {
  final GameStateBloc gameStat;
  final BuildContext
      oldContext; // HACK: old context contains the needed providers, it works to just pass it, so doing that for now.

  const GameOverCard(
      {required this.gameStat, required this.oldContext, super.key});

  @override
  State<GameOverCard> createState() => _GameOverCardState();
}

class _GameOverCardState extends State<GameOverCard> {

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.theme.colorScheme.surfaceContainerHigh,
      child: Container(
        height: 350,
        width: context.height * 0.7,
        padding: EdgeInsets.symmetric(horizontal: 05),
        child: Column(
          children: [
            SizedBox(height: 10),
            Text("Game Over", style: context.textTheme.headlineSmall),
            if (widget.gameStat.game.result == GameResult.draw)
              Text("Game Drawn", style: context.textTheme.labelLarge)
            else
              Text(
                  "${widget.gameStat.game.result!.getWinnerStone()!.name.capitalize()} won by ${widget.gameStat.game.gameOverMethod!.actualName}",
                  style: context.textTheme.labelLarge),
            SizedBox(height: 10),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlayerTile(data: widget.gameStat.blackPlayer!),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("vs",
                        style: context.textTheme.titleLarge?.italicify)),
                PlayerTile(data: widget.gameStat.whitePlayer!),
              ],
            ),
            SizedBox(height: 10),
            LoaderBasicButton(
                onPressed: () async {
                  if (widget.gameStat.getPlatform() == GamePlatform.local) {
                    showOverTheBoardCreateCustomGameDialog(widget.oldContext);
                  } else if (widget.gameStat.getPlatform() ==
                      GamePlatform.online) {
                    showLiveCreateCustomGameDialog(widget.oldContext);
                  }
                },
                label: "Create New"),
            LoaderBasicButton(
                onPressed: () async {
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/HomePage", (v) => false);
                },
                label: "Home"),
          ],
        ),
      ),
    );
  }

  // NOTE: Unused, was needed for matchfinding
  bool canFindMatching() {
    return existsSimilarTime() &&
        widget.gameStat.game.boardSizeData.boardSize.matchableBoardSize != null;
  }

  // NOTE: Unused, was needed for matchfinding
  bool existsSimilarTime() {
    return (Constants.timeControlsForMatch.map((e) => e.simpleRepr()).contains(
        widget.gameStat.game.timeControl.getTimeControlDto().simpleRepr()));
  }

  // NOTE: Unused, was needed for matchfinding
  TimeControlDto getSimilarTime() {
    return TimeControlDto.fromSimpleRepr((Constants.timeControlsForMatch
        .map((e) => e.simpleRepr())
        .firstWhere((e) =>
            e ==
            widget.gameStat.game.timeControl
                .getTimeControlDto()
                .simpleRepr())));
  }
}

class PlayerTile extends StatelessWidget {
  final DisplayablePlayerData data;

  const PlayerTile({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      child: Card(
        color: Constants.playerColors[data.stoneType!.index],
        elevation: 5,
        child: Theme(
          data: context.theme.copyWith(
            textTheme: Constants.buildTextTheme(
                Constants.playerColors[data.stoneType!.other.index]),
          ),
          child: Builder(builder: (context) {
            return Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(data.displayName, style: context.textTheme.titleLarge),
                  const SizedBox(width: 5),
                  if (data.komi != null) ...[
                    Text("Komi: ${data.komi}",
                        style: context.textTheme.labelSmall),
                    const SizedBox(width: 5),
                  ],
                  Text("Captures: ${data.prisoners}",
                      style: context.textTheme.labelSmall),
                  const SizedBox(width: 5),
                  if (data.score != null) ...[
                    Text("Points: ${data.score}",
                        style: context.textTheme.labelSmall),
                    const SizedBox(width: 5),
                  ]
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
