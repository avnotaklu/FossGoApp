import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/services/api.dart';
import 'package:go/models/game.dart';
import 'package:go/services/app_user.dart';
import 'package:go/services/game_creation_dto.dart';
import 'package:go/services/game_join_dto.dart';

class HomepageBloc {

  List<AppUser> otherActivePlayers = [];

  var api = Api();

  Future<Either<AppError, Game>> joinGame(String gameId, String token) async {
    var game = await api.joinGame(GameJoinDto(gameId: gameId), token);
    return game.mapLeft(AppError.fromApiError);
  }
}
