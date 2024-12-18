import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go/constants/constants.dart';
import 'package:go/core/error_handling/app_error.dart';
import 'package:go/core/validation/validator.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/services/api.dart';
import 'package:go/services/update_profile_dto.dart';
import 'package:go/services/user_account.dart';

class EditProfileProvider extends ChangeNotifier {
  final Api api;
  final AuthProvider auth;

  EditProfileProvider({required this.auth, required this.api});

  Either<AppError, UserAccount> get user =>
      auth.currentUserAccount!.asUserAccount;

  void setup(
      void Function(
              {String? fName, String? email, String? bio, String? nationality})
          s) {
    user.fold((l) {}, (user) {
      s.call(
        fName: user.fullName,
        email: user.email,
        bio: user.bio,
        nationality: user.nationality,
      );
    });
  }

  Validator<String?, String?> fullNameValidator() {
    return NonRequiredValidator(
        Validator.getValidator(Validations.validateFullName));
  }

  Validator<String?, String?> emailValidator() {
    return NonRequiredValidator(
        Validator.getValidator(Validations.validateEmail));
  }

  Validator<String?, String?> bioValidator() {
    return NonRequiredValidator(
        Validator.getValidator(Validations.validateBio));
  }

  Future<Either<AppError, UserAccount>> saveProfile(
      String fullName, String bio, String nationality) async {
    var res = await api.updateProfile(
      UpdateProfileDto(
        fullName: fullName,
        bio: bio,
        nationality: nationality,
      ),
      auth.myId,
      auth.token!,
    );

    return res.map((a) {
      auth.updateUserAccount(a.user);
      return a.user;
    });
  }
}
