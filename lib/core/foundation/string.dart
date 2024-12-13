extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

extension TypeToString<T> on T {
  String stringConv(String Function(T) f) {
    return f(this);
  }
}
