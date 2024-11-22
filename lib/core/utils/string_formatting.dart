class StringFormatting {
  static String totalSecondsToDurationRepr(int totalSeconds) {
    var minutes = totalSeconds ~/ 60;
    var seconds = totalSeconds % 60;
    var minutes_s = minutes > 0 ? "${minutes}m" : "";
    var seconds_s = seconds > 0 ? "${seconds}s" : "";
    return "$minutes_s$seconds_s";
  }
}
