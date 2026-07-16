/// Pure boundary-checking logic, separated from filesystem discovery so the
/// rules engine is unit-testable against synthetic package graphs — including
/// the mandatory "a deliberate violation fails" test (Phase-0 exit criterion).
library;

/// What the checker needs to know about one workspace package.
class PackageInfo {
  const PackageInfo({
    required this.name,
    required this.dependencies,
    required this.importedPackages,
  });

  final String name;

  /// Names from the `dependencies:` section of the package's pubspec
  /// (including `flutter` when depended on via sdk).
  final Set<String> dependencies;

  /// Package names imported anywhere under lib/ (`package:<name>/...`).
  final Set<String> importedPackages;
}

/// The parsed contents of boundaries.yaml.
class BoundaryRules {
  const BoundaryRules({required this.allow, required this.pureDart});

  /// Package name or glob (`provider_*`) → allowed internal deps
  /// (`['*']` = unrestricted).
  final Map<String, List<String>> allow;

  /// Packages forbidden from touching the Flutter SDK.
  final Set<String> pureDart;
}

bool _globMatches(String pattern, String name) {
  if (!pattern.contains('*')) return pattern == name;
  final regex = RegExp(
    '^${pattern.split('*').map(RegExp.escape).join('.*')}\$',
  );
  return regex.hasMatch(name);
}

/// Finds the allowlist for [name]: exact rule first, then the first glob
/// rule that matches (declaration order). Null when nothing matches.
List<String>? _ruleFor(Map<String, List<String>> allow, String name) {
  final exact = allow[name];
  if (exact != null) return exact;
  for (final entry in allow.entries) {
    if (entry.key.contains('*') && _globMatches(entry.key, name)) {
      return entry.value;
    }
  }
  return null;
}

/// Returns human-readable violations; empty means the architecture holds.
List<String> checkBoundaries({
  required Map<String, PackageInfo> packages,
  required BoundaryRules rules,
}) {
  final violations = <String>[];
  final internalNames = packages.keys.toSet();

  for (final pkg in packages.values) {
    final allowed = _ruleFor(rules.allow, pkg.name);
    if (allowed == null) {
      violations.add(
        '${pkg.name}: no boundary rule in boundaries.yaml — every package '
        'must declare its place in the dependency graph',
      );
      continue;
    }
    final unrestricted = allowed.contains('*');

    if (!unrestricted) {
      final internalDeps = pkg.dependencies.intersection(internalNames)
        ..addAll(pkg.importedPackages.intersection(internalNames));
      for (final dep in internalDeps) {
        final permitted = allowed.any((pattern) => _globMatches(pattern, dep));
        if (!permitted) {
          violations.add(
            '${pkg.name}: depends on internal package "$dep" which its '
            'boundary rule does not allow (allowed: '
            '${allowed.isEmpty ? 'none' : allowed.join(', ')})',
          );
        }
      }
    }

    if (rules.pureDart.contains(pkg.name)) {
      if (pkg.dependencies.contains('flutter') ||
          pkg.importedPackages.contains('flutter')) {
        violations.add(
          '${pkg.name}: is declared pure-Dart but touches the Flutter SDK',
        );
      }
    }
  }

  return violations..sort();
}
