import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

extension ReadOrNull on BuildContext {
  T? readOrNull<T>() {
    try {
      return read<T>();
    } on ProviderNotFoundException catch (_) {
      return null;
    }
  }
}
