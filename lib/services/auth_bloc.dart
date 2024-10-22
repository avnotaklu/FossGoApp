import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/api_error.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/services/api.dart';
import 'package:go/services/app_user.dart';
import 'package:go/services/auth.dart';
import 'package:go/services/register_player_dto.dart';
import 'package:go/services/user_authentication_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthBloc {
  final authService = Auth();
  final api = Api();
  final googleSignIn = GoogleSignIn(
      scopes: [
        // 'https://www.googleapis.com/auth/userinfo.email',
        // 'https://www.googleapis.com/auth/userinfo.profile',
        'email'
      ],
      clientId:
          "983500952462-p1upu5nu2bis5565bj6nbqu3iqsp5209.apps.googleusercontent.com");
  final StreamController<AppUser?> _currentUserStreamController =
      StreamController.broadcast();
  Stream<AppUser?> get currentUser => _currentUserStreamController.stream;
  String? token;

  List<AppUser> otherActivePlayers = [];

  Future<Either<AppError, UserAuthenticationModel>> loginGoogle() async {
    try {
      Future<GoogleSignInAccount?> googleUser() async =>
          await googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth =
          await (await googleUser())!.authentication;

      // final AuthCredential credential = GoogleAuthProvider.credential(
      //     idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

      // final result = await authService.signInWithCredentials(credential);
      final result = await api.googleSignIn(googleAuth);

      return result.mapLeft(
        (e) => AppError(message: e.message),
      );
    } catch (error) {
      debugPrint(error.toString());

      return Either.left(
        AppError(message: error.toString()),
      );
    }
  }

  void setUser(AppUser user, String token, String signalRConnectionId) async {
    this.token = token;
    var registerRes = await api.registerPlayer(
      RegisterPlayerDto(connectionId: signalRConnectionId),
      token,
    );
    registerRes.fold((e) {
      debugPrint(e.toString());
    }, (v) {
      otherActivePlayers = v.otherActivePlayers;
      _currentUserStreamController.add(user);
      debugPrint("email");
    });
  }

  logout() {
    authService.logout();
  }
}
