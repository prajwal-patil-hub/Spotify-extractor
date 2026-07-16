import 'dart:io';

import 'package:repo_tools/repo_tools.dart';

/// Enforces boundaries.yaml across the workspace. Run from the repo root
/// (melos and CI both do): `dart run repo_tools:check_boundaries`.
void main() {
  var root = Directory.current;
  // Walk up until we find the workspace root (has boundaries.yaml).
  while (!File('${root.path}/boundaries.yaml').existsSync()) {
    final parent = root.parent;
    if (parent.path == root.path) {
      stderr.writeln(
        'error: boundaries.yaml not found above ${Directory.current.path}',
      );
      exit(2);
    }
    root = parent;
  }

  final violations = checkBoundaries(
    packages: scanWorkspace(root),
    rules: loadRules(root),
  );

  if (violations.isEmpty) {
    stdout.writeln('architecture boundaries: OK');
    return;
  }
  stderr.writeln('architecture boundary violations:');
  for (final violation in violations) {
    stderr.writeln('  ✗ $violation');
  }
  exit(1);
}
