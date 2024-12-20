import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/services/user_account.dart';
import 'package:go/services/guest_user.dart';
import 'package:go/services/public_user_info.dart';

import 'package:go/services/register_player_dto.dart';
import 'package:go/services/register_user_result.dart';
import 'package:go/services/user_authentication_model.dart';
import 'package:go/services/player_rating.dart';
import 'package:go/services/user_rating_result.dart';
import 'package:go/services/user_stats.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/hub_connection.dart';

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

  // final StreamController<UserAccount> _currentUserStreamController =
  //     StreamController.broadcast();
  // Stream<UserAccount> get currentUser => _currentUserStreamController.stream;

  final StreamController<Either<AppError, AbstractUserAccount?>>
      _authResultStreamController = StreamController.broadcast();
  Stream<Either<AppError, AbstractUserAccount?>> get authResult =>
      _authResultStreamController.stream;

  AbstractUserAccount? _currentUserRaw;
  AbstractUserAccount get currentUserAccount => _currentUserRaw!;

  String get myId => _currentUserRaw!.myId;
  PlayerType get myType => _currentUserRaw!.myType;
  String get myUsername => _currentUserRaw!.myUsername;

  // PlayerRating? _currentUserRating;
  // UserStat? _currentUserStat;
  // UserStat? get currentUserStat => _currentUserStat;

  // PublicUserInfo? _currentUserInfo;
  // PublicUserInfo get currentUserInfo => _currentUserInfo!;

  String? _token;
  String? get token => _token;

  Completer<Either<AppError, UserAccount?>> initialAuth = Completer();

  // bool locallyInitialedAuth = false;
  AuthProvider(this.signlRBloc) {
    getToken().then((value) {
      if (value != null) {
        _token = value;
        getUser(value).then((authRes) {
          authRes.fold((e) {
            debugPrint(e.toString());
          }, (m) async {
            var res = await authenticateNormalUser(m.user, m.token);
            initialAuth.complete(res);
          });
        });
      } else {
        initialAuth.complete(right(null));
      }
    });
    Future.delayed(Duration(seconds: 2), () {
      if (!initialAuth.isCompleted) {
        initialAuth.complete(left(AppError(message: "Login Timeout")));
      }
    });
  }

  Future<Either<AppError, UserAccount>> loginGoogle() async {
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

  void _setUser(String token, AbstractUserAccount user) {
    _currentUserRaw = user;
    _token = token;

    if (user is UserAccount) {
      storeToken(token);
      storeUser(user);
    }

    debugPrint("email");
  }

  Future<Either<AppError, UserAccount>> authenticateNormalUser(
      UserAccount user, String token) async {
    final registerTas = registerUser(token, user.id);

    var res = (await registerTas.run()).flatMap((r) {
      _setUser(token, user);
      return right(user);
    }).mapLeft((e) {
      signlRBloc.disconnect();
      return e;
    });

    _authResultStreamController.add(res);
    return res;
  }

  Future<Either<AppError, GuestUser>> loginAsGuest() {
    var task = TaskEither(() => api.guestLogin());

    return task.flatMap((r) {
      return TaskEither(() => authenticateGuestUser(r.user, r.token));
    }).run();
  }

  Future<Either<AppError, GuestUser>> authenticateGuestUser(
      GuestUser user, String token) async {
    final registerTas = registerUser(token, user.id);

    var res = (await registerTas.run()).flatMap((r) {
      _setUser(token, user);
      return right(user);
    }).mapLeft((e) {
      signlRBloc.disconnect();
      return e;
    });

    _authResultStreamController.add(res);
    return res;
  }

  TaskEither<AppError, RegisterUserResult> registerUser(
      String token, String userId) {
    var signalRConnectionId =
        TaskEither(() => signlRBloc.connectSignalR(token));

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

  Future<Either<AppError, PlayerRating>> _userRatingResult(
      String token, String userId) async {
    var registerRes = await api.getUserRating(
      userId,
      token,
    );
    return registerRes;
  }

  Future<Either<AppError, UserStat>> _userStatResult(
      String token, String userId) async {
    var registerRes = await api.getUserStats(
      userId,
      token,
    );
    return registerRes;
  }

  void storeToken(String token) {
    sharedPrefs.setString('token', token);
  }

  void storeUser(UserAccount user) {
    sharedPrefs.setString('user', user.toJson());
  }

  void updateUserAccount(UserAccount user) {
    _setUser(
      token!,
      user,
    );
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

    final con = signlRBloc.hubConnection;

    if (con != null && con.state == HubConnectionState.Connected) {
      await signlRBloc.disconnect();
    }

    _authResultStreamController.add(right(null));
    _currentUserRaw = null;
    _token = null;
  }
}
