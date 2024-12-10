import 'dart:convert';

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

Option<T> tryParse<T>(
    Map<String, dynamic> data, T Function(Map<String, dynamic>) parser) {
  try {
    return some(parser(data));
  } catch (e) {
    return none();
  }
}

Option<T> tryParseJ<T>(String data, T Function(Map<String, dynamic>) parser) {
  return tryParse(json.decode(data) as Map<String, dynamic>, parser);
}
