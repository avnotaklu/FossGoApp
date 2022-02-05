import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class Auth{
  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<UserCredential> signInWithCredentials(AuthCredential credential) =>
  _auth.signInWithCredential(credential);
  Future<void> logout() => _auth.signOut();
  Stream<User?> get currentUser => _auth.authStateChanges();
}
