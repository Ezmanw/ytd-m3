import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/server_profile.dart';
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
        label: const Text('Add server'),
      ),
      body: servers.isEmpty
          ? _EmptyState(onAdd: () async {
              final profile = await ServerDialog.show(context);
              if (profile != null && context.mounted) {
                await context.read<SettingsController>().upsertServer(profile);
              }
            })
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: servers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final server = servers[index];
                final isActive = server.id == settings.activeServerId;

                return Card(
                  color: isActive ? Theme.of(context).colorScheme.secondaryContainer : null,
                  child: ListTile(
                    leading: Icon(
                      server.kind == ServerKind.local ? Icons.computer : Icons.dns,
                    ),
                    title: Text(server.name),
                    subtitle: Text(
                      '${server.kind == ServerKind.local ? 'This computer' : 'Remote server'} · ${server.baseUrl}',
                    ),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        if (!isActive)
                          TextButton(
                            onPressed: () =>
                                context.read<SettingsController>().setActiveServer(server.id),
                            child: const Text('Connect'),
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
                );
              },
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.dns_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text('No servers yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Add this computer as a server, or connect to a remote server —\n'
            'your own, or one a friend is hosting for you.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add a server'),
          ),
        ],
      ),
    );
  }
}
