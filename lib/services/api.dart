import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/api_error.dart';
import 'package:go/services/user_authentication_model.dart';
import 'package:go/services/user_details_dto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class Api {
  final String baseUrl = "http://192.168.188.71:8080";

  Future<Either<ApiError, UserAuthenticationModel>> googleSignIn(
      GoogleSignInAuthentication userCreds) async {
    var idToken = userCreds.idToken!;
    var res = await http.get(Uri.parse("$baseUrl/Authentication/GoogleSignIn"),
        headers: {"Authorization": "Bearer $idToken"});
    if (res.statusCode == 200) {
      return Either.right(UserAuthenticationModel.fromJson(res.body));
    } else {
      return Either.left(ApiError(
          message: "Couldn't sign in with google", statusCode: res.statusCode));
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
      return Either.left(
          ApiError(message: res.body, statusCode: res.statusCode));
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
      return Either.left(
          ApiError(message: res.body, statusCode: res.statusCode));
    }
  }
}
