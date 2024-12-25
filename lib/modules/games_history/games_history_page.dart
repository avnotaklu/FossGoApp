import 'package:flutter/material.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/foundation/string.dart';
import 'package:go/core/utils/intl/formatters.dart';
import 'package:go/core/utils/my_responsive_framework/extensions.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/models/game.dart';
import 'package:go/models/variant_type.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/gameplay/playfield_interface/live_game_widget.dart';
import 'package:go/modules/games_history/games_history_provider.dart';
import 'package:go/modules/games_history/query_params.dart';
import 'package:go/modules/homepage/create_game_screen.dart';
import 'package:go/modules/stats/stats_repository.dart';
import 'package:go/services/api.dart';
import 'package:go/services/game_and_opponent.dart';
import 'package:go/widgets/basic_alert.dart';
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
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
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
                            onChanged: (v) => pro.setQueryParams(boardSize: v),
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
                    Container(
                      height: context.height * 0.72,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Game Played Since: ${sinceTimeText(
                          pro.sinceTime,
                        )}"),
                        IconButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () async {
                            final res = await showDatePicker(
                              context: context,
                              firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                              lastDate: DateTime.now(),
                            );

                            if (res != null) {
                              pro.setSinceTime(res);
                            }
                          },
                          icon: Icon(Icons.calendar_month),
                        )
                      ],
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

  String sinceTimeText(DateTime? sinceTime) {
    if (sinceTime == null) return "Start";
    return sinceTime.pastTimeFrameDiffDisplay(DateTime.now(), 2);
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
    return ListTile(
      title: Text(
        "$opName",
        style: context.textTheme.bodySmall,
      ),
      subtitle: Text(
        game.creationTime.pastTimeFrameDiffDisplay(DateTime.now(), 2),
        style: context.textTheme.labelLarge,
      ),
      contentPadding: EdgeInsets.all(0),
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
      trailing: Icon(
        Icons.keyboard_arrow_right,
        weight: 1,
        size: 30,
      ),
    );
  }
}
