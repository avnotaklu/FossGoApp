import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/api_error.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/error_handling/http_error.dart';
import 'package:go/core/foundation/either.dart';
import 'package:go/models/game.dart';
import 'package:go/models/game_move.dart';
import 'package:go/services/available_game.dart';
import 'package:go/services/edit_dead_stone_dto.dart';
import 'package:go/services/game_creation_dto.dart';
import 'package:go/services/game_join_dto.dart';
import 'package:go/services/move_position.dart';
import 'package:go/services/join_message.dart';
import 'package:go/services/my_games.dart';
import 'package:go/services/new_move_result.dart';
import 'package:go/services/register_player_dto.dart';
import 'package:go/services/register_user_result.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:go/services/user_authentication_model.dart';
import 'package:go/services/user_details_dto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

// abstract interface class IApi {
//   Future<Either<ApiError, Game>> makeMove(
//       MovePosition data, String token, String gameId);
// }

class Api {
  static const String baseUrl = "http://192.168.145.71:8080";

  Future<Either<HttpError, http.Response>> get(Uri url, String? token) async {
    try {
      var res = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) ...{"Authorization": "Bearer $token"}
        },
      );
      return right(res);
    } on SocketException {
      return left(HttpError(message: "No internet connection"));
    } on HttpException {
      return left(HttpError(message: "Can't find the server"));
    } on FormatException {
      rethrow;
    }
  }

  Future<Either<HttpError, http.Response>> post(
      Uri url, String? body, String? token) async {
    try {
      var res = await http.post(
        url,
        body: body,
        headers: {
          "Content-Type": "application/json",
          if (token != null) ...{"Authorization": "Bearer $token"}
        },
      );
      return right(res);
    } on SocketException {
      return left(HttpError(message: "No internet connection"));
    } on HttpException {
      return left(HttpError(message: "Can't find the server"));
    } on FormatException {
      rethrow;
    }
  }

  Future<Either<AppError, UserAuthenticationModel>> googleSignIn(
      GoogleSignInAuthentication userCreds) async {
    var idToken = userCreds.idToken!;
    var res =
        await get(Uri.parse("$baseUrl/Authentication/GoogleSignIn"), idToken);
    return convert(res, (a) => UserAuthenticationModel.fromJson(a));
  }

  Future<Either<AppError, UserAuthenticationModel>> passwordSignUp(
      UserDetailsDto details) async {
    var res = await post(
      Uri.parse("$baseUrl/Authentication/PasswordSignUp"),
      details.toJson(),
      null,
    );

    return convert(res, (a) => UserAuthenticationModel.fromJson(a));
  }

  Future<Either<AppError, UserAuthenticationModel>> passwordLogin(
      UserDetailsDto details) async {
    var res = await post(Uri.parse("$baseUrl/Authentication/PasswordLogIn"),
        details.toJson(), null);

    return convert(res, (a) => UserAuthenticationModel.fromJson(a));
  }

  Future<Either<AppError, UserAuthenticationModel>> getUser(
      String token) async {
    var res = await get(Uri.parse("$baseUrl/Authentication/GetUser"), token);

    return convert(res, (a) => UserAuthenticationModel.fromJson(a));
  }

  Future<Either<AppError, RegisterUserResult>> registerPlayer(
      RegisterPlayerDto data, String token) async {
    var res = await post(
        Uri.parse("$baseUrl/Player/RegisterPlayer"), data.toJson(), token);

    return convert(res, (a) => RegisterUserResult.fromJson(a));
  }

  Future<Either<AppError, Game>> createGame(
      GameCreationDto data, String token) async {
    var res = await post(
        Uri.parse("$baseUrl/Player/CreateGame"), data.toJson(), token);

    return convert(res, (a) => Game.fromJson(a));
  }

  Future<Either<AppError, GameJoinMessage>> joinGame(
      GameJoinDto data, String token) async {
    var res =
        await post(Uri.parse("$baseUrl/Player/JoinGame"), data.toJson(), token);

    return convert(res, (a) => GameJoinMessage.fromJson(a));
  }

  Future<Either<AppError, NewMoveResult>> makeMove(
      MovePosition data, String token, String gameId) async {
    // var data = MovePosition(x: 0, y: 0);
    var res = await post(
        Uri.parse("$baseUrl/Game/$gameId/MakeMove"), data.toJson(), token);

    return convert(res, (a) => NewMoveResult.fromJson(a));
  }

  Future<Either<AppError, Game>> continueGame(
      String token, String gameId) async {
    // var data = MovePosition(x: 0, y: 0);
    var res = await post(
        Uri.parse("$baseUrl/Game/$gameId/ContinueGame"), null, token);

    return convert(res, (a) => Game.fromJson(a));
  }

  Future<Either<AppError, Game>> acceptScores(
      String token, String gameId) async {
    // var data = MovePosition(x: 0, y: 0);
    var res = await post(
        Uri.parse("$baseUrl/Game/$gameId/AcceptScores"), null, token);

    return convert(res, (a) => Game.fromJson(a));
  }

  Future<Either<AppError, Game>> resignGame(String token, String gameId) async {
    // var data = MovePosition(x: 0, y: 0);
    var res =
        await post(Uri.parse("$baseUrl/Game/$gameId/ResignGame"), null, token);
    return convert(res, (a) => Game.fromJson(a));
  }

  Future<Either<AppError, Game>> editDeadStoneCluster(
      EditDeadStoneClusterDto dto, String token, String gameId) async {
    // var data = MovePosition(x: 0, y: 0);
    var res = await post(
        Uri.parse("$baseUrl/Game/$gameId/EditDeadStoneCluster"),
        dto.toJson(),
        token);
    return convert(res, (a) => Game.fromJson(a));
  }

  Future<Either<AppError, AvailableGames>> getAvailableGames(
      String token) async {
    var res = await get(Uri.parse("$baseUrl/Player/AvailableGames"), token);
    return convert(res, (a) => AvailableGames.fromJson(a));
  }

  Future<Either<AppError, MyGames>> getMyGames(String token) async {
    var res = await get(Uri.parse("$baseUrl/Player/MyGames"), token);
    return convert(res, (a) => MyGames.fromJson(a));
  }

  static ApiError getErrorFromResponse(http.Response res) {
    return ApiError(
        message: res.body,
        statusCode: res.statusCode,
        reasonPhrase: res.reasonPhrase);
  }

  static Either<AppError, T> convert<T>(
      Either<HttpError, http.Response> res, T Function(String) fromJson) {
    return res.mapLeft(AppError.fromHttpError).mapUp<T>(
      (a) {
        if (a.statusCode == 200) {
          return Either.right(fromJson(a.body));
        } else {
          return Either.left(AppError.fromApiError(getErrorFromResponse(a)));
        }
      },
    ).flatMap((a) => a);
  }
}
