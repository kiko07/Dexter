import 'package:flutter_test/flutter_test.dart';
import 'package:dexter/core/utils/fuzzy_search.dart';

void main() {
  test('fuzzyFilterAndSort sorts best matches first', () {
    final list = ['apple', 'pineapple', 'app', 'apply'];

    final results = fuzzyFilterAndSort<String>(list, 'apple', (item) => item);

    expect(results.first, 'apple'); // Exact match first
    expect(results[1], 'apply'); // 1 char difference
  });

  test('levenshtein distance calculates correctly', () {
    expect(levenshteinDistance('kitten', 'sitting'), 3);
    expect(levenshteinDistance('flaw', 'lawn'), 2);
    expect(levenshteinDistance('gumbo', 'gambol'), 2);
  });

  test('fuzzyFilterAndSort compares query tokens with payload tokens', () {
    final list = ['ahmed cairo egypt 30', 'mohamed alexandria', 'sara cairo'];

    final results = fuzzyFilterAndSort<String>(list, 'ahmd', (item) => item);

    expect(results, contains('ahmed cairo egypt 30'));
  });
}
