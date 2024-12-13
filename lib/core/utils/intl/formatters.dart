import 'package:intl/intl.dart';

extension DateTimeFormatter on DateTime {
  String toServerString() {
    return toIso8601String();
  }

  String MMM_dd_yyyy() {
    return DateFormat('MMM dd, yyyy').format(this);
  }

}
