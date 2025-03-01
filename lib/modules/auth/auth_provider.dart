import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/services/api.dart';
import 'package:go/models/auth_creds.dart';
import 'package:go/models/google_o_auth_model.dart';
import 'package:go/services/local_datasource.dart';
import 'package:go/models/user_account.dart';
import 'package:go/models/guest_user.dart';
import 'package:go/models/public_user_info.dart';

import 'package:go/models/register_player_dto.dart';
import 'package:go/models/register_user_result.dart';
import 'package:go/models/user_authentication_model.dart';
import 'package:go/models/player_rating.dart';
import 'package:go/models/user_rating_result.dart';
import 'package:go/models/user_stats.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/hub_connection.dart';

class AuthProvider {
  final LocalDatasource localDatasource;
  final SignalRProvider signlRBloc;

  final Api api;

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

  AuthCreds? get _authCreds => api.authCreds;
  set _authCreds(AuthCreds? creds) => api.authCreds = creds;

  Completer<Either<AppError, UserAccount?>> initialAuth = Completer();

  // bool locallyInitialedAuth = false;
  AuthProvider(this.signlRBloc, this.localDatasource, this.api) {
    getToken().then((value) {
      if (value != null) {
        getUser(value).then((authRes) {
          authRes.fold((e) {
            debugPrint(e.toString());
          }, (m) async {
            _authCreds = value;
            var res = await authenticateNormalUser(m.user, m.creds);
            res.fold((l) {}, (r) {
              _setUser(_authCreds!, r);
              initialAuth.complete(res);
            });
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

  Future<Either<AppError, Either<String, UserAccount>>> loginGoogle() async {
    try {
      Future<GoogleSignInAccount?> googleUser() async =>
          await googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth =
          await (await googleUser())!.authentication;

      final result = TaskEither(
        () => api.googleSignIn(GoogleSignInBody(token: googleAuth.idToken!)),
      );

      // FIXME: Here be dragons
      var res = result.map((r) {
        if (r.authenticated) {
          return right<String, UserAuthenticationModel>(r.auth!);
        } else {
          return left<String, UserAuthenticationModel>(r.newOAuthToken!);
        }
      });

      var mapCircus = res.map((r) {
        var res = r.map((r) {
          return TaskEither(() {
            return (authenticateNormalUser(
              r.user,
              r.creds,
            ));
          });
        });
        return res;
      });

      var taskEitherWrestling =
          mapCircus.match<TaskEither<AppError, Either<String, UserAccount>>>(
        (l) {
          return TaskEither(() => Future.value(left(l)));
        },
        (r) {
          return r.match((l) {
            return TaskEither(() => Future.value(right(left(l))));
          }, (r) {
            var res = r.map((r) => right<String, UserAccount>(r));
            return res;
          });
        },
      );

      var magicShow = await (await taskEitherWrestling.run()).run();
      return magicShow;
    } on PlatformException catch (error) {
      debugPrint(error.toString());

      return Either.left(
        AppError(message: error.message ?? "Platform error"),
      );
    }
  }

  void _setUser(AuthCreds creds, AbstractUserAccount user) {
    _currentUserRaw = user;
    _authCreds = creds;

    if (user is UserAccount) {
      storeToken(creds);
      storeUser(user);
    }

    debugPrint("email");
  }

  Future<Either<AppError, UserAccount>> authenticateNormalUser(
      UserAccount user, AuthCreds creds) async {
    final registerTas = _connectUser(user.id, creds);

    var res = (await registerTas.run()).flatMap((r) {
      _setUser(creds, user);
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
      return TaskEither(() => authenticateGuestUser(r.user, r.creds));
    }).run();
  }

  Future<Either<AppError, GuestUser>> authenticateGuestUser(
      GuestUser user, AuthCreds creds) async {
    final registerTas = _connectUser(user.id, creds);

    var res = (await registerTas.run()).flatMap((r) {
      _setUser(creds, user);
      return right(user);
    }).mapLeft((e) {
      signlRBloc.disconnect();
      return e;
    });

    _authResultStreamController.add(res);
    return res;
  }


  Future<Either<AppError, String>> connectUser() {
    return signlRBloc.connectSignalR(_authCreds!);
  }
  

  TaskEither<AppError, String> _connectUser(String userId, AuthCreds creds) {
    var signalRConnectionId =
        TaskEither(() => signlRBloc.connectSignalR(creds));
    return signalRConnectionId;
  }

  Future<Either<AppError, RegisterUserResult>> _registerUser(
      String token, String signalRConnectionId) async {
    var registerRes = await api.registerPlayer(
      RegisterPlayerDto(connectionId: signalRConnectionId),
    );
    return registerRes;
  }

  Future<Either<AppError, PlayerRating>> _userRatingResult(
      String token, String userId) async {
    var registerRes = await api.getUserRating(
      userId,
    );
    return registerRes;
  }

  Future<Either<AppError, UserStat>> _userStatResult(
      String token, String userId) async {
    var registerRes = await api.getUserStats(
      userId,
    );
    return registerRes;
  }

  void storeToken(AuthCreds creds) {
    localDatasource.storeAuthCreds(creds);
  }

  void storeUser(UserAccount user) {
    localDatasource.storeUser(user);
  }

  void updateUserAccount(UserAccount user) {
    _setUser(
      _authCreds!,
      user,
    );
  }

  Future<AuthCreds?> getToken() {
    return localDatasource.getAuthCreds();
  }

  Future<Either<AppError, UserAuthenticationModel>> getUser(
      AuthCreds creds) async {
    var res = await api.getUser(creds);
    return res;
  }

  Future<void> logout() async {
    await localDatasource.clear();

    final con = signlRBloc.hubConnection;

    if (con != null && con.state == HubConnectionState.Connected) {
      await signlRBloc.disconnect();
    }

    _authResultStreamController.add(right(null));
    _currentUserRaw = null;
    _authCreds = null;
  }
}
