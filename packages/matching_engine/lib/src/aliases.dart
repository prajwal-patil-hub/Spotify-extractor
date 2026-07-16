/// Artist alias resolution: curated seeds plus aliases learned from user
/// corrections (docs/07 §5 — review decisions feed this table).
///
/// All names are expected pre-folded (Normalizer.fold + leading-"the" drop).
class AliasTable {
  AliasTable({Map<String, Set<String>>? seed})
    : _groups = {
        for (final entry in (seed ?? _curatedSeed).entries)
          entry.key: {entry.key, ...entry.value},
      } {
    _reindex();
  }

  /// canonical → all names in the group (including the canonical).
  final Map<String, Set<String>> _groups;
  final Map<String, String> _nameToCanonical = {};

  static const Map<String, Set<String>> _curatedSeed = {
    'beyonce': {'beyonce knowles'},
    'pink': {'p!nk'},
    'kesha': {r'ke$ha'},
    'bts': {'방탄소년단', 'bangtan boys', 'bangtan sonyeondan'},
    'the weeknd': {'weeknd'},
    'jay-z': {'jay z', 'jayz'},
    'a. r. rahman': {'a r rahman', 'ar rahman'},
  };

  void _reindex() {
    _nameToCanonical.clear();
    _groups.forEach((canonical, names) {
      for (final name in names) {
        _nameToCanonical[name] = canonical;
      }
    });
  }

  String canonical(String foldedName) =>
      _nameToCanonical[foldedName] ?? foldedName;

  bool areAliases(String a, String b) => canonical(a) == canonical(b);

  /// Learns an equivalence from a confirmed user correction.
  void learn(String foldedA, String foldedB) {
    final canonicalA = canonical(foldedA);
    final canonicalB = canonical(foldedB);
    if (canonicalA == canonicalB) return;
    final merged = {
      ...(_groups.remove(canonicalA) ?? {foldedA, canonicalA}),
      ...(_groups.remove(canonicalB) ?? {foldedB, canonicalB}),
    };
    _groups[canonicalA] = merged;
    _reindex();
  }
}
