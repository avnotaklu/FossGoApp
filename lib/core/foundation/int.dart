
extension IntFoundation on int {
  String signedString() {
    if (this == 0) return "0";
    return this > 0 ? "+$this" : "$this";
  }
}
