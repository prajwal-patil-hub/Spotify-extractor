import 'package:bridgetune_app/app.dart';
import 'package:bridgetune_app/state/demo_seed.dart';
import 'package:bridgetune_app/state/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppServices> _seededServices() async {
  final services = AppServices.demo();
  await seedDemoLibrary(services);
  return services;
}

Widget _app(AppServices services) => ProviderScope(
  overrides: [servicesProvider.overrideWithValue(services)],
  child: const BridgetuneApp(),
);

void main() {
  testWidgets('full demo flow: wizard → transfer over the real engines → '
      'dashboard stats → review queue → skip clears the job', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final services = await _seededServices();
    await tester.pumpWidget(_app(services));
    await tester.pumpAndSettle();

    // Empty state first.
    expect(find.text('Move your music between platforms'), findsOneWidget);

    // Wizard: capability note must be there — the demo destination cannot
    // accept artwork, and the UI renders from the capability intersection.
    await tester.tap(find.text('New transfer'));
    await tester.pumpAndSettle();
    expect(find.text('Road Trip'), findsOneWidget);
    expect(find.textContaining("Artwork won't transfer"), findsOneWidget);

    // "Focus Flow" contains the tracks that only exist as live versions or
    // not at all on the destination → produces a review queue.
    await tester.tap(find.text('Focus Flow'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start transfer'));
    await tester.pumpAndSettle();

    // Back on the dashboard with a needs-review job and live stats.
    expect(find.textContaining('need your review'), findsOneWidget);
    expect(find.text('Needs review'), findsOneWidget);
    expect(find.text('awaiting review'), findsOneWidget);

    // The destination really received a playlist (real engine, fake wire).
    final ytm = services.registry.byId(services.accounts.keys.last);
    expect(ytm, isNotNull);

    // Review tab: items exist; skipping all of them completes the job.
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    expect(find.text('Skip song'), findsWidgets);
    while (tester.any(find.text('Skip song'))) {
      await tester.tap(find.text('Skip song').first);
      await tester.pumpAndSettle();
    }
    expect(find.text('Nothing needs your review.'), findsOneWidget);

    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsOneWidget);
  });

  testWidgets('clean transfer completes without review', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final services = await _seededServices();
    await tester.pumpWidget(_app(services));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New transfer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Road Trip')); // all 15 tracks match cleanly
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start transfer'));
    await tester.pumpAndSettle();

    expect(find.textContaining('transferred: 15 of 15'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
  });

  testWidgets('theme switching: Old Money repaints the scaffold', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final services = await _seededServices();
    await tester.pumpWidget(_app(services));
    await tester.pumpAndSettle();

    ThemeData theme() => Theme.of(tester.element(find.byType(Scaffold).first));
    expect(theme().brightness, Brightness.dark);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Old Money'));
    await tester.pumpAndSettle();

    expect(theme().brightness, Brightness.light);
    expect(
      theme().scaffoldBackgroundColor,
      const Color(0xFFF5F1E8),
      reason: 'aged ivory — the Old Money surface token',
    );
  });
}
