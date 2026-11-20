import 'dart:math' as math;

/// Where [query] appears in [text], ignoring case: S24's highlights.
List<({int start, int end})> matchRanges(String text, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  final lower = text.toLowerCase();
  final out = <({int start, int end})>[];
  var from = 0;
  while (true) {
    final at = lower.indexOf(q, from);
    if (at == -1) return out;
    out.add((start: at, end: at + q.length));
    from = at + q.length;
  }
}

/// Up to [radius] characters either side of [query]'s first match in
/// [text], with "…" where it's cut: S24's "Note matches …". Null if it
/// doesn't match.
String? snippet(String text, String query, {int radius = 20}) {
  final match = matchRanges(text, query).firstOrNull;
  if (match == null) return null;
  final start = math.max(0, match.start - radius);
  final end = math.min(text.length, match.end + radius);
  return '${start > 0 ? '…' : ''}${text.substring(start, end).trim()}'
      '${end < text.length ? '…' : ''}';
}

/// S25's "Did you mean …?": the word in [vocabulary] closest to [query],
/// at most two edits away, or null. Ties go to the more common word.
String? didYouMean(String query, Iterable<String> vocabulary) {
  final q = query.trim().toLowerCase();
  if (q.length < 3) return null;
  final counts = <String, int>{};
  for (final text in vocabulary) {
    for (final word in text.toLowerCase().split(
      RegExp(r'[^\p{L}\p{N}]+', unicode: true),
    )) {
      if (word.length >= 3) counts[word] = (counts[word] ?? 0) + 1;
    }
  }
  String? best;
  var bestDistance = 3;
  var bestCount = 0;
  for (final MapEntry(key: word, value: count) in counts.entries) {
    if (word == q || (word.length - q.length).abs() > 2) continue;
    final d = _distance(q, word);
    if (d < bestDistance || (d == bestDistance && count > bestCount)) {
      best = word;
      bestDistance = d;
      bestCount = count;
    }
  }
  return best;
}

/// Levenshtein distance.
int _distance(String a, String b) {
  var previous = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final current = [i, ...List.filled(b.length, 0)];
    for (var j = 1; j <= b.length; j++) {
      current[j] = [
        previous[j] + 1,
        current[j - 1] + 1,
        previous[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1),
      ].reduce(math.min);
    }
    previous = current;
  }
  return previous[b.length];
}
