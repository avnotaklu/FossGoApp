extension DurationExtension on Duration {
  String durationRepr() {
    var days = inDays;
    var hours = inHours % 24;
    var minutes = inMinutes % 60;
    var seconds = inSeconds % 60;

    var daysS = days > 0 ? "${days}d" : "";
    var hoursS = hours > 0 ? "${hours}h" : "";
    var minutesS = minutes > 0 ? "${minutes}m" : "";
    var secondsS = seconds > 0 ? "${seconds}s" : "";

    return "$daysS$hoursS$minutesS$secondsS";
  }
}
