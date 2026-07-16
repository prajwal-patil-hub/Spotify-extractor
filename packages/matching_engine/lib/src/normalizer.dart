import 'package:meta/meta.dart';

/// Recording-variant flags extracted from title/album qualifiers.
///
/// [hard] flags mark a *different recording* — a mismatch between source
/// and candidate halves the total score (docs/07 §4), which is the classic
/// wrong-match killer (live version auto-matching a studio request).
enum VariantFlag {
  live(hard: true),
  acoustic(hard: true),
  instrumental(hard: true),
  karaoke(hard: true),
  remix(hard: true),
  rerecording(hard: false),
  remaster(hard: false),
  demo(hard: true),
  radioEdit(hard: false);

  const VariantFlag({required this.hard});

  final bool hard;
}

/// One table row: qualifiers matching [pattern] set [flag]. The table is
/// data, not code — tuning ships as rule updates, not logic changes.
class _QualifierRule {
  const _QualifierRule(this.flag, this.pattern);

  final VariantFlag flag;
  final RegExp pattern;
}

final List<_QualifierRule> _qualifierRules = [
  _QualifierRule(VariantFlag.live, RegExp(r'\blive\b|\bunplugged\b')),
  _QualifierRule(VariantFlag.acoustic, RegExp(r'\bacoustic\b')),
  _QualifierRule(VariantFlag.instrumental, RegExp(r'\binstrumental\b')),
  _QualifierRule(
    VariantFlag.karaoke,
    RegExp(
      r'\bkaraoke\b|originally performed|in the style of|tribute( to)?\b'
      r'|\bcover( version)?\b',
    ),
  ),
  _QualifierRule(
    VariantFlag.remix,
    RegExp(r'\bremix\b|\brmx\b|\b(club|extended|dub) mix\b'),
  ),
  _QualifierRule(
    VariantFlag.rerecording,
    RegExp(r"taylor'?s version|re-?record(ed|ing)"),
  ),
  _QualifierRule(
    VariantFlag.remaster,
    RegExp(r'\bremaster(ed)?\b|\b\d{4} remaster\b'),
  ),
  _QualifierRule(VariantFlag.demo, RegExp(r'\bdemo\b')),
  _QualifierRule(
    VariantFlag.radioEdit,
    RegExp(r'\bradio edit\b|\bsingle (version|edit)\b'),
  ),
];

/// Album-edition noise stripped without setting any flag.
final RegExp _albumEditionNoise = RegExp(
  r'\b(\d+(st|nd|rd|th) )?(deluxe|expanded|anniversary|special|collector'
  r"'?s|super|platinum)( edition)?\b"
  r'|\bbonus track( version)?\b|\bedition\b',
);

final RegExp _featPattern = RegExp(
  r'\b(?:feat\.?|ft\.?|featuring|with)\s+(.+)$',
);

/// Common Latin diacritics folded to ASCII; a diacritic-preserved copy is
/// kept by callers that want the exact-form bonus (docs/07 §2).
const Map<String, String> _diacritics = {
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'å': 'a',
  'ā': 'a',
  'æ': 'ae',
  'ç': 'c',
  'č': 'c',
  'ć': 'c',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ē': 'e',
  'ę': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ī': 'i',
  'ñ': 'n',
  'ń': 'n',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ø': 'o',
  'ō': 'o',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ū': 'u',
  'ý': 'y',
  'ÿ': 'y',
  'š': 's',
  'ž': 'z',
  'ż': 'z',
  'ł': 'l',
  'ß': 'ss',
  'đ': 'd',
  'ð': 'd',
  'þ': 'th',
};

/// A title reduced to its comparable core.
@immutable
class NormalizedTitle {
  const NormalizedTitle({
    required this.base,
    required this.flags,
    required this.featuredArtists,
  });

  /// Folded, qualifier-stripped title.
  final String base;

  final Set<VariantFlag> flags;

  /// Artists extracted from feat./ft./featuring qualifiers — merged into
  /// the artist comparison, never left to pollute the title.
  final List<String> featuredArtists;
}

