import 'package:fpdart/fpdart.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/foundation/fpdart.dart';
import 'package:go/core/validation/validator.dart';
import 'package:go/modules/auth/sign_in_dto.dart';
import 'package:go/services/api.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/services/google_o_auth_model.dart';
import 'package:go/services/public_user_info.dart';
import 'package:go/services/user_account.dart';

class NewOAuthProvider {
  final AuthProvider authBloc;
  final String token;

  NewOAuthProvider({
    required this.authBloc,
    required this.token,
  });

  final api = Api();

  Validator<String?, String> usernameValidator() {
    return RequiredValidator(
        Validator.getValidator(Validations.validateUsernameFirst).add(
            Validator.getValidator(Validations.validateUsernameCharacters)));
  }

  Future<Either<AppError, UserAccount>> signUp(
    String username,
  ) async {
    var usernameRes = usernameValidator().validate(username);
    return usernameRes.fold((l) async => Either.left(AppError(message: l)),
        (username) async {

      var logInRes = TaskEither(() => api.googleSignUp(
            GoogleSignUpBody(
              username: username,
            ),
            token,
          ));

      var res = logInRes.flatMap(
        (r) => TaskEither(
          () => authBloc.authenticateNormalUser(r.user, r.token),
        ),
      );

      return await res.run();
    });
  }
}
