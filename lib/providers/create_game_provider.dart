import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/models/game.dart';
import 'package:go/providers/signalr_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/services/game_creation_dto.dart';

class CreateGameProvider {
  // final SignalRProvider signalRBloc;
  CreateGameProvider(this.signalRBloc);
  final SignalRProvider signalRBloc;

  var api = Api();

  Future<Either<AppError, Game>> createGame(String token) async {
    var game = await api.createGame(
        GameCreationDto(rows: 9, columns: 9, timeInSeconds: 5), token);
    return game.mapLeft(AppError.fromApiError);
  }
}
