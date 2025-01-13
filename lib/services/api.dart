// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:go/core/error_handling/api_error.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/error_handling/http_error.dart';
import 'package:go/core/foundation/fpdart.dart';
import 'package:go/models/game.dart';
import 'package:go/models/variant_type.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/auth/sign_in_dto.dart';
import 'package:go/modules/gameplay/game_state/game_entrance_data.dart';
import 'package:go/modules/games_history/player_result.dart';
import 'package:go/services/auth_creds.dart';
import 'package:go/services/available_game.dart';
import 'package:go/services/bad_request_error.dart';
import 'package:go/services/edit_dead_stone_dto.dart';
import 'package:go/services/game_and_opponent.dart';
import 'package:go/services/game_creation_dto.dart';
import 'package:go/services/game_join_dto.dart';
import 'package:go/services/games_history_batch.dart';
import 'package:go/services/google_o_auth_model.dart';
import 'package:go/services/guest_user.dart';
import 'package:go/services/guest_user_result.dart';
import 'package:go/services/move_position.dart';
import 'package:go/services/new_move_result.dart';
import 'package:go/services/ongoing_games.dart';
import 'package:go/services/player_rating.dart';
import 'package:go/services/public_user_info.dart';
import 'package:go/services/register_player_dto.dart';
import 'package:go/services/register_user_result.dart';
import 'package:go/services/signal_r_message.dart';
import 'package:go/services/update_profile_dto.dart';
import 'package:go/services/update_profile_result.dart';
import 'package:go/services/user_authentication_model.dart';
import 'package:go/services/user_details_dto.dart';
import 'package:go/services/user_rating_result.dart';
import 'package:go/services/user_stats.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Api {
  static const String basePath = "badukserver.onrender.com";
  // static const String basePath = "192.168.170.71:8080";
  static const String scheme = "https";
  static const String baseUrl = "https://$basePath";

  Uri makeUri(String unencodedPath, Map<String, dynamic>? queryParameters) =>
      scheme == "https"
          ? Uri.https(basePath, unencodedPath, queryParameters)
          : Uri.http(basePath, unencodedPath, queryParameters);

  AuthCreds? _authCreds;
  AuthCreds? get authCreds => _authCreds;

  set authCreds(AuthCreds? creds) {
    _authCreds = creds;
  }

  void log(String m) {
    debugPrint(m);
  }

  Future<Either<HttpError, http.Response>> get(
      Uri url, AuthCreds? creds) async {
    try {
      log("Api Call: ${url.toString()}");
      log("Request: Get");
      var res = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (creds != null) ...{"Authorization": "Bearer ${creds.token}"}
        },
      );

      log("Response: ${res.body}");
      return right(res);
    } on Exception catch (e) {
      log("Socket Exception: ${url.toString()}");
      return left(HttpError(message: "No internet connection"));
    }
    // on  SocketException {
    // } on HttpException {
    //   log("Http Exception: ${url.toString()}");
    //   return left(HttpError(message: "Can't find the server"));
    // } on FormatException {
    //   log("Format Exception: ${url.toString()}");
    //   rethrow;
    // }
  }

  Future<Either<HttpError, http.Response>> post(
      Uri url, String? body, AuthCreds? creds) async {
    try {
      log("Api Call: ${url.toString()}");
      log("Request: Post => $body");

      String? token;

      if (creds != null) {
        bool hasExpired = JwtDecoder.isExpired(creds.token);
        if (hasExpired) {
          if (creds.refreshToken == null) {
            return left(
                HttpError(message: "Session expired please login again"));
          }

          var res = await refreshToken(creds);

          var res2 = res.fold((l) {
            return left(
                HttpError(message: "Session expired please login again"));
          }, (r) {
            authCreds = creds;
            return right(null);
          });

          if (res2.isLeft()) {
            return left(res2.getLeft().toNullable()!);
          }
        } else {
          token = creds.token;
        }
      }

      var res = await http.post(
        url,
        body: body,
        headers: {
          "Content-Type": "application/json",
          if (token != null) ...{"Authorization": "Bearer $token"}
        },
      );

      log("Response: ${res.body}");
      return right(res);
    } on Exception catch (e) {
      log("Socket Exception: ${url.toString()}");
      return left(HttpError(message: "No internet connection"));
    }
  }

  Future<Either<HttpError, http.Response>> rawPost(
      Uri url, String? body, String? token) async {
    try {
      log("Api Call: ${url.toString()}");
      log("Request: Post => $body");

      if (token != null) {
        if (JwtDecoder.isExpired(token)) {
          return left(HttpError(message: "Session expired please login again"));
        }
      }

      var res = await http.post(
        url,
        body: body,
        headers: {
          "Content-Type": "application/json",
          if (token != null) ...{"Authorization": "Bearer $token"}
        },
      );

      log("Response: ${res.body}");
      return right(res);
    } on Exception catch (e) {
      log("Socket Exception: ${url.toString()}");
      return left(HttpError(message: "No internet connection"));
    }

    // on SocketException {
    //   log("Socket Exception: ${url.toString()}");
    //   return left(HttpError(message: "No internet connection"));
    // } on HttpException {
    //   log("Http Exception: ${url.toString()}");
    //   return left(HttpError(message: "Can't find the server"));
    // } on FormatException {
    //   log("Format Exception: ${url.toString()}");
    //   rethrow;
    // }
  }

  static String flagUrl(String countryCode) {
    return "$baseUrl/flags/${countryCode.toLowerCase()}.jpg";
  }

  Future<Either<AppError, GoogleSignInResponse>> googleSignIn(
      GoogleSignInBody body) async {
    var res = await post(
      Uri.parse("$baseUrl/Authentication/GoogleSignIn"),
      body.toJson(),
      null,
    );
    return convert(res, (a) => GoogleSignInResponse.fromJson(a));
  }

  Future<Either<AppError, UserAuthenticationModel>> googleSignUp(
      GoogleSignUpBody body, String token) async {
    var res = await rawPost(
      Uri.parse("$baseUrl/Authentication/GoogleSignUp"),
      body.toJson(),
      token,
    );
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
      SignInDto details) async {
    var res = await post(Uri.parse("$baseUrl/Authentication/PasswordLogIn"),
        details.toJson(), null);

    return convert(res, (a) => UserAuthenticationModel.fromJson(a));
  }

  Future<Either<AppError, AuthCreds>> getValidAuthCreds() async {
    if (authCreds == null) {
      return left(AppError(message: "No auth creds"));
    }

    if (JwtDecoder.isExpired(authCreds!.token)) {
      if (authCreds!.refreshToken == null) {
        return left(AppError(message: "Session expired please login again"));
      }

      var res = await refreshToken(authCreds!);
      return res.map((r) => r.creds);
    } else {
      return right(authCreds!);
    }
  }

  Future<Either<AppError, UserAuthenticationModel>> refreshToken(
    AuthCreds authCreds,
  ) async {
    var res = await rawPost(
      Uri.parse("$baseUrl/Authentication/RefreshToken"),
      authCreds.toJson(),
      authCreds.token,
    );

    return convert(res, (a) => UserAuthenticationModel.fromJson(a));
  }

  Future<Either<AppError, UpdateProfileResult>> updateProfile(
      UpdateProfileDto data, String uid) async {
    var res = await post(
      makeUri("/User/UpdateUserProfile", {'userId': uid}),
      data.toJson(),
      authCreds,
    );

    return convert(res, (a) => UpdateProfileResult.fromJson(a));
  }

  Future<Either<AppError, UserAuthenticationModel>> getUser(
      AuthCreds creds) async {
    var res = await get(Uri.parse("$baseUrl/Authentication/GetUser"), creds);

    // FIXME: This api returns emtpy body of failure sometimes, that shouldn't happen
    return convert(res, (a) => UserAuthenticationModel.fromJson(a));
  }

  Future<Either<AppError, GuestUserResult>> guestLogin() async {
    var res = await post(
      Uri.parse("$baseUrl/Authentication/GuestLogin"),
      null,
      null,
    );

    return convert(res, (a) => GuestUserResult.fromJson(a));
  }

  Future<Either<AppError, RegisterUserResult>> registerPlayer(
      RegisterPlayerDto data) async {
    var res = await post(
        Uri.parse("$baseUrl/Player/RegisterPlayer"), data.toJson(), authCreds);

    return convert(res, (a) => RegisterUserResult.fromJson(a));
  }

  Future<Either<AppError, PlayerRating>> getUserRating(String userId) async {
    var res = await get(
      makeUri("/User/GetUserRatings", {'userId': userId}),
      authCreds,
    );

    return convert(res, (a) => PlayerRating.fromJson(a));
  }

  Future<Either<AppError, UserStat>> getUserStats(String userId) async {
    var res = await get(
      makeUri("/User/GetUserStats", {'userId': userId}),
      authCreds,
    );

    return convert(res, (a) => UserStat.fromJson(a));
  }

  Future<Either<AppError, GameAndOpponent>> getGameAndOpponent(
      String gameId) async {
    var res = await get(
      Uri.parse("$baseUrl/Game/$gameId/GameAndOpponent"),
      authCreds,
    );

    return convert(res, (a) => GameAndOpponent.fromJson(a));
  }

  Future<Either<AppError, PublicUserInfo>> getOpponent(
      String opponentId) async {
    var res = await get(
      Uri.parse("$baseUrl/Player/Opponent/$opponentId"),
      authCreds,
    );

    return convert(res, (a) => PublicUserInfo.fromJson(a));
  }

  Future<Either<AppError, GamesHistoryBatch>> getGamesHistory(
    int page,
    BoardSize? board,
    TimeStandard? time,
    PlayerResult? result,
    DateTime? from,
    DateTime? to,
  ) async {
    var res = await get(
      // Uri.parse("$baseUrl/Player/MyGameHistory/$page"),
      makeUri(
        "/Player/MyGameHistory/$page",
        {
          "boardSize": board?.index.toString(),
          "timeStandard": time?.index.toString(),
          "result": result?.index.toString(),
          "from": from?.toIso8601String(),
          "to": to?.toIso8601String()
        },
      ),
      authCreds,
    );

    return convert(res, (a) => GamesHistoryBatch.fromJson(a));
  }

  Future<Either<AppError, Game>> createGame(GameCreationDto data) async {
    var res = await post(
        Uri.parse("$baseUrl/Player/CreateGame"), data.toJson(), authCreds);

    return convert(res, (a) => Game.fromJson(a));
  }

  Future<Either<AppError, GameEntranceData>> joinGame(GameJoinDto data) async {
    var res = await post(
        Uri.parse("$baseUrl/Player/JoinGame"), data.toJson(), authCreds);

    return convert(res, (a) => GameEntranceData.fromJson(a));
  }

  Future<Either<AppError, NewMoveResult>> makeMove(
      MovePosition data, String gameId) async {
    // var data = MovePosition(x: 0, y: 0);
    var res = await post(
        Uri.parse("$baseUrl/Game/$gameId/MakeMove"), data.toJson(), authCreds);

    return convert(res, (a) => NewMoveResult.fromJson(a));
  }

  Future<Either<AppError, Game>> continueGame(String gameId) async {
    // var data = MovePosition(x: 0, y: 0);
    var res = await post(
        Uri.parse("$baseUrl/Game/$gameId/ContinueGame"), null, authCreds);

    return convert(res, (a) => Game.fromJson(a));
  }

  Future<Either<AppError, Game>> acceptScores(String gameId) async {
    // var data = MovePosition(x: 0, y: 0);
    var res = await post(
        Uri.parse("$baseUrl/Game/$gameId/AcceptScores"), null, authCreds);

    return convert(res, (a) => Game.fromJson(a));
  }

  Future<Either<AppError, Game>> resignGame(String gameId) async {
    // var data = MovePosition(x: 0, y: 0);
    var res = await post(
        Uri.parse("$baseUrl/Game/$gameId/ResignGame"), null, authCreds);
    return convert(res, (a) => Game.fromJson(a));
  }

  Future<Either<AppError, Game>> editDeadStoneCluster(
      EditDeadStoneClusterDto dto, String gameId) async {
    // var data = MovePosition(x: 0, y: 0);
    var res = await post(
        Uri.parse("$baseUrl/Game/$gameId/EditDeadStoneCluster"),
        dto.toJson(),
        authCreds);
    return convert(res, (a) => Game.fromJson(a));
  }

  Future<Either<AppError, AvailableGames>> getAvailableGames() async {
    var res = await get(Uri.parse("$baseUrl/Player/AvailableGames"), authCreds);
    return convert(res, (a) => AvailableGames.fromJson(a));
  }

  Future<Either<AppError, OngoingGames>> getMyGames() async {
    var res = await get(Uri.parse("$baseUrl/Player/OngoingGames"), authCreds);
    return convert(res, (a) => OngoingGames.fromJson(a));
  }

  static ApiError getErrorFromResponse(http.Response res) {
    var badRequest = tryParseJ(
      res.body,
      (d) => BadRequestError.fromMap(d),
    );

    return ApiError(
      message: badRequest.toNullable()?.message ?? res.body,
      statusCode: res.statusCode,
      reasonPhrase: res.reasonPhrase,
    );
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
