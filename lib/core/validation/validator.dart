import 'package:fpdart/fpdart.dart';

class Validator<T, R> {
  final Either<String, R> Function(T) _validate;
  Validator(Either<String, R> Function(T) validator) : _validate = validator;

  Validator<T, X> add<X>(Validator<R, X> v) {
    return SimpleValidator((T value) {
      final res = _validate(value);
      return res.flatMap((a) => v.validate(a));
    });
  }

  Either<String, R> validate(T value) {
    return _validate(value);
  }

  String? flutterFieldValidate(T value) {
    var res = _validate(value);
    return res.swap().toOption().toNullable();
  }

  static Validator<String, String> getValidator(String? Function(String) self) {
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
}

class NonRequiredValidator extends Validator<String?, String?> {
  @override
  NonRequiredValidator()
      : super((String? value) {
          return right(value);
        });
}

class RequiredValidator extends Validator<String?, String> {
  @override
  RequiredValidator()
      : super((String? value) {
          if (value == null || value.isEmpty) {
            return left("This field is required");
          }
          return right(value);
        });
}

class OrValidator<T, O, R> extends Validator<T, Either<O, R>> {
  final Validator<T, O> _validator1;
  final Validator<T, R> _validator2;

  OrValidator(this._validator1, this._validator2)
      : super((T value) {
          var res = _validator1
              .validate(value)
              .mapLeft((e1) => _validator2
                  .validate(value)
                  .map((v1) => right<O, R>(v1))
                  .mapLeft((e2) => e1)
                  .swap())
              .map((v1) => left<O, R>(v1))
              .swap()
              .flatMap(identity);

          return res.swap();
        });
}
