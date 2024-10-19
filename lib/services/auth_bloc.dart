import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go/services/api.dart';
import 'package:go/services/app_user.dart';
import 'package:go/services/auth.dart';
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
    clientId: "983500952462-p1upu5nu2bis5565bj6nbqu3iqsp5209.apps.googleusercontent.com"
  );
  final StreamController<AppUser?> _currentUserStreamController =
      StreamController.broadcast();
  Stream<AppUser?> get currentUser => _currentUserStreamController.stream;

  loginGoogle() async {
    try {
      Future<GoogleSignInAccount?> googleUser() async =>
          await googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth =
          await (await googleUser())!.authentication;

      // final AuthCredential credential = GoogleAuthProvider.credential(
      //     idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

      // final result = await authService.signInWithCredentials(credential);
      final result = await api.googleSignIn(googleAuth);

      result.fold((e) {
        debugPrint(e.toString());
      }, (v) {
        debugPrint("email");
        debugPrint('${v.user?.email}');
        _currentUserStreamController.add(v.user);
        debugPrint("email");
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void setUser(AppUser user) {
    _currentUserStreamController.add(user);
  }

  logout() {
    authService.logout();
  }
}
