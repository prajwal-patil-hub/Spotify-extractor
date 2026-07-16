/// The matching golden set (docs/12 §3) — the quality ratchet.
///
/// Each case is a real-world-shaped scenario: a source track plus the slice
/// of the destination catalog a search would plausibly return, including
/// the adversarial traps that break naive matchers. Every engine change
/// must keep the metrics in golden_test.dart green.
///
/// This is the seed set (~40 cases across every trap category); it grows
/// toward the ≥500-case target as user corrections and provider quirks
/// accumulate (docs/12 §3). Add cases — never delete or weaken one.
library;

import 'package:core_domain/core_domain.dart';

const srcProvider = ProviderId('spotify');
const dstProvider = ProviderId('ytmusic');

Track src(
  String title,
  String artist, {
  String? album,
  int? sec,
  String? isrc,
  int? year,
  bool? explicit,
  List<String> moreArtists = const [],
}) => Track(
  providerId: srcProvider,
  id: const ProviderTrackId('src'),
  title: title,
  artists: [
    Artist(name: artist),
    for (final a in moreArtists) Artist(name: a),
  ],
  album: album == null ? null : Album(title: album, releaseYear: year),
  duration: sec == null ? null : Duration(seconds: sec),
  isrc: isrc,
  releaseYear: year,
  explicit: explicit,
);

Track cand(
  String id,
  String title,
  String artist, {
  String? album,
  int? sec,
  String? isrc,
  int? year,
  bool? explicit,
  int? popularity,
  List<String> moreArtists = const [],
}) => Track(
  providerId: dstProvider,
  id: ProviderTrackId(id),
  title: title,
  artists: [
    Artist(name: artist),
    for (final a in moreArtists) Artist(name: a),
  ],
  album: album == null ? null : Album(title: album, releaseYear: year),
  duration: sec == null ? null : Duration(seconds: sec),
  isrc: isrc,
  releaseYear: year,
  explicit: explicit,
  popularity: popularity,
);

class GoldenCase {
  const GoldenCase(
    this.name, {
    required this.source,
    required this.catalog,
    this.expectedId,
    this.expectAuto = true,
  });

  final String name;
  final Track source;
  final List<Track> catalog;

  /// The correct destination track id; null = no correct match exists.
  final String? expectedId;

  /// Whether the engine is expected to auto-approve at `balanced`.
  /// False = the correct outcome is review (or no candidates).
  final bool expectAuto;
}

