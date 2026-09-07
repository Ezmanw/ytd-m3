import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/server_profile.dart';
import '../state/settings_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final activeServer = settings.activeServer;
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1100 ? 3 : (width >= 720 ? 2 : 1);

    return Scaffold(
      appBar: AppBar(title: const Text('YTD M3')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (settings.legalWarningEnabled) ...[
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Theme.of(context).colorScheme.onErrorContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Only download content you have the rights to, that is '
                        'licensed for download, or that is in the public domain. '
                        'You can turn this notice off in Settings.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text('Active server', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                activeServer == null
                    ? Icons.link_off
                    : (activeServer.kind == ServerKind.local ? Icons.computer : Icons.dns),
              ),
              title: Text(activeServer?.name ?? 'No server connected'),
              subtitle: Text(
                activeServer == null
                    ? 'Add a local or remote server from the Servers tab to start downloading.'
                    : '${activeServer.kind == ServerKind.local ? 'This computer' : 'Remote'} · ${activeServer.baseUrl}',
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Quick actions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: columns,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.1,
            children: const [
              _QuickActionCard(
                icon: Icons.add_link,
                title: 'New download',
                subtitle: 'Paste a URL to send to your active server',
              ),
              _QuickActionCard(
                icon: Icons.folder_open,
                title: 'Downloads folder',
                subtitle: 'Open the destination folder on the server',
              ),
              _QuickActionCard(
                icon: Icons.history,
                title: 'History',
                subtitle: 'Review past downloads and their status',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
