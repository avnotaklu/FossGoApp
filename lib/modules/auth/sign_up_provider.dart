// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fpdart/fpdart.dart';
import 'package:go/constants/constants.dart';

import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/validation/validator.dart';
import 'package:go/services/api.dart';
import 'package:go/services/user_account.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/services/public_user_info.dart';
import 'package:go/services/user_details_dto.dart';

class SignUpProvider {
  final AuthProvider authBloc;
  SignUpProvider({
    required this.authBloc,
  });
  final api = Api();

  Validator<String?, String> usernameValidator() {
    return RequiredValidator()
        .add(Validator.getValidator(Validations.validateUsernameFirst))
        .add(Validator.getValidator(Validations.validateUsernameCharacters));
  }

  Future<Either<AppError, PublicUserInfo>> signUp(
      String username, String password) async {
    var usernameRes = usernameValidator().validate(username);

    if (usernameRes.isLeft()) {
      return Either.left(
          AppError(message: usernameRes.getLeft().toNullable()!));
    }

    if (!Validations.validatePassword(password)) {
      return Either.left(
          AppError(message: "Password must be at least 6 characters"));
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
        () => authBloc.authenticateNormalUser(r.user, r.token),
      ),
    );

    return await res.run();
  }
}
