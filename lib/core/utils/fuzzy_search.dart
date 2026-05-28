import 'dart:math';

/// Calculates the Levenshtein distance between two strings.
/// Returns the distance score (0 means exact match).
int levenshteinDistance(String a, String b) {
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  List<int> v0 = List<int>.filled(b.length + 1, 0);
  List<int> v1 = List<int>.filled(b.length + 1, 0);

  for (int i = 0; i <= b.length; i++) {
    v0[i] = i;
  }

  for (int i = 0; i < a.length; i++) {
    v1[0] = i + 1;

    for (int j = 0; j < b.length; j++) {
      int cost = (a[i] == b[j]) ? 0 : 1;
      v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
    }

    for (int j = 0; j <= b.length; j++) {
      v0[j] = v1[j];
    }
  }

  return v1[b.length];
}

/// Applies fuzzy search over a list of items based on a specific string payload.
/// Items with distance higher than maxDistance are dropped.
/// Items are sorted ascending by distance (0 first).
List<T> fuzzyFilterAndSort<T>(
  List<T> items,
  String query,
  String Function(T) getPayload, {
  int maxDistance = 5,
}) {
  if (query.isEmpty) return items;

  final scoredItems = <_ScoredItem<T>>[];
  for (var item in items) {
    final payload = getPayload(item);
    final distance = levenshteinDistance(query, payload);
    if (distance <= maxDistance) {
      scoredItems.add(_ScoredItem(item, distance));
    }
  }

  scoredItems.sort((a, b) => a.score.compareTo(b.score));
  return scoredItems.map((e) => e.item).toList();
}

class _ScoredItem<T> {
  final T item;
  final int score;

  _ScoredItem(this.item, this.score);
}