/// Pure, table-driven normalization (docs/07 §2). Stateless.
class Normalizer {
  const Normalizer();

  /// Case fold, diacritic fold, punctuation unification, whitespace
  /// collapse. Applied to every string before comparison.
  String fold(String input) {
    final lower = input.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_diacritics[char] ?? char);
    }
    return buffer
        .toString()
        .replaceAll(RegExp('[‘’ʼ]'), "'")
        .replaceAll(RegExp(r'[&＆]'), ' and ')
        .replaceAll(RegExp(r"[^\p{L}\p{N}\s'!$]", unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Splits qualifiers out of a raw title: parenthetical/bracket groups and
  /// ` - suffix` segments are matched against the rule table. Matching
  /// groups are stripped AND recorded as flags; non-matching parentheticals
  /// — "(I Can't Get No) Satisfaction" — are kept verbatim.
  NormalizedTitle normalizeTitle(String rawTitle) {
    final flags = <VariantFlag>{};
    final featured = <String>[];
    var working = rawTitle;

    // 1. Parenthetical/bracket groups.
    working = working.replaceAllMapped(RegExp(r'[(\[]([^)\]]*)[)\]]'), (m) {
      final inner = m.group(1)!;
      final handled = _consumeQualifier(inner, flags, featured);
      return handled ? ' ' : m.group(0)!;
    });

    // 2. ` - qualifier` suffix segments (may stack: "X - Live - 2011 Remaster").
    var changed = true;
    while (changed) {
      changed = false;
      final dash = working.lastIndexOf(' - ');
      if (dash > 0) {
        final suffix = working.substring(dash + 3);
        if (_consumeQualifier(suffix, flags, featured)) {
          working = working.substring(0, dash);
          changed = true;
        }
      }
    }

    // 3. Trailing feat. outside any group: "Song feat. X".
    working = working.replaceAllMapped(_featPattern, (m) {
      featured.addAll(_splitArtists(m.group(1)!));
      return ' ';
    });

    return NormalizedTitle(
      base: fold(working),
      flags: flags,
      featuredArtists: [for (final f in featured) fold(f)],
    );
  }

  /// Album titles: strip edition noise and variant qualifiers (recorded as
  /// flags by the caller when needed via [normalizeTitle]).
  String normalizeAlbum(String rawAlbum) {
    final working = rawAlbum.replaceAllMapped(RegExp(r'[(\[]([^)\]]*)[)\]]'), (
      m,
    ) {
      final inner = fold(m.group(1)!);
      final isNoise =
          _albumEditionNoise.hasMatch(inner) ||
          _qualifierRules.any((r) => r.pattern.hasMatch(inner));
      return isNoise ? ' ' : m.group(0)!;
    });
    // Noise stripping runs on folded text so the patterns stay lowercase.
    return fold(working)
        .replaceAll(_albumEditionNoise, ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Splits joined artist strings, folds each, drops a leading "the ".
  List<String> normalizeArtists(Iterable<String> rawArtists) => [
    for (final raw in rawArtists)
      for (final part in _splitArtists(raw)) _dropLeadingThe(fold(part)),
  ];

  bool _consumeQualifier(
    String segment,
    Set<VariantFlag> flags,
    List<String> featured,
  ) {
    final folded = fold(segment);
    final feat = _featPattern.firstMatch(folded);
    if (feat != null) {
      featured.addAll(_splitArtists(feat.group(1)!));
      // A group can carry both feat and a variant ("Live feat. X").
    }
    var matched = feat != null;
    for (final rule in _qualifierRules) {
      if (rule.pattern.hasMatch(folded)) {
        flags.add(rule.flag);
        matched = true;
      }
    }
    if (_albumEditionNoise.hasMatch(folded)) matched = true;
    return matched;
  }

  static List<String> _splitArtists(String joined) => joined
      .split(RegExp(r',|&| x |×|\band\b|\bwith\b'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  static String _dropLeadingThe(String name) =>
      name.startsWith('the ') ? name.substring(4) : name;
}
