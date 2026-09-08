import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/platform_support.dart';
import '../state/settings_controller.dart';
import '../widgets/server_dialog.dart';

class ServersScreen extends StatelessWidget {
  const ServersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final servers = settings.servers;

    return Scaffold(
      appBar: AppBar(title: const Text('Servers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final profile = await ServerDialog.show(context);
          if (profile != null && context.mounted) {
            await context.read<SettingsController>().upsertServer(profile);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add remote server'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (supportsDirectMode) ...[
            Card(
              color:
                  settings.isDirectMode ? Theme.of(context).colorScheme.secondaryContainer : null,
              child: ListTile(
                leading: const Icon(Icons.computer),
                title: const Text('Direct (this computer)'),
                subtitle: const Text('The default — works with no setup, no server required.'),
                trailing: settings.isDirectMode
                    ? const Chip(label: Text('Active'))
                    : TextButton(
                        onPressed: () => context.read<SettingsController>().useDirectMode(),
                        child: const Text('Use'),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            'Remote servers (optional)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Only add one of these if you want to download through another '
            'machine — your own remote box, or a server a friend is hosting '
            'for you. Nothing below is required to use this app.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          if (servers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No remote servers added yet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ),
            )
          else
            ...servers.map((server) {
              final isActive = server.id == settings.activeServerId;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  color: isActive ? Theme.of(context).colorScheme.secondaryContainer : null,
                  child: ListTile(
                    leading: const Icon(Icons.dns),
                    title: Text(server.name),
                    subtitle: Text(server.baseUrl),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        if (!isActive)
                          TextButton(
                            onPressed: () =>
                                context.read<SettingsController>().setActiveServer(server.id),
                            child: const Text('Use'),
                          )
                        else
                          const Chip(label: Text('Active')),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Edit',
                          onPressed: () async {
                            final updated = await ServerDialog.show(context, existing: server);
                            if (updated != null && context.mounted) {
                              await context.read<SettingsController>().upsertServer(updated);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Remove',
                          onPressed: () =>
                              context.read<SettingsController>().removeServer(server.id),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
