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

/// Applies tokenized fuzzy search over a list of items.
/// A row matches when every query token is close to at least one payload token.
/// Items are sorted ascending by distance (0 first).
List<T> fuzzyFilterAndSort<T>(
  List<T> items,
  String query,
  String Function(T) getPayload, {
  int? maxDistance,
}) {
  if (query.isEmpty) return items;

  final queryTokens = _tokens(query);
  if (queryTokens.isEmpty) return items;

  final scoredItems = <_ScoredItem<T>>[];
  for (var item in items) {
    final payloadTokens = _tokens(getPayload(item));
    if (payloadTokens.isEmpty) continue;

    var totalScore = 0;
    var matchedAllTokens = true;
    for (final queryToken in queryTokens) {
      final threshold = maxDistance ?? max(3, queryToken.length ~/ 2);
      var bestDistance = 1 << 30;
      for (final payloadToken in payloadTokens) {
        final distance = levenshteinDistance(queryToken, payloadToken);
        if (distance < bestDistance) {
          bestDistance = distance;
        }
      }
      if (bestDistance > threshold) {
        matchedAllTokens = false;
        break;
      }
      totalScore += bestDistance;
    }

    if (matchedAllTokens) {
      scoredItems.add(_ScoredItem(item, totalScore));
    }
  }

  scoredItems.sort((a, b) => a.score.compareTo(b.score));
  return scoredItems.map((e) => e.item).toList();
}

List<String> _tokens(String value) {
  return value
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .map((token) => token.trim())
      .where((token) => token.isNotEmpty)
      .toList();
}

class _ScoredItem<T> {
  final T item;
  final int score;

  _ScoredItem(this.item, this.score);
}
