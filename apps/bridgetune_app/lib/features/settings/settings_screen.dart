import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/themes.dart';
import '../../state/services.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  RadioGroup<BridgetuneTheme>(
                    groupValue: theme,
                    onChanged: (v) =>
                        ref.read(themeProvider.notifier).state = v!,
                    child: Column(
                      children: [
                        for (final option in BridgetuneTheme.values)
                          RadioListTile<BridgetuneTheme>(
                            value: option,
                            title: Text(option.label),
                            contentPadding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: ListTile(
              leading: Icon(Icons.science_outlined),
              title: Text('Demo mode'),
              subtitle: Text(
                'Running the full pipeline against built-in fake services. '
                'Connect real Spotify and YouTube Music accounts by '
                'configuring OAuth client IDs (see docs/06).',
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: ListTile(
              leading: Icon(Icons.tune),
              title: Text('Matching threshold'),
              subtitle: Text(
                'Balanced — songs at 85%+ confidence transfer automatically; '
                'everything else waits for your review.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
