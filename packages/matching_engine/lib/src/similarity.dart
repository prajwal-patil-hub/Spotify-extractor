import 'dart:math';

/// Pure string-similarity primitives. All inputs are expected to be
/// pre-normalized (folded case, stripped diacritics) — see Normalizer.

/// Jaro similarity in [0,1].
double jaro(String a, String b) {
  if (a == b) return 1;
  if (a.isEmpty || b.isEmpty) return 0;
  final window = max(a.length, b.length) ~/ 2 - 1;
  final bMatched = List.filled(b.length, false);
  final aMatches = <int>[];
  for (var i = 0; i < a.length; i++) {
    final from = max(0, i - window);
    final to = min(b.length - 1, i + window);
    for (var j = from; j <= to; j++) {
      if (!bMatched[j] && a[i] == b[j]) {
        bMatched[j] = true;
        aMatches.add(i);
        break;
      }
    }
  }
  if (aMatches.isEmpty) return 0;
  final m = aMatches.length;
  var transpositions = 0;
  var k = 0;
  for (final i in aMatches) {
    while (!bMatched[k]) {
      k++;
    }
    if (a[i] != b[k]) transpositions++;
    k++;
  }
  final t = transpositions / 2;
  return (m / a.length + m / b.length + (m - t) / m) / 3;
}

/// Jaro-Winkler: Jaro boosted by common prefix (up to 4 chars, p=0.1).
double jaroWinkler(String a, String b) {
  final j = jaro(a, b);
  var prefix = 0;
  for (var i = 0; i < min(4, min(a.length, b.length)); i++) {
    if (a[i] == b[i]) {
      prefix++;
    } else {
      break;
    }
  }
  return j + prefix * 0.1 * (1 - j);
}

/// Cosine similarity over whitespace token sets in [0,1] — order-insensitive,
/// robust to word reshuffles ("The Boxer - Simon & Garfunkel" listings).
double tokenSetCosine(String a, String b) {
  final ta = a.split(' ').where((t) => t.isNotEmpty).toSet();
  final tb = b.split(' ').where((t) => t.isNotEmpty).toSet();
  if (ta.isEmpty || tb.isEmpty) return 0;
  final common = ta.intersection(tb).length;
  return common / sqrt(ta.length * tb.length);
}

/// Title similarity: the max of character-level and token-level views —
/// each covers the other's blind spot (typos vs. reordering).
double titleSimilarity(String a, String b) =>
    max(jaroWinkler(a, b), tokenSetCosine(a, b));