final List<GoldenCase> goldenCases = [
  // ── Mainstream happy paths ────────────────────────────────────────────
  GoldenCase(
    'exact mainstream hit',
    source: src(
      'Blinding Lights',
      'The Weeknd',
      album: 'After Hours',
      sec: 200,
      year: 2020,
    ),
    catalog: [
      cand(
        'ok',
        'Blinding Lights',
        'The Weeknd',
        album: 'After Hours',
        sec: 200,
        year: 2020,
      ),
      cand('bad1', 'Blinding Lights (Live)', 'The Weeknd', sec: 214),
      cand('bad2', 'Blinding Lights', 'Kidz Bop Kids', sec: 190),
    ],
    expectedId: 'ok',
  ),
  GoldenCase(
    'the-prefix and & vs and',
    source: src('Rock & Roll All Nite', 'KISS', sec: 240),
    catalog: [cand('ok', 'Rock and Roll All Nite', 'Kiss', sec: 241)],
    expectedId: 'ok',
  ),
  GoldenCase(
    'reordered feat notation',
    source: src('Empire State of Mind (feat. Alicia Keys)', 'JAY-Z', sec: 276),
    catalog: [
      cand(
        'ok',
        'Empire State of Mind',
        'Jay Z',
        moreArtists: ['Alicia Keys'],
        sec: 277,
      ),
      cand(
        'bad',
        'Empire State of Mind (Part II) Broken Down',
        'Alicia Keys',
        sec: 216,
      ),
    ],
    expectedId: 'ok',
  ),
  GoldenCase(
    'diacritics fold',
    source: src('Jóga', 'Björk', sec: 305),
    catalog: [cand('ok', 'Joga', 'Bjork', sec: 306)],
    expectedId: 'ok',
  ),
  GoldenCase(
    'artist alias P!nk',
    source: src('Just Give Me a Reason', 'P!nk', sec: 242),
    catalog: [
      cand('ok', 'Just Give Me a Reason', 'Pink', sec: 243),
      cand('bad', 'Just Give Me a Reason (Karaoke)', 'Party Tyme', sec: 242),
    ],
    expectedId: 'ok',
  ),
  GoldenCase(
    'ISRC pathway wins instantly',
    source: src('Fast Car', 'Tracy Chapman', sec: 296, isrc: 'USEE10180355'),
    catalog: [
      cand('ok', 'Fast Car', 'Tracy Chapman', sec: 296, isrc: 'USEE10180355'),
      cand('bad', 'Fast Car', 'Luke Combs', sec: 265),
    ],
    expectedId: 'ok',
  ),
  GoldenCase(
    'remaster is an acceptable auto-match for a studio request',
    source: src('Africa', 'Toto', album: 'Toto IV', sec: 295, year: 1982),
    catalog: [
      cand(
        'ok',
        'Africa (2015 Remaster)',
        'Toto',
        album: 'Toto IV',
        sec: 296,
        year: 1982,
      ),
    ],
    expectedId: 'ok',
  ),
  GoldenCase(
    'source live wants candidate live',
    source: src(
      'Comfortably Numb - Live at Pompeii',
      'David Gilmour',
      sec: 552,
    ),
    catalog: [
      cand('ok', 'Comfortably Numb (Live)', 'David Gilmour', sec: 553),
      cand('bad', 'Comfortably Numb', 'Pink Floyd', sec: 382),
    ],
    expectedId: 'ok',
  ),
  GoldenCase(
    'k-pop romanized artist alias',
    source: src('Spring Day', 'BTS', sec: 274),
    catalog: [cand('ok', 'Spring Day', '방탄소년단', sec: 275)],
    expectedId: 'ok',
  ),
  GoldenCase(
    'bollywood transliterated listing',
    source: src('Tum Hi Ho', 'Arijit Singh', album: 'Aashiqui 2', sec: 262),
    catalog: [
      cand('ok', 'Tum Hi Ho', 'Arijit Singh', album: 'Aashiqui 2', sec: 261),
      cand('bad', 'Tum Hi Ho (Cover)', 'Various Artists', sec: 250),
    ],
    expectedId: 'ok',
  ),
  GoldenCase(
    'radio edit acceptable when durations agree',
    source: src('One More Time', 'Daft Punk', sec: 320),
    catalog: [
      cand('ok', 'One More Time', 'Daft Punk', sec: 320),
      cand('near', 'One More Time - Radio Edit', 'Daft Punk', sec: 214),
    ],
    expectedId: 'ok',
  ),
  GoldenCase(
    'apostrophe unification',
    source: src('Don’t Stop Believin’', 'Journey', sec: 250),
    catalog: [cand('ok', "Don't Stop Believin'", 'Journey', sec: 251)],
    expectedId: 'ok',
  ),
  GoldenCase(
    'legit parenthetical is not stripped',
    source: src(
      "(I Can't Get No) Satisfaction",
      'The Rolling Stones',
      sec: 224,
    ),
    catalog: [
      cand('ok', "(I Can't Get No) Satisfaction", 'Rolling Stones', sec: 224),
      cand('bad', 'Satisfaction (Karaoke)', 'Hit Crew', sec: 224),
    ],
    expectedId: 'ok',
  ),
  GoldenCase(
    'album disambiguates same-artist rerelease',
    source: src(
      'All of Me',
      'John Legend',
      album: 'Love in the Future',
      sec: 270,
      year: 2013,
    ),
    catalog: [
      cand(
        'ok',
        'All of Me',
        'John Legend',
        album: 'Love in the Future',
        sec: 269,
        year: 2013,
      ),
      cand(
        'bad',
        'All of Me (Live at iTunes Festival)',
        'John Legend',
        sec: 292,
      ),
    ],
    expectedId: 'ok',
  ),

  // ── Hard-variant traps: must NEVER auto-match ─────────────────────────
  GoldenCase(
    'live trap: only live exists',
    source: src('Fast Car', 'Tracy Chapman', sec: 296),
    catalog: [
      cand('trap', 'Fast Car (Live at Wembley)', 'Tracy Chapman', sec: 312),
    ],
    expectedId: null,
    expectAuto: false,
  ),
  GoldenCase(
    'acoustic trap',
    source: src('Wonderwall', 'Oasis', sec: 258),
    catalog: [cand('trap', 'Wonderwall (Acoustic)', 'Oasis', sec: 260)],
    expectedId: null,
    expectAuto: false,
  ),
  GoldenCase(
    'instrumental trap',
    source: src('Shape of You', 'Ed Sheeran', sec: 233),
    catalog: [
      cand('trap', 'Shape of You (Instrumental)', 'Ed Sheeran', sec: 233),
    ],
    expectedId: null,
    expectAuto: false,
  ),
  GoldenCase(
    'karaoke imposter trap',
    source: src('Halo', 'Beyoncé', sec: 261),
    catalog: [
      cand(
        'trap',
        'Halo (Karaoke Version) [Originally Performed by Beyoncé]',
        'Sing King Karaoke',
        sec: 261,
      ),
    ],
    expectedId: null,
    expectAuto: false,
  ),
  GoldenCase(
    'cover imposter trap (Fast Car)',
    source: src('Fast Car', 'Tracy Chapman', sec: 296),
    catalog: [
      cand('trap', 'Fast Car', 'Luke Combs', sec: 265),
      cand(
        'trap2',
        'Fast Car (Tribute to Tracy Chapman)',
        'Cover Nation',
        sec: 296,
      ),
    ],
    expectedId: null,
    expectAuto: false,
  ),
  GoldenCase(
    'remix trap',
    source: src('Blinding Lights', 'The Weeknd', sec: 200),
    catalog: [
      cand(
        'trap',
        'Blinding Lights (Major Lazer Remix)',
        'The Weeknd',
        sec: 184,
      ),
    ],
    expectedId: null,
    expectAuto: false,
  ),
  GoldenCase(
    'demo trap',
    source: src('Creep', 'Radiohead', sec: 238),
    catalog: [cand('trap', 'Creep (Demo)', 'Radiohead', sec: 222)],
    expectedId: null,
    expectAuto: false,
  ),
  GoldenCase(
    'inverse live trap: live request, only studio exists',
    source: src('Alive (Live)', 'Pearl Jam', sec: 341),
    catalog: [cand('trap', 'Alive', 'Pearl Jam', sec: 341)],
    expectedId: null,
    expectAuto: false,
  ),

  // ── Ambiguity: correct answer exists but review is right ──────────────
  GoldenCase(
    "Taylor's Version: original requested, both exist — original wins",
    source: src(
      'Love Story',
      'Taylor Swift',
      album: 'Fearless',
      sec: 235,
      year: 2008,
    ),
    catalog: [
      cand(
        'ok',
        'Love Story',
        'Taylor Swift',
        album: 'Fearless',
        sec: 235,
        year: 2008,
      ),
      cand(
        'tv',
        "Love Story (Taylor's Version)",
        'Taylor Swift',
        album: "Fearless (Taylor's Version)",
        sec: 236,
        year: 2021,
      ),
    ],
    expectedId: 'ok',
  ),
  GoldenCase(
    "Taylor's Version: original requested, only TV exists → review",
    source: src(
      'Love Story',
      'Taylor Swift',
      album: 'Fearless',
      sec: 235,
      year: 2008,
    ),
    catalog: [
      cand(
        'tv',
        "Love Story (Taylor's Version)",
        'Taylor Swift',
        album: "Fearless (Taylor's Version)",
        sec: 236,
        year: 2021,
      ),
    ],
    expectedId: null,
    expectAuto: false,
  ),
  GoldenCase(
    'duration outlier: same text, 50 s longer → review',
    source: src('Purple Rain', 'Prince', sec: 520),
    catalog: [cand('trap', 'Purple Rain', 'Prince', sec: 570)],
    expectedId: null,
    expectAuto: false,
  ),
  GoldenCase(
    'empty catalog → confirmed miss',
    source: src('Ultra Obscure Bootleg', 'Nobody Knows', sec: 200),
    catalog: [],
    expectedId: null,
    expectAuto: false,
  ),

  // ── Messy metadata that must still auto-match ─────────────────────────
  GoldenCase(
    'no album/year/duration on candidate (YTM-typical sparseness)',
    source: src(
      'Holocene',
      'Bon Iver',
      album: 'Bon Iver, Bon Iver',
      sec: 337,
      year: 2011,
    ),
    catalog: [
      cand('ok', 'Holocene', 'Bon Iver'),
      cand('bad', 'Holocene (Live from AIR Studios)', 'Bon Iver'),
    ],
    expectedId: 'ok',
  ),
  GoldenCase(
    'explicit/clean flags disagree but everything else aligns',
    source: src('HUMBLE.', 'Kendrick Lamar', sec: 177, explicit: true),
    catalog: [
      cand('ok', 'HUMBLE.', 'Kendrick Lamar', sec: 177, explicit: false),
    ],
    expectedId: 'ok',
  ),
  GoldenCase(
    'primary artist listed with collaborators',
    source: src('Leave The Door Open', 'Silk Sonic', sec: 242),
    catalog: [
      cand(
        'ok',
        'Leave The Door Open',
        'Bruno Mars',
        moreArtists: ['Anderson .Paak', 'Silk Sonic'],
        sec: 242,
      ),
    ],
    expectedId: 'ok',
  ),
  GoldenCase(
    'deluxe album edition noise',
    source: src('Style', 'Taylor Swift', album: '1989', sec: 231, year: 2014),
    catalog: [
      cand(
        'ok',
        'Style',
        'Taylor Swift',
        album: '1989 (Deluxe Edition)',
        sec: 231,
        year: 2014,
      ),
    ],
    expectedId: 'ok',
  ),
];
