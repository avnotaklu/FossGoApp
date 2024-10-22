import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/services/api.dart';
import 'package:go/services/game.dart';
import 'package:go/services/game_creation_dto.dart';
import 'package:go/services/game_join_dto.dart';

class HomepageBloc {
  var api = Api();

  Future<Either<AppError, Game>> createGame(String token) async {
    var game = await api.createGame(
        GameCreationDto(rows: 9, columns: 9, timeInSeconds: 300), token);
    return game.mapLeft((e) => AppError(message: e.message));
  }

  Future<Either<AppError, Game>> joinGame(String gameId, String token) async {
    var game = await api.joinGame(GameJoinDto(gameId: gameId), token);
    return game.mapLeft((e) => AppError(message: e.message));
  }
}
