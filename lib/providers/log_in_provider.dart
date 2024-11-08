import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/api_error.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/services/api.dart';
import 'package:go/services/app_user.dart';
import 'package:go/services/auth_provider.dart';
import 'package:go/services/user_authentication_model.dart';
import 'package:go/services/user_details_dto.dart';

class LogInProvider {
  final AuthProvider authBloc;
  LogInProvider({
    required this.authBloc,
  });

  final api = Api();

  Future<Either<AppError, AppUser>> logIn(String email, String password) async {
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
            () => api.passwordLogin(UserDetailsDto(email, false, password)))
        .mapLeft(AppError.fromApiError);

    var res = logInRes.flatMap(
        (r) => TaskEither(() => authBloc.registerUser(r.token, r.user)));

    return await res.run();
  }
}
