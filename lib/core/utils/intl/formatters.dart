import 'dart:math';

import 'package:intl/intl.dart';

extension DateTimeFormatter on DateTime {
  String toServerString() {
    return toIso8601String();
  }

  String MMM_dd_yyyy() {
    return DateFormat('MMM dd, yyyy').format(this);
  }

  String pastTimeFrameDiffDisplay(DateTime now, [int truncation = 0]) {
    var years = now.year - year;
    var months = now.month - month;
    var days = now.day - day;
    var hours = now.hour - hour;
    var minutes = now.minute - minute;

    var yearsS = years > 0 ? "${years} Years" : "";
    var monthsS = months > 0 ? "${months} Months" : "";
    var daysS = days > 0 ? "${days} Days" : "";
    var hoursS = hours > 0 ? "${hours} Hours" : "";
    var minutesS = minutes > 0 ? "${minutes} Mins" : "";

    var parts = [yearsS, monthsS, daysS, hoursS, minutesS];

    var validParts = [];

    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        validParts.add(parts[i]);
      }

      if (validParts.length == truncation ||
          (validParts.isNotEmpty && parts[i].isEmpty)) {
        break;
      }
    }

    var partsString = validParts.join(", ") + " ago";
    return partsString;
  }
}
