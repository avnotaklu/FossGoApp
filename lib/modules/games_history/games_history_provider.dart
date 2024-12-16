import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/services/api.dart';
import 'package:go/services/game_and_opponent.dart';

class GamesHistoryProvider {
  int page = 0;
  bool get isLastPage => false;
  final List<GameAndOpponent> games = [];
  final Api api;
  final AuthProvider auth;

  GamesHistoryProvider({required this.auth, required this.api});

  Future<void> loadGames() async {
    final token = auth.token!;
    final res = await api.getGamesHistory(token);

    res.fold(
      (error) {},
      (games) {
        this.games.addAll(games.games);
        page++;
      },
    );
  }
}
