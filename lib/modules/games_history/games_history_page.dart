import 'package:flutter/material.dart';
import 'package:go/modules/games_history/games_history_provider.dart';
import 'package:go/services/api.dart';
import 'package:go/services/game_and_opponent.dart';
import 'package:paginated_list/paginated_list.dart';
import 'package:provider/provider.dart';

class GamesHistoryPage extends StatelessWidget {
  const GamesHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<GamesHistoryProvider>(
      builder: (context, child) {
        final pro = context.read<GamesHistoryProvider>();
        return Scaffold(
          appBar: AppBar(
            title: Text('Games History'),
          ),
          body: Container(
            child: PaginatedList<GameAndOpponent>(
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
              builder: (movie, index) => Container(),
            ),
          ),
        );
      },
      create: (BuildContext context) => GamesHistoryProvider(
        auth: context.read(),
        api: Api(),
      )..loadGames(),
    );
  }
}
