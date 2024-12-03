import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/services/app_user.dart';
import 'package:go/services/guest_user.dart';
import 'package:go/services/public_user_info.dart';

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

  final StreamController<Either<AppError, PublicUserInfo>>
      _authResultStreamController = StreamController.broadcast();
  Stream<Either<AppError, PublicUserInfo>> get authResult =>
      _authResultStreamController.stream;

  AppUser? _currentUserRaw;
  UserRating? _currentUserRating;
  PublicUserInfo? _currentUserInfo;
  PublicUserInfo get currentUserInfo => _currentUserInfo!;

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
          }, (m) {
            authenticateNormalUser(m.user, m.token);
          });
        });
      }
    });
  }

  Future<Either<AppError, PublicUserInfo>> loginGoogle() async {
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
        return TaskEither(
          () => authenticateNormalUser(
            r.user,
            r.token,
          ),
        );
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
    _currentUserRating = userRating;
    _currentUserRaw = user;

    _currentUserInfo = PublicUserInfo(
      email: user.email,
      id: user.id,
      rating: userRating,
    );

    _token = token;

    storeToken(token);
    storeUser(user);

    debugPrint("email");
  }

  Future<Either<AppError, PublicUserInfo>> authenticateNormalUser(
      AppUser user, String token) async {
    final registerTas = registerUser(token, user.id);

    var userRatingTas = registerTas.flatMap((r) {
      return TaskEither(() => _userRatingResult(token, user.id));
    });

    var res = (await userRatingTas.run()).flatMap((r) {
      _setUser(r, token, user);
      return right(currentUserInfo);
    }).mapLeft((e) {
      signlRBloc.disconnect();
      return e;
    });

    _authResultStreamController.add(res);
    return res;
  }

  Future<Either<AppError, PublicUserInfo>> loginAsGuest() {
    var task = TaskEither(() => api.guestLogin());

    return task.flatMap((r) {
      return TaskEither(() => authenticateGuestUser(r.user, r.token));
    }).run();
  }

  Future<Either<AppError, PublicUserInfo>> authenticateGuestUser(
      GuestUser user, String token) async {
    final registerTas = registerUser(token, user.id);

    var res = (await registerTas.run()).flatMap((r) {
      _token = token;
      _currentUserInfo = PublicUserInfo(email: null, id: user.id, rating: null);

      return right(currentUserInfo);
    }).mapLeft((e) {
      signlRBloc.disconnect();
      return e;
    });

    _authResultStreamController.add(res);
    return res;
  }

  TaskEither<AppError, RegisterUserResult> registerUser(
      String token, String userId) {
    var signalRConnectionId = TaskEither(() => signlRBloc.connectSignalR());

    var registerTas = signalRConnectionId.flatMap((r) {
      return TaskEither(() => _registerUser(token, r));
    });

    return registerTas;
  }

  Future<Either<AppError, RegisterUserResult>> _registerUser(
      String token, String signalRConnectionId) async {
    var registerRes = await api.registerPlayer(
      RegisterPlayerDto(connectionId: signalRConnectionId),
      token,
    );
    return registerRes;
  }

  Future<Either<AppError, UserRating>> _userRatingResult(
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
