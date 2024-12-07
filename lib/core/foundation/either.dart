import 'package:fpdart/fpdart.dart';
import 'package:go/core/error_handling/base_error.dart';

extension BetterEither<E, A> on Either<E, A> {
  Either<E, Either<E, B>> mapUp<B>(Either<E, B> Function(A) p) {
    return map(p);
  }

  (E?, A?) toRecord() {
    return fold((l) => (l, null), (r) => (null, r));
  }
}

typedef ErrorOr<T> = Either<BaseError, T>;
