import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/api_error.dart';
import 'package:go/models/game.dart';
import 'package:go/models/game_move.dart';
import 'package:go/services/edit_dead_stone_dto.dart';
import 'package:go/services/game_creation_dto.dart';
import 'package:go/services/game_join_dto.dart';
import 'package:go/services/move_position.dart';
import 'package:go/services/join_message.dart';
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
  static const String baseUrl = "http://192.168.80.71:8080";

  Future<Either<ApiError, UserAuthenticationModel>> googleSignIn(
      GoogleSignInAuthentication userCreds) async {
    var idToken = userCreds.idToken!;
    var res = await http.get(Uri.parse("$baseUrl/Authentication/GoogleSignIn"),
        headers: {"Authorization": "Bearer $idToken"});
    if (res.statusCode == 200) {
      return Either.right(UserAuthenticationModel.fromJson(res.body));
    } else {
      return Either.left(getErrorFromResponse(res));
      // return Either.left(ApiError(
      //     message: "Couldn't sign in with google", statusCode: res.statusCode));
    }
  }

  Future<Either<ApiError, UserAuthenticationModel>> passwordSignUp(
      UserDetailsDto details) async {
    var res = await http.post(
      Uri.parse("$baseUrl/Authentication/PasswordSignUp"),
      body: details.toJson(),
      headers: {"Content-Type": "application/json"},
    );
    if (res.statusCode == 200) {
      return Either.right(UserAuthenticationModel.fromJson(res.body));
    } else {
      return Either.left(getErrorFromResponse(res));
      // return Either.left(
      //     ApiError(message: res.body, statusCode: res.statusCode));
    }
  }

  Future<Either<ApiError, UserAuthenticationModel>> passwordLogin(
      UserDetailsDto details) async {
    var res = await http.post(
      Uri.parse("$baseUrl/Authentication/PasswordLogIn"),
      body: details.toJson(),
      headers: {"Content-Type": "application/json"},
    );
    if (res.statusCode == 200) {
      return Either.right(UserAuthenticationModel.fromJson(res.body));
    } else {
      return Either.left(getErrorFromResponse(res));
      // return Either.left(
      //     ApiError(message: res.body, statusCode: res.statusCode));
    }
  }

  Future<Either<ApiError, UserAuthenticationModel>> getUser(
      String token) async {
    var res = await http.get(
      Uri.parse("$baseUrl/Authentication/GetUser"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );
    if (res.statusCode == 200) {
      return Either.right(UserAuthenticationModel.fromJson(res.body));
    } else {
      return Either.left(getErrorFromResponse(res));
      // return Either.left(
      //     ApiError(message: res.body, statusCode: res.statusCode));
    }
  }

  Future<Either<ApiError, RegisterUserResult>> registerPlayer(
      RegisterPlayerDto data, String token) async {
    var res = await http.post(
      Uri.parse("$baseUrl/Player/RegisterPlayer"),
      body: data.toJson(),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );
    if (res.statusCode == 200) {
      return Either.right(RegisterUserResult.fromJson(res.body));
    } else {
      return Either.left(getErrorFromResponse(res));
      // return Either.left(
      //     ApiError(message: res.body, statusCode: res.statusCode));
    }
  }

  Future<Either<ApiError, Game>> createGame(
      GameCreationDto data, String token) async {
    var res = await http.post(
      Uri.parse("$baseUrl/Player/CreateGame"),
      body: data.toJson(),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );
    if (res.statusCode == 200) {
      return Either.right(Game.fromJson(res.body));
    } else {
      return Either.left(getErrorFromResponse(res));
      // return Either.left(
      //     ApiError(message: res.body, statusCode: res.statusCode));
    }
  }

  Future<Either<ApiError, GameJoinMessage>> joinGame(
      GameJoinDto data, String token) async {
    var res = await http.post(
      Uri.parse("$baseUrl/Player/JoinGame"),
      body: data.toJson(),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );
    if (res.statusCode == 200) {
      return Either.right(GameJoinMessage.fromJson(res.body));
    } else {
      return Either.left(getErrorFromResponse(res));
      // return Either.left(
      //     ApiError(message: res.body, statusCode: res.statusCode));
    }
  }

  Future<Either<ApiError, NewMoveResult>> makeMove(
      MovePosition data, String token, String gameId) async {
    // var data = MovePosition(x: 0, y: 0);
    var res = await http.post(
      Uri.parse("$baseUrl/Game/$gameId/MakeMove"),
      body: data.toJson(),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );
    if (res.statusCode == 200) {
      return Either.right(NewMoveResult.fromJson(res.body));
    } else {
      return Either.left(getErrorFromResponse(res));
      // return Either.left(
      //     ApiError(message: res.body, statusCode: res.statusCode));
    }
  }

  Future<Either<ApiError, Game>> continueGame(
      String token, String gameId) async {
    // var data = MovePosition(x: 0, y: 0);
    var res = await http.post(
      Uri.parse("$baseUrl/Game/$gameId/ContinueGame"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );
    if (res.statusCode == 200) {
      return Either.right(Game.fromJson(res.body));
    } else {
      return Either.left(getErrorFromResponse(res));
      // return Either.left(
      //     ApiError(message: res.body, statusCode: res.statusCode));
    }
  }

  Future<Either<ApiError, Game>> acceptScores(
      String token, String gameId) async {
    // var data = MovePosition(x: 0, y: 0);
    var res = await http.post(
      Uri.parse("$baseUrl/Game/$gameId/AcceptScores"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );
    if (res.statusCode == 200) {
      return Either.right(Game.fromJson(res.body));
    } else {
      return Either.left(getErrorFromResponse(res));
      // return Either.left(
      //     ApiError(message: res.body, statusCode: res.statusCode));
    }
  }


  Future<Either<ApiError, Game>> editDeadStoneCluster(
      EditDeadStoneClusterDto dto, String token, String gameId) async {
    // var data = MovePosition(x: 0, y: 0);
    var res = await http.post(
      Uri.parse("$baseUrl/Game/$gameId/EditDeadStoneCluster"),
      body: dto.toJson(),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );
    if (res.statusCode == 200) {
      return Either.right(Game.fromJson(res.body));
    } else {
      return Either.left(getErrorFromResponse(res));
      // return Either.left(
      //     ApiError(message: res.body, statusCode: res.statusCode));
    }
  }

  Future<Either<ApiError, AvailableGames>> getAvailableGames(
      String token) async {
    var res = await http.get(
      Uri.parse("$baseUrl/Player/AvailableGames"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );
    if (res.statusCode == 200) {
      return Either.right(AvailableGames.fromJson(res.body));
    } else {
      return Either.left(getErrorFromResponse(res));
      // return Either.left(
      //     ApiError(message: res.body, statusCode: res.statusCode));
    }
  }

  static ApiError getErrorFromResponse(http.Response res) {
    return ApiError(
        message: res.body,
        statusCode: res.statusCode,
        reasonPhrase: res.reasonPhrase);
  }
}
