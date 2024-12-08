import 'package:fpdart/fpdart.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/foundation/either.dart';
import 'package:go/core/validation/validator.dart';
import 'package:go/modules/auth/sign_in_dto.dart';
import 'package:go/services/api.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/services/public_user_info.dart';

class LogInProvider {
  final AuthProvider authBloc;
  LogInProvider({
    required this.authBloc,
  });

  final api = Api();

  Validator<String?, String> usernameValidator() {
    return NonRequiredValidator()
        .add(Validator.getValidator(Validations.validateUsernameFirst))
        .add(Validator.getValidator(Validations.validateUsernameCharacters));
  }

  Validator<String?, String> emailValidator() {
    return NonRequiredValidator()
        .add(Validator.getValidator(Validations.validateEmail));
  }

  OrValidator<String?, String, String> emailOrUsernameValidator() {
    return OrValidator(usernameValidator(), emailValidator(),
        (usernameE, emailE) => "Invalid username or email");
  }

  Future<Either<AppError, PublicUserInfo>> logIn(
    String authName,
    String password,
  ) async {
    var emailOrUsernameRes = emailOrUsernameValidator().validate(authName);
    return emailOrUsernameRes.fold(
        (l) async => Either.left(AppError(message: l)), (authNameValid) async {
      var (username, email) = authNameValid.toRecord();

      if (Validations.validatePassword(password) == false) {
        return Either.left(
            AppError(message: "Password must be at least 6 characters"));
      }

      var logInRes = TaskEither(() => api.passwordLogin(SignInDto(
            email: email,
            username: username,
            password: password,
          )));

      var res = logInRes.flatMap(
        (r) => TaskEither(
          () => authBloc.authenticateNormalUser(r.user, r.token),
        ),
      );

      return await res.run();
    });
  }
}
