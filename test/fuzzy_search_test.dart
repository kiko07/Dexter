import 'package:flutter_test/flutter_test.dart';
import 'package:dexter/core/utils/fuzzy_search.dart';

void main() {
  test('fuzzyFilterAndSort sorts best matches first', () {
    final list = ['apple', 'pineapple', 'app', 'apply'];
    
    final results = fuzzyFilterAndSort<String>(
      list,
      'apple',
      (item) => item,
    );

    expect(results.first, 'apple'); // Exact match first
    expect(results[1], 'apply'); // 1 char difference
  });

  test('levenshtein distance calculates correctly', () {
    expect(levenshteinDistance('kitten', 'sitting'), 3);
    expect(levenshteinDistance('flaw', 'lawn'), 2);
    expect(levenshteinDistance('gumbo', 'gambol'), 2);
  });
}
