/// Filesystem discovery: reads the root pubspec's workspace list, each
/// package's pubspec, and each package's lib/ imports, producing the inputs
/// for [checkBoundaries].
library;

import 'dart:io';

import 'package:yaml/yaml.dart';

import 'boundary_checker.dart';

final _importPattern = RegExp(
  '''^\\s*(?:import|export)\\s+['"]package:([A-Za-z0-9_]+)/''',
);

/// Loads boundaries.yaml from [rootDir].
BoundaryRules loadRules(Directory rootDir) {
  final file = File('${rootDir.path}/boundaries.yaml');
  final doc = loadYaml(file.readAsStringSync()) as YamlMap;
  final allowNode = doc['allow'] as YamlMap? ?? YamlMap();
  final pureNode = doc['pure_dart'] as YamlList? ?? YamlList();
  return BoundaryRules(
    allow: {
      for (final entry in allowNode.entries)
        entry.key as String: [
          for (final dep in entry.value as YamlList) dep as String,
        ],
    },
    pureDart: {for (final name in pureNode) name as String},
  );
}

/// Discovers workspace packages from the root pubspec's `workspace:` list.
Map<String, PackageInfo> scanWorkspace(Directory rootDir) {
  final rootPubspec =
      loadYaml(File('${rootDir.path}/pubspec.yaml').readAsStringSync())
          as YamlMap;
  final members = rootPubspec['workspace'] as YamlList? ?? YamlList();

  final packages = <String, PackageInfo>{};
  for (final member in members) {
    final dir = Directory('${rootDir.path}/$member');
    final info = scanPackage(dir);
    packages[info.name] = info;
  }
  return packages;
}

/// Reads one package directory into a [PackageInfo].
PackageInfo scanPackage(Directory packageDir) {
  final pubspec =
      loadYaml(File('${packageDir.path}/pubspec.yaml').readAsStringSync())
          as YamlMap;
  final name = pubspec['name'] as String;
  final deps = pubspec['dependencies'] as YamlMap? ?? YamlMap();

  final imports = <String>{};
  final libDir = Directory('${packageDir.path}/lib');
  if (libDir.existsSync()) {
    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      for (final line in entity.readAsLinesSync()) {
        final match = _importPattern.firstMatch(line);
        if (match != null) imports.add(match.group(1)!);
      }
    }
  }

  return PackageInfo(
    name: name,
    dependencies: {for (final dep in deps.keys) dep as String},
    importedPackages: imports,
  );
}
