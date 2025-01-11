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

  UserAccount get user => auth.currentUserAccount!.forceUserAccount;

  void setup(
      void Function(
              {String? fName, String? email, String? bio, String? nationality})
          s) {
    // user.fold((l) {}, (user) {
    s.call(
      fName: user.fullName,
      email: user.email,
      bio: user.bio,
      nationality: user.nationality,
    );
    // });
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

  Validator<String?, String?> nationalityValidator() {
    return NonRequiredValidator(
        Validator.getValidator(Validations.validateNationalityLength).add(
            Validator.getValidator(Validations.validateNationalityFormat)));
  }

  Future<Either<AppError, UserAccount>> saveProfile(
      String fullName, String bio, String nationality) async {
    final fullNameRes = fullNameValidator().validate(fullName);
    final bioRes = bioValidator().validate(bio);
    final natRes = nationalityValidator().validate(nationality);

    var res = await fullNameRes
        .flatMap((f) => bioRes.map<({String? fullName, String? bio})>(
            (b) => (fullName: f, bio: b)))
        .flatMap((f) =>
            natRes.map<({String? fullName, String? bio, String? nat})>(
                (b) => (fullName: f.fullName, bio: f.bio, nat: b)))
        .match(
            (l) async =>
                Either<AppError, UserAccount>.left(AppError(message: l)),
            (r) async {
      if (user.fullName == r.fullName &&
          user.bio == r.bio &&
          user.nationality == r.nat) {
        return Either<AppError, UserAccount>.left(
            AppError(message: "No changes to save"));
      }

      var res = await api.updateProfile(
        UpdateProfileDto(
          fullName: r.fullName,
          bio: r.bio,
          nationality: r.nat,
        ),
        auth.myId,
      );

      return res.map((a) {
        auth.updateUserAccount(a.user);
        return a.user;
      });
    });

    return res;
  }
}
