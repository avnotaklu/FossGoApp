import 'package:fpdart/fpdart.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/foundation/fpdart.dart';
import 'package:go/core/validation/validator.dart';
import 'package:go/modules/auth/sign_in_dto.dart';
import 'package:go/services/api.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/models/public_user_info.dart';
import 'package:go/models/user_account.dart';

class LogInProvider {
  final AuthProvider authBloc;
  LogInProvider({
    required this.authBloc,
    required this.api,
  });

  final Api api;

  Validator<String?, String> usernameValidator() {
    return RequiredValidator(
        Validator.getValidator(Validations.validateUsernameFirst).add(
            Validator.getValidator(Validations.validateUsernameCharacters)));
    // ;
  }

  Validator<String?, String> emailValidator() {
    return RequiredValidator(Validator.getValidator(Validations.validateEmail));
  }

  OrValidator<String?, String?, String?> emailOrUsernameValidator() {
    return OrValidator(usernameValidator(), emailValidator(),
        (usernameE, emailE) => "Invalid username or email");
  }

  Validator<String?, String> passwordValidator() {
    return RequiredValidator(
        Validator.getValidator(Validations.validatePassword));
  }

  Future<Either<AppError, UserAccount>> logIn(
    String authName,
    String password,
  ) async {
    var emailOrUsernameRes = emailOrUsernameValidator().validate(authName);
    var passwordRes = passwordValidator().validate(password);
    return emailOrUsernameRes
        .map(
          (authRes) => passwordRes.map((res) => (authRes.toRecord(), res)),
        )
        .flatMap(identity)
        .fold((l) async => Either.left(AppError(message: l)),
            (authValid) async {
      var ((username, email), password) = authValid;

      if (Validations.validatePassword(password) != null) {
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
          () => authBloc.authenticateNormalUser(r.user, r.creds),
        ),
      );

      return await res.run();
    });
  }
}
