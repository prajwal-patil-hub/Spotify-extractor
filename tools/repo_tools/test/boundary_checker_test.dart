import 'package:repo_tools/src/boundary_checker.dart';
import 'package:test/test.dart';

void main() {
  final rules = BoundaryRules(
    allow: {
      'core_domain': [],
      'provider_api': ['core_domain'],
      'matching_engine': ['core_domain', 'provider_api'],
      'provider_*': ['core_domain', 'provider_api'],
      '*_app': ['*'],
    },
    pureDart: {'core_domain', 'provider_api', 'matching_engine'},
  );

  PackageInfo pkg(
    String name, {
    Set<String> deps = const {},
    Set<String> imports = const {},
  }) => PackageInfo(name: name, dependencies: deps, importedPackages: imports);

  test('a clean graph passes', () {
    final violations = checkBoundaries(
      packages: {
        'core_domain': pkg('core_domain', deps: {'meta', 'collection'}),
        'provider_api': pkg(
          'provider_api',
          deps: {'core_domain'},
          imports: {'core_domain'},
        ),
        'provider_spotify': pkg(
          'provider_spotify',
          deps: {'core_domain', 'provider_api', 'dio'},
        ),
        'bridgetune_app': pkg(
          'bridgetune_app',
          deps: {'flutter', 'core_domain', 'provider_spotify'},
        ),
      },
      rules: rules,
    );
    expect(violations, isEmpty);
  });

  group('deliberate violations fail (Phase-0 exit criterion)', () {
    test('core_domain importing a provider plugin is caught', () {
      final violations = checkBoundaries(
        packages: {
          'core_domain': pkg('core_domain', imports: {'provider_spotify'}),
          'provider_spotify': pkg('provider_spotify'),
        },
        rules: rules,
      );
      expect(violations, hasLength(1));
      expect(violations.single, contains('core_domain'));
      expect(violations.single, contains('provider_spotify'));
    });

    test('a provider depending on another provider is caught', () {
      final violations = checkBoundaries(
        packages: {
          'provider_spotify': pkg(
            'provider_spotify',
            deps: {'provider_ytmusic'},
          ),
          'provider_ytmusic': pkg('provider_ytmusic'),
        },
        rules: rules,
      );
      expect(violations, hasLength(1));
      expect(violations.single, contains('provider_ytmusic'));
    });

    test('a pure-Dart engine touching Flutter is caught', () {
      final violations = checkBoundaries(
        packages: {
          'matching_engine': pkg('matching_engine', deps: {'flutter'}),
        },
        rules: rules,
      );
      expect(violations.single, contains('pure-Dart'));
    });

    test('an unlisted package with no rule is itself a violation', () {
      final violations = checkBoundaries(
        packages: {'mystery_pkg': pkg('mystery_pkg')},
        rules: rules,
      );
      expect(violations.single, contains('no boundary rule'));
    });

    test('undeclared-but-imported internal packages are caught too', () {
      // pubspec looks innocent; a lib/ file sneaks the import in.
      final violations = checkBoundaries(
        packages: {
          'provider_api': pkg(
            'provider_api',
            deps: {'core_domain'},
            imports: {'core_domain', 'matching_engine'},
          ),
          'core_domain': pkg('core_domain'),
          'matching_engine': pkg('matching_engine'),
        },
        rules: rules,
      );
      expect(violations.single, contains('matching_engine'));
    });
  });

  test('glob rules match: provider_* and *_app', () {
    final violations = checkBoundaries(
      packages: {
        'provider_deezer': pkg('provider_deezer', deps: {'core_domain'}),
        'core_domain': pkg('core_domain'),
        'other_app': pkg(
          'other_app',
          deps: {'core_domain', 'provider_deezer', 'flutter'},
        ),
      },
      rules: rules,
    );
    expect(violations, isEmpty);
  });
}
