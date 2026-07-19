import 'package:flutter/material.dart';

/// The three Bridgetune themes (docs/10 §3.1). Components consume semantic
/// [ColorScheme] roles only — never raw hex — so every screen renders
/// correctly in all three.
enum BridgetuneTheme { dark, light, oldMoney }

extension BridgetuneThemeData on BridgetuneTheme {
  String get label => switch (this) {
    BridgetuneTheme.dark => 'Dark',
    BridgetuneTheme.light => 'Light',
    BridgetuneTheme.oldMoney => 'Old Money',
  };

  ThemeData get themeData => switch (this) {
    BridgetuneTheme.dark => _build(
      brightness: Brightness.dark,
      surface: const Color(0xFF0E1113),
      surfaceRaised: const Color(0xFF16191C),
      ink: const Color(0xFFE8EAED),
      inkMuted: const Color(0xFF9AA0A6),
      accent: const Color(0xFF6FD3A6),
      onAccent: const Color(0xFF06281A),
      outline: const Color(0xFF3A3F44),
      danger: const Color(0xFFE5726B),
    ),
    BridgetuneTheme.light => _build(
      brightness: Brightness.light,
      surface: const Color(0xFFFAFAF8),
      surfaceRaised: const Color(0xFFFFFFFF),
      ink: const Color(0xFF1A1C1E),
      inkMuted: const Color(0xFF5F6368),
      accent: const Color(0xFF1F7A5C),
      onAccent: const Color(0xFFFFFFFF),
      outline: const Color(0xFFE4E2DD),
      danger: const Color(0xFFB3261E),
    ),
    // Luxury through typography and restraint: aged ivory, hunter green,
    // antique-gold hairlines, serif display (docs/10).
    BridgetuneTheme.oldMoney => _build(
      brightness: Brightness.light,
      surface: const Color(0xFFF5F1E8),
      surfaceRaised: const Color(0xFFEDE7D9),
      ink: const Color(0xFF2C2A25),
      inkMuted: const Color(0xFF6B6455),
      accent: const Color(0xFF1F4D3A),
      onAccent: const Color(0xFFF5F1E8),
      outline: const Color(0xFFB49A5E),
      danger: const Color(0xFF8C3A2E),
      serifDisplay: true,
    ),
  };
}

ThemeData _build({
  required Brightness brightness,
  required Color surface,
  required Color surfaceRaised,
  required Color ink,
  required Color inkMuted,
  required Color accent,
  required Color onAccent,
  required Color outline,
  required Color danger,
  bool serifDisplay = false,
}) {
  final scheme = ColorScheme(
    brightness: brightness,
    primary: accent,
    onPrimary: onAccent,
    secondary: outline,
    onSecondary: ink,
    error: danger,
    onError: surface,
    surface: surface,
    onSurface: ink,
    surfaceContainerHighest: surfaceRaised,
    onSurfaceVariant: inkMuted,
    outline: outline,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: surface,
  );
  final display = serifDisplay
      ? const TextStyle(fontFamily: 'serif', letterSpacing: 0.2)
      : const TextStyle();
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium?.merge(display),
      titleLarge: base.textTheme.titleLarge?.merge(display),
    ),
    cardTheme: CardThemeData(
      color: surfaceRaised,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: outline.withValues(alpha: 0.5)),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: DividerThemeData(
      color: outline.withValues(alpha: 0.5),
      thickness: 1,
    ),
  );
}
