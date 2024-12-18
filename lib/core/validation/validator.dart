import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

abstract class Validator<T, R> {
  final Either<String, R> Function(T) _validate;
  Validator(Either<String, R> Function(T) validator) : _validate = validator;

  Either<String, R> validate(T value) {
    return _validate(value);
  }

  String? flutterFieldValidate(T value) {
    var res = _validate(value);
    return res.swap().toOption().toNullable();
  }

  static SimpleValidator<String, String> getValidator(
      String? Function(String) self) {
    Either<String, String> validateFunc(String v) {
      var res = self.call(v);
      if (res != null) {
        return left(res);
      } else {
        return right(v);
      }
    }

    return SimpleValidator(validateFunc);
  }
}

class SimpleValidator<T, R> extends Validator<T, R> {
  SimpleValidator(super.validate);

  SimpleValidator<T, X> add<X>(Validator<R, X> v) {
    return SimpleValidator((T value) {
      final res = _validate(value);
      return res.flatMap((a) => v.validate(a));
    });
  }
}

class NonRequiredValidator extends Validator<String?, String?> {
  final Validator<String, String> validator;
  @override
  NonRequiredValidator(this.validator)
      : super((String? value) {
          if (value == null) return right(null);
          if (value.isEmpty) return right(null);

          return validator.validate(value);
        });

  // /// This method is unsafe, non required can't ever return with validator same type due to nullability
  // @protected
  // @override
  // Validator<String?, X> add<X>(Validator<String?, X> v) {
  //   return SimpleValidator((String? value) {
  //     final res = _validate(value);
  //     return res.flatMap(
  //       (a) => a == null
  //           ? right(null
  //               as X /* FIXME: Type bomb, this is the result of not having reflection, always ensure X is nullable when using with NonRequiredValidator */)
  //           : v.validate(a),
  //     );
  //   });
  // }

  // Validator<String?, X?> add2<X>(Validator<String, X> v) {
  //   return SimpleValidator((String? value) {
  //     final res = _validate(value);
  //     return res.flatMap(
  //       (a) => a == null ? right(null) : v.validate(a),
  //     );
  //   });
  // }
}

class RequiredValidator extends Validator<String?, String> {
  final Validator<String, String> validator;
  @override
  RequiredValidator(this.validator)
      : super((String? value) {
          if (value == null || value.isEmpty) {
            return left("This field is required");
          }
          return validator.validate(value);
        });
}

class OrValidator<T, O, R> extends Validator<T, Either<O, R>> {
  final Validator<T, O> _validator1;
  final Validator<T, R> _validator2;

  OrValidator(this._validator1, this._validator2,
      String Function(String, String) errorFormatter)
      : super((T value) {
          var res = _validator1
              .validate(value)
              .mapLeft(
                (e1) => _validator2
                    .validate(value) // Validate the second guy
                    .map((v1) => right<O, R>(v1))
                    .mapLeft((e2) =>
                        errorFormatter(e1, e2)) // Get the formatted error
                    .swap(), // swap cuz we can only ignore left side
              )
              .map((v1) => left<O, R>(v1))
              .swap()
              .flatMap(identity);

          return res.swap();
        });
}
