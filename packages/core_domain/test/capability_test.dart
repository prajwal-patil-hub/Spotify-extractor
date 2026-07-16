import 'package:core_domain/core_domain.dart';
import 'package:test/test.dart';

void main() {
  group('ProviderCapabilities', () {
    final source = ProviderCapabilities(
      supported: {
        Capability.likedSongs,
        Capability.playlistArtworkUpload,
        Capability.playlistDescription,
        Capability.isrcLookup,
      },
      details: {
        Capability.playlistArtworkUpload: const CapabilityDetail(
          note: 'JPEG only, max 256 KB',
        ),
      },
    );

    final destination = ProviderCapabilities(
      supported: {
        Capability.likedSongs,
        Capability.playlistDescription,
        Capability.catalogSearch,
      },
    );

    test('supports() reflects the declared set', () {
      expect(source.supports(Capability.isrcLookup), isTrue);
      expect(source.supports(Capability.queue), isFalse);
    });

    test('intersect keeps only capabilities both sides support', () {
      final effective = source.intersect(destination);
      expect(effective.supported, {
        Capability.likedSongs,
        Capability.playlistDescription,
      });
      // Artwork dropped: destination cannot accept it — the docs/02 YTM case.
      expect(effective.supports(Capability.playlistArtworkUpload), isFalse);
    });

    test('intersect prefers the destination caveat, falls back to source', () {
      final dst = ProviderCapabilities(
        supported: {Capability.playlistDescription},
        details: {
          Capability.playlistDescription: const CapabilityDetail(
            note: 'max 500 chars',
          ),
        },
      );
      final src = ProviderCapabilities(
        supported: {Capability.playlistDescription},
        details: {
          Capability.playlistDescription: const CapabilityDetail(
            note: 'max 300 chars',
          ),
        },
      );
      expect(
        src.intersect(dst).detailOf(Capability.playlistDescription)?.note,
        'max 500 chars',
      );
      expect(
        dst.intersect(src).detailOf(Capability.playlistDescription)?.note,
        'max 300 chars',
      );
    });

    test('collections are immutable', () {
      expect(
        () => source.supported.add(Capability.queue),
        throwsUnsupportedError,
      );
    });

    test('value equality', () {
      expect(
        ProviderCapabilities(supported: {Capability.likedSongs}),
        ProviderCapabilities(supported: {Capability.likedSongs}),
      );
      expect(ProviderCapabilities.none, ProviderCapabilities(supported: {}));
    });
  });
}
