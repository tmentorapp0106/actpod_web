import 'dart:math';

class NumberUtils {
  static double randomRangeNum(double min, double max) {
    // Create a Random object
    final random = Random();

    // Generate a random integer within the specified range
    return min + random.nextDouble() * (max - min);
  }

  static List<int> shuffledRange(int n, {int? seed}) {
    if (n < 0) throw ArgumentError('n must be >= 0');
    final rng = seed == null ? Random() : Random(seed);
    final list = List<int>.generate(n, (i) => i);
    list.shuffle(rng); // Fisher–Yates under the hood
    return list;
  }
}