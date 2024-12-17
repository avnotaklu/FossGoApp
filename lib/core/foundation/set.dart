extension SetExtension<T> on Set<T> {
  Set<T> symmetricDifference(Set<T> set2) {
    return difference(set2).union(set2.difference(this));
  }
}
