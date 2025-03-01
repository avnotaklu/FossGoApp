// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fpdart/fpdart.dart';
import 'package:go/constants/constants.dart';

import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/validation/validator.dart';
import 'package:go/services/api.dart';
import 'package:go/models/user_account.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/models/public_user_info.dart';
import 'package:go/models/user_details_dto.dart';

class SignUpProvider {
  final AuthProvider authBloc;

  SignUpProvider({
    required this.authBloc,
    required this.api,
  });

  final Api api;

  Validator<String?, String> usernameValidator() {
    return RequiredValidator(
        Validator.getValidator(Validations.validateUsernameFirst).add(
            Validator.getValidator(Validations.validateUsernameCharacters)));
  }

  Validator<String?, String> passwordValidator() {
    return RequiredValidator(
        Validator.getValidator(Validations.validatePassword));
  }

  Future<Either<AppError, AbstractUserAccount>> signUp(
      String username, String password) async {
    var usernameRes = usernameValidator().validate(username);

    if (usernameRes.isLeft()) {
      return Either.left(
          AppError(message: usernameRes.getLeft().toNullable()!));
    }

    var passwordRes = passwordValidator().validate(password);
    if (passwordRes.isLeft()) {
      return Either.left(
          AppError(message: passwordRes.getLeft().toNullable()!));
    }

    var logInRes = TaskEither(
      () => api.passwordSignUp(
        UserDetailsDto(
          username: username,
          password: password,
          googleSignIn: false,
        ),
      ),
    );

    var res = logInRes.flatMap(
      (r) => TaskEither(
        () => authBloc.authenticateNormalUser(r.user, r.creds),
      ),
    );

    return await res.run();
  }
}
