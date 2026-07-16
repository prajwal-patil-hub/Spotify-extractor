import 'package:matching_engine/matching_engine.dart';
import 'package:test/test.dart';

void main() {
  const normalizer = Normalizer();

  group('fold', () {
    test('case, diacritics, punctuation, whitespace', () {
      expect(normalizer.fold('Björk'), 'bjork');
      expect(normalizer.fold('Beyoncé'), 'beyonce');
      expect(normalizer.fold('  Déjà   Vu '), 'deja vu');
      expect(normalizer.fold('Rock & Roll'), 'rock and roll');
      expect(normalizer.fold('don’t stop'), "don't stop");
    });
  });

  group('normalizeTitle — table cases', () {
    // (raw title, expected base, expected flags)
    final cases = <(String, String, Set<VariantFlag>)>[
      ('Fast Car', 'fast car', {}),
      ('Fast Car (Live)', 'fast car', {VariantFlag.live}),
      (
        'Comfortably Numb - Live at Wembley 1988',
        'comfortably numb',
        {VariantFlag.live},
      ),
      ('Africa (2011 Remaster)', 'africa', {VariantFlag.remaster}),
      (
        'Layla - Acoustic; Live',
        'layla',
        {VariantFlag.acoustic, VariantFlag.live},
      ),
      ('Layla - Acoustic', 'layla', {VariantFlag.acoustic}),
      (
        'Wonderwall (Instrumental Version)',
        'wonderwall',
        {VariantFlag.instrumental},
      ),
      (
        'Halo (Karaoke Version) [Originally Performed by Beyoncé]',
        'halo',
        {VariantFlag.karaoke},
      ),
      (
        'Blinding Lights (Major Lazer Remix)',
        'blinding lights',
        {VariantFlag.remix},
      ),
      (
        "Love Story (Taylor's Version)",
        'love story',
        {VariantFlag.rerecording},
      ),
      (
        'One More Time - Radio Edit - 2005 Remaster',
        'one more time',
        {VariantFlag.radioEdit, VariantFlag.remaster},
      ),
      // Legit parenthetical WORDS are preserved (fold drops the parens
      // themselves — punctuation carries no matching signal):
      ("(I Can't Get No) Satisfaction", "i can't get no satisfaction", {}),
      ('99 Luftballons', '99 luftballons', {}),
    ];

    for (final (raw, base, flags) in cases) {
      test('"$raw" → "$base" $flags', () {
        final n = normalizer.normalizeTitle(raw);
        expect(n.base, base);
        expect(n.flags, flags);
      });
    }

    test('feat. extraction from parens, suffix, and bare form', () {
      for (final raw in [
        'Empire State of Mind (feat. Alicia Keys)',
        'Empire State of Mind feat. Alicia Keys',
        'Empire State of Mind [ft. Alicia Keys]',
      ]) {
        final n = normalizer.normalizeTitle(raw);
        expect(n.base, 'empire state of mind', reason: raw);
        expect(n.featuredArtists, ['alicia keys'], reason: raw);
      }
    });
  });

  group('normalizeAlbum', () {
    test('strips edition noise and variant qualifiers', () {
      expect(
        normalizer.normalizeAlbum('Thriller (Deluxe Edition)'),
        'thriller',
      );
      expect(
        normalizer.normalizeAlbum('Nevermind [2011 Remaster]'),
        'nevermind',
      );
      expect(
        normalizer.normalizeAlbum(
          '25th Anniversary Super Deluxe Edition OK Computer',
        ),
        'ok computer',
      );
    });
  });

  group('normalizeArtists', () {
    test('splits joined strings, folds, drops leading "the"', () {
      expect(normalizer.normalizeArtists(['The Beatles']), ['beatles']);
      expect(normalizer.normalizeArtists(['Simon & Garfunkel']), [
        'simon',
        'garfunkel',
      ]);
      expect(
        normalizer.normalizeArtists([
          'Silk Sonic',
          'Bruno Mars, Anderson .Paak',
        ]),
        ['silk sonic', 'bruno mars', 'anderson paak'],
      );
    });
  });
}
