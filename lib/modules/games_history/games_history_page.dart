import 'package:flutter/material.dart';
import 'package:go/core/utils/intl/formatters.dart';
import 'package:go/core/utils/theme_helpers/context_extensions.dart';
import 'package:go/models/game.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/gameplay/playfield_interface/live_game_widget.dart';
import 'package:go/modules/games_history/games_history_provider.dart';
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
                child: PaginatedList(
                  loadingIndicator: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    ),
                  ),
                  items: pro.games,
                  isRecentSearch: false,
                  isLastPage: pro.isLastPage,
                  onLoadMore: (index) => pro.loadGames(),
                  builder: (game, index) => GameListTile(game: game),
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
        game.creationTime.MMM_dd_yyyy(),
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
