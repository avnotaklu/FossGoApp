import 'dart:math';

extension DurationExtension on Duration {
  String smallRepr() {
    var days = inDays;
    var hours = inHours % 24;
    var minutes = inMinutes % 60;
    var seconds = inSeconds % 60;

    var daysS = days > 0 ? "${days}d " : "";
    var hoursS = hours > 0 ? "${hours}h " : "";
    var minutesS = minutes > 0 ? "${minutes}m " : "";
    var secondsS = seconds > 0 ? "${seconds}s" : "";

    return "$daysS$hoursS$minutesS$secondsS";
  }

  String bigRepr([int truncation = 0]) {
    var days = inDays;
    var hours = inHours % 24;
    var minutes = inMinutes % 60;
    var seconds = inSeconds % 60;

    var daysS = days > 0 ? "${days} Days" : "";
    var hoursS = hours > 0 ? "${hours} Hours" : "";
    var minutesS = minutes > 0 ? "${minutes} Mins" : "";
    var secondsS = seconds > 0 ? "${seconds} Secs" : "";

    var parts =
        [daysS, hoursS, minutesS, secondsS].where((a) => a.isNotEmpty).toList();

    if (truncation > 0) {
      parts = parts.sublist(0, min(truncation, parts.length));
    }

    return parts.join(", ");
  }

  /// Returns the division by precision of seconds
  int dividedBy(Duration other) {
    return (inSeconds / other.inSeconds).round();
  }
}
