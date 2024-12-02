import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/api_error.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/providers/signalr_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/services/app_user.dart';
import 'package:go/services/auth.dart';
import 'package:go/services/register_player_dto.dart';
import 'package:go/services/register_user_result.dart';
import 'package:go/services/user_authentication_model.dart';
import 'package:go/services/user_rating.dart';
import 'package:go/services/user_rating_result.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider {
  final sharedPrefs = SharedPreferencesAsync();
  final SignalRProvider signlRBloc;
  // final authService = Auth();
  final api = Api();
  final googleSignIn = GoogleSignIn(
      scopes: [
        // 'https://www.googleapis.com/auth/userinfo.email',
        // 'https://www.googleapis.com/auth/userinfo.profile',
        'email'
      ],
      clientId:
          "983500952462-p1upu5nu2bis5565bj6nbqu3iqsp5209.apps.googleusercontent.com");

  final StreamController<AppUser> _currentUserStreamController =
      StreamController.broadcast();
  Stream<AppUser> get currentUser => _currentUserStreamController.stream;

  final StreamController<Either<AppError, AppUser>>
      _authResultStreamController = StreamController.broadcast();
  Stream<Either<AppError, AppUser>> get authResult =>
      _authResultStreamController.stream;

  AppUser? _currentUserRaw;
  AppUser get currentUserRaw => _currentUserRaw!;
  UserRating? _currentUserRating;
  UserRating get currentUserRating => _currentUserRating!;

  String? _token;
  String? get token => _token;

  // bool locallyInitialedAuth = false;
  AuthProvider(this.signlRBloc) {
    getToken().then((value) {
      if (value != null) {
        _token = value;
        getUser(value).then((authRes) {
          authRes.fold((e) {
            debugPrint(e.toString());
          }, (userAuthModel) {
            registerUser(userAuthModel.token, userAuthModel.user);
          });
        });
      }
    });
  }

  Future<Either<AppError, AppUser>> loginGoogle() async {
    try {
      Future<GoogleSignInAccount?> googleUser() async =>
          await googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth =
          await (await googleUser())!.authentication;

      // final AuthCredential credential = GoogleAuthProvider.credential(
      //     idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

      // final result = await authService.signInWithCredentials(credential);
      final result = TaskEither(() => api.googleSignIn(googleAuth));

      var res = result.flatMap((r) {
        return TaskEither(() => registerUser(r.token, r.user));
      });

      return await res.run();
    } catch (error) {
      debugPrint(error.toString());

      return Either.left(
        AppError(message: error.toString()),
      );
    }
  }

  void _setUser(UserRating userRating, String token, AppUser user) {
    _currentUserStreamController.add(user);
    _currentUserRaw = user;
    _token = token;

    storeToken(token);
    storeUser(user);

    debugPrint("email");
  }

  Future<Either<AppError, AppUser>> registerUser(
      String token, AppUser user) async {
    var signalRConnectionId = TaskEither(() => signlRBloc.connectSignalR());

    var registerTas = signalRConnectionId.flatMap((r) {
      return TaskEither(() => _registerUser(token, r));
    });

    var userRatingTas = registerTas.flatMap((r) {
      return TaskEither(() => _userRatingResult(token, user.id));
    });

    var res = (await userRatingTas.run()).flatMap((r) {
      _setUser(r.userRating, token, user);
      return right(user);
    });

    _authResultStreamController.add(res);
    return res;
  }

  Future<Either<AppError, RegisterUserResult>> _registerUser(
      String token, String signalRConnectionId) async {
    var registerRes = await api.registerPlayer(
      RegisterPlayerDto(connectionId: signalRConnectionId),
      token,
    );
    return registerRes;
  }

  Future<Either<AppError, UserRatingResult>> _userRatingResult(
      String token, String userId) async {
    var registerRes = await api.getUserRating(
      userId,
      token,
    );
    return registerRes;
  }

  void storeToken(String token) {
    sharedPrefs.setString('token', token);
  }

  void storeUser(AppUser user) {
    sharedPrefs.setString('user', user.toJson());
  }

  Future<String?> getToken() {
    return sharedPrefs.getString('token');
  }

  Future<Either<AppError, UserAuthenticationModel>> getUser(
      String token) async {
    var res = await api.getUser(token);
    return res;
  }

  Future<void> logout() async {
    await sharedPrefs.remove('user');
    await sharedPrefs.remove('token');
    await signlRBloc.disconnect();
    _currentUserRaw = null;
    _token = null;
  }
}
