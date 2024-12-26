import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/foundation/int.dart';
import 'package:go/core/foundation/string.dart';
import 'package:go/core/utils/intl/formatters.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/core/utils/theme_helpers/text_theme_helper.dart';
import 'package:go/models/game.dart';
import 'package:go/models/variant_type.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/gameplay/playfield_interface/live_game_widget.dart';
import 'package:go/modules/games_history/games_history_provider.dart';
import 'package:go/modules/games_history/player_result.dart';
import 'package:go/modules/homepage/create_game_screen.dart';
import 'package:go/modules/stats/stats_repository.dart';
import 'package:go/services/api.dart';
import 'package:go/services/game_and_opponent.dart';
import 'package:go/services/game_over_message.dart';
import 'package:go/widgets/basic_alert.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paginated_list/paginated_list.dart';
import 'package:provider/provider.dart';

class GamesHistoryPage extends StatelessWidget {
  final IStatsRepository statsRepo;

  const GamesHistoryPage({required this.statsRepo, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        builder: (context, child) {
          return Consumer<GamesHistoryProvider>(builder: (context, pro, child) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Games History'),
              ),
              body: Container(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 90,
                            child: MyDropDown(
                              label: 'Board',
                              items: [null, ...BoardSize.values],
                              selectedItem: pro.boardSize,
                              itemBuilder: (v) => DropdownMenuItem(
                                value: v,
                                child: Text(
                                  v?.toDisplayString ?? "All",
                                  style: context.textTheme.labelLarge,
                                ),
                              ),
                              onChanged: (v) =>
                                  pro.setQueryParams(boardSize: v),
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            width: 90,
                            child: MyDropDown(
                              label: "Result",
                              items: [null, ...PlayerResult.values],
                              selectedItem: pro.result,
                              itemBuilder: (v) => DropdownMenuItem(
                                value: v,
                                child: Text(
                                  v?.name.capitalize() ?? "All",
                                  style: context.textTheme.labelLarge,
                                ),
                              ),
                              onChanged: (v) => pro.setQueryParams(result: v),
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            width: 150,
                            child: MyDropDown(
                              label: "Time",
                              items: [null, ...TimeStandard.values],
                              selectedItem: pro.timeStandard,
                              itemBuilder: (v) => DropdownMenuItem(
                                value: v,
                                child: Text(
                                  v?.standardName ?? "All",
                                  style: context.textTheme.labelLarge,
                                ),
                              ),
                              onChanged: (v) =>
                                  pro.setQueryParams(timeStandard: v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      height: context.height * 0.7,
                      child: PaginatedList(
                        loadingIndicator: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        shrinkWrap: true,
                        items: pro.games,
                        isRecentSearch: false,
                        isLastPage: pro.isLastPage,
                        onLoadMore: (index) => pro.loadGames(),
                        builder: (game, index) => GameListTile(game: game),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            "Games Played From ",
                            style: context.textTheme.bodyLarge,
                          ),
                          IconButton(
                            padding: EdgeInsets.all(8),
                            onPressed: () async {
                              final res = await showDatePicker(
                                context: context,
                                firstDate:
                                    DateTime.fromMicrosecondsSinceEpoch(0),
                                lastDate: pro.to ?? DateTime.now(),
                              );

                              if (res != null) {
                                pro.setFromTime(res);
                              }
                            },
                            icon: Column(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  size: 16,
                                ),
                                Text(
                                  "${fromTimeText(
                                    pro.from,
                                  )}",
                                  style: context.textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "To",
                            style: context.textTheme.bodyLarge,
                          ),
                          IconButton(
                            padding: EdgeInsets.all(8),
                            onPressed: () async {
                              final res = await showDatePicker(
                                context: context,
                                firstDate: pro.from ??
                                    DateTime.fromMicrosecondsSinceEpoch(0),
                                lastDate: DateTime.now(),
                              );

                              if (res != null) {
                                pro.setToTime(res);
                              }
                            },
                            icon: Column(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  size: 16,
                                ),
                                Text(
                                  "${toTimeText(
                                    pro.to,
                                  )}",
                                  style: context.textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
        providers: [
          ChangeNotifierProvider(
            create: (context) => GamesHistoryProvider(
              auth: context.read(),
              api: Api(),
            )..loadGames(),
          ),
          Provider<IStatsRepository>.value(value: statsRepo)
        ]);
  }

  String fromTimeText(DateTime? fromTime) {
    return fromTime?.MMM_dd_yyyy() ?? "Start";
  }

  String toTimeText(DateTime? fromTime) {
    return fromTime?.MMM_dd_yyyy() ?? "Now";
  }
}

class GameListTile extends StatelessWidget {
  const GameListTile({
    required this.game,
    super.key,
  });

  final Game game;

  @override
  Widget build(BuildContext context) {
    final myId = context.read<AuthProvider>().myId;
    final StoneType? opStone = game.getOtherStoneFromPlayerId(myId);
    final opName = opStone?.getValueFromPlayerList(game.usernames);
    return InkWell(
      onTap: () async {
        final statsRepo = context.read<IStatsRepository>();
        final pro = context.read<GamesHistoryProvider>();

        final res = await pro.getGameAndOpponent(game);

        return res.fold(
          (l) {
            showDialog(
                context: context,
                builder: (context) {
                  return BasicDialog(
                      title: "Game did not load", content: l.message);
                });
          },
          (r) {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return LiveGameWidget(game, r, statsRepo);
            }));
          },
        );
      },
      child: Container(
          width: double.infinity,
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        game.title,
                        style: context.textTheme.bodySmall?.copyWith(
                            fontFamily: GoogleFonts.spaceMono().fontFamily),
                      ),
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(
                          text: "Vs ",
                          style: context.textTheme.labelLarge?.italicify,
                        ),
                        TextSpan(
                          text: "$opName ",
                          style: context.textTheme.bodySmall,
                        ),
                        if (game.didEnd())
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "(",
                                style: context.textTheme.labelLarge,
                              ),
                              TextSpan(
                                text: game.playersRatingsDiff[game
                                        .getStoneFromPlayerId(
                                            context.read<AuthProvider>().myId)!
                                        .index]
                                    .signedString(),
                                style: context.textTheme.labelLarge?.copyWith(
                                  color: game.playersRatingsDiff[game
                                              .getStoneFromPlayerId(context
                                                  .read<AuthProvider>()
                                                  .myId)!
                                              .index] <
                                          0
                                      ? otherColors.loss
                                      : otherColors.win,
                                ),
                              ),
                              TextSpan(
                                text: ")",
                                style: context.textTheme.labelLarge,
                              )
                            ],
                            style: context.textTheme.bodySmall,
                          )
                        else
                          TextSpan(
                            text: "(playing)",
                            style: context.textTheme.bodySmall,
                          )
                      ])),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Text(
                        "Played ${game.creationTime.pastTimeFrameDiffDisplay(DateTime.now(), 2)}",
                        style: context.textTheme.labelSmall,
                      ),
                      Spacer(),
                      gameOverText(context)
                    ],
                  )
                ],
              ),
            ),
          )),
    );
  }

  PlayerResult getMyResult(BuildContext context, GameResult result) {
    final auth = context.read<AuthProvider>();
    if (result == GameResult.draw) return PlayerResult.draw;
    return result.getWinnerStone() == game.getStoneFromPlayerId(auth.myId)
        ? PlayerResult.won
        : PlayerResult.lost;
  }

  String? getGameOverMethod(BuildContext context, Game game) {
    if (game.gameOverMethod == null) return null;

    PlayerResult myRes = getMyResult(context, game.result!);

    if (myRes == PlayerResult.draw) return "Draw";

    return "${myRes.name.capitalize()} By ${game.gameOverMethod!.displayStringWithScoreForWinner(game)}";
  }

  Widget gameOverText(BuildContext context) {
    if (!game.didEnd()) return const SizedBox.shrink();

    PlayerResult myRes = getMyResult(context, game.result!);

    return Text(
      " • ${getGameOverMethod(context, game)}",
      style: context.textTheme.labelSmall?.copyWith(
          color: myRes == PlayerResult.draw
              ? null
              : myRes == PlayerResult.won
                  ? otherColors.win
                  : otherColors.loss),
    );
  }
}
