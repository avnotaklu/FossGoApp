// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fpdart/fpdart.dart';

import 'package:go/core/error_handling/app_error.dart';
import 'package:go/services/api.dart';
import 'package:go/services/app_user.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/services/public_user_info.dart';
import 'package:go/services/user_details_dto.dart';

class SignUpProvider {
  final AuthProvider authBloc;
  SignUpProvider({
    required this.authBloc,
  });
  final api = Api();

  Future<Either<AppError, PublicUserInfo>> signUp(
      String email, String password) async {
    // regex for email validation
    final RegExp emailRegex = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

    if (!emailRegex.hasMatch(email)) {
      return Either.left(AppError(message: "Invalid email"));
    }

    if (password.length < 6) {
      return Either.left(
          AppError(message: "Password must be at least 6 characters"));
    }

    var logInRes = TaskEither(
        () => api.passwordSignUp(UserDetailsDto(email, false, password)));

    var res = logInRes.flatMap(
      (r) => TaskEither(
        () => authBloc.authenticateNormalUser(r.user, r.token),
      ),
    );

    return await res.run();
  }
}
