import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/api_error.dart';
import 'package:go/services/api.dart';
import 'package:go/services/user_authentication_model.dart';
import 'package:go/services/user_details_dto.dart';

class SignUpProvider {
  final api = Api();

  Future<Either<ApiError, UserAuthenticationModel>> signUp(
      String email, String password) async {
    // regex for email validation
    final RegExp emailRegex = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

    if (!emailRegex.hasMatch(email)) {
      return Either.left(ApiError(message: "Invalid email", statusCode: 400));
    }

    if(password.length < 6) {
      return Either.left(ApiError(message: "Password must be at least 6 characters", statusCode: 400));
    }

    return api.passwordSignUp(UserDetailsDto(email, false, password));
  }
}
