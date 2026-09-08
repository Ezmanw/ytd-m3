import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/platform_support.dart';
import '../state/settings_controller.dart';
import '../widgets/color_seed_picker.dart';
import '../widgets/legal_warning_dialog.dart';
import '../widgets/server_dialog.dart';
import 'servers_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _SectionCard(
            title: 'Appearance',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Theme mode'),
                trailing: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode)),
                    ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto)),
                    ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode)),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (selection) =>
                      context.read<SettingsController>().setThemeMode(selection.first),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Theme color'),
              const SizedBox(height: 12),
              ColorSeedPicker(
                selected: settings.seedColor,
                onSelected: (color) => context.read<SettingsController>().setSeedColor(color),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Servers',
            children: [
              Text(
                settings.isDirectMode
                    ? (supportsDirectMode
                        ? 'Currently running Direct — this computer, no server needed.'
                        : 'No server added yet.')
                    : 'Currently connected to "${settings.activeServer!.name}".',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                supportsDirectMode
                    ? 'A server is entirely optional — this app works on its own with '
                        'no setup. Only add one if you want to download through another '
                        'machine, like your own remote box or a friend\'s server.'
                    : 'This build only downloads through a remote server — add your '
                        'own box, or one a friend is hosting for you.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      final profile = await ServerDialog.show(context);
                      if (profile != null && context.mounted) {
                        await context.read<SettingsController>().upsertServer(profile);
                        if (context.mounted) {
                          await context.read<SettingsController>().setActiveServer(profile.id);
                        }
                      }
                    },
                    icon: const Icon(Icons.dns),
                    label: const Text('Add a remote server'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ServersScreen()),
                    ),
                    icon: const Icon(Icons.list),
                    label: const Text('Manage servers'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Legal',
            titleColor: settings.legalWarningEnabled
                ? null
                : Theme.of(context).colorScheme.error,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Show legal / copyright warning'),
                subtitle: const Text(
                  'Displayed on the Home screen as a reminder to only download '
                  'content you have the rights to.',
                ),
                value: settings.legalWarningEnabled,
                onChanged: (value) async {
                  if (value) {
                    await context.read<SettingsController>().setLegalWarningEnabled(true);
                    return;
                  }
                  final confirmed = await LegalWarningOptOutDialog.show(context);
                  if (confirmed && context.mounted) {
                    await context.read<SettingsController>().setLegalWarningEnabled(false);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
    this.titleColor,
  });

  final String title;
  final List<Widget> children;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: titleColor),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
