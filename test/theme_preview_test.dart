import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _loadFonts() async {
  final loader = FontLoader('Nunito');
  loader.addFont(rootBundle.load('assets/fonts/Nunito-Regular.ttf'));
  loader.addFont(rootBundle.load('assets/fonts/Nunito-Bold.ttf'));
  await loader.load();
}

Future<ThemeData> _readTheme(Brightness brightness) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWith((ref) => prefs)],
  );
  final theme = createAppTheme(brightness, container.read(appSettingsProvider));
  container.dispose();
  return theme;
}

class _Preview extends StatelessWidget {
  const _Preview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solian'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.edit),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: SolSpace.page,
          vertical: SolSpace.xl,
        ),
        children: [
          Text('Good evening', style: theme.textTheme.headlineSmall),
          const SizedBox(height: SolSpace.xs),
          Text(
            'A quieter place to catch up with the people you follow.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SolSpace.xxl),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(SolSpace.card),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: scheme.primaryContainer,
                        foregroundColor: scheme.onPrimaryContainer,
                        child: const Text('S'),
                      ),
                      const SizedBox(width: SolSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stellar update',
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              '2 minutes ago',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.bookmark_border),
                      ),
                    ],
                  ),
                  const SizedBox(height: SolSpace.lg),
                  Text(
                    'We shipped a warmer, roomier interface for spring. '
                    'Cards breathe, corners are softer, and the whole app '
                    'sits on a sheet of sun-warmed paper.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: SolSpace.lg),
                  Wrap(
                    spacing: SolSpace.sm,
                    runSpacing: SolSpace.sm,
                    children: const [
                      Chip(label: Text('design')),
                      Chip(label: Text('release')),
                      Chip(label: Text('solian')),
                    ],
                  ),
                  const SizedBox(height: SolSpace.lg),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () {},
                          child: const Text('Continue'),
                        ),
                      ),
                      const SizedBox(width: SolSpace.md),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Later'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: SolSpace.xl),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Display name',
              hintText: 'How should we call you?',
            ),
          ),
          const SizedBox(height: SolSpace.xl),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  subtitle: const Text('Mentions, replies and new followers'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Appearance'),
                  subtitle: const Text('Warm paper, dark cocoa or system'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  selected: true,
                  leading: const Icon(Icons.favorite_outline),
                  title: const Text('Wellbeing'),
                  subtitle: const Text('Gentle reminders and quiet hours'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_loadFonts);

  for (final brightness in Brightness.values) {
    testWidgets('theme preview ${brightness.name}', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final theme = await _readTheme(brightness);
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: const _Preview(),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/theme_${brightness.name}.png'),
      );
    });
  }
}
