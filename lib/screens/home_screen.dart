import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/history_screen.dart';
import '../screens/servers_screen.dart';
import '../services/folder_launcher.dart';
import '../services/platform_support.dart';
import '../state/downloads_controller.dart';
import '../state/settings_controller.dart';
import '../widgets/new_download_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final activeServer = settings.activeServer;
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1100 ? 3 : (width >= 720 ? 2 : 1);
    final hasUsableTarget = activeServer != null || supportsDirectMode;

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
          Text('Active target', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(activeServer == null ? Icons.computer : Icons.dns),
              title: Text(
                activeServer?.name ??
                    (supportsDirectMode ? 'Direct (this computer)' : 'No server added'),
              ),
              subtitle: Text(
                activeServer != null
                    ? 'Remote · ${activeServer.baseUrl}'
                    : supportsDirectMode
                        ? 'No server needed — this is the default.'
                        : 'Add a remote server to start downloading on this device.',
              ),
              trailing: !hasUsableTarget
                  ? FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ServersScreen()),
                      ),
                      child: const Text('Add server'),
                    )
                  : null,
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
            children: [
              _QuickActionCard(
                icon: Icons.add_link,
                title: 'New download',
                subtitle: activeServer != null
                    ? 'Send a URL to ${activeServer.name}'
                    : supportsDirectMode
                        ? 'Paste a URL (Direct mode)'
                        : 'Add a server first',
                enabled: hasUsableTarget,
                onTap: () async {
                  final url = await NewDownloadDialog.show(context);
                  if (url == null || !context.mounted) return;
                  final downloads = context.read<DownloadsController>();
                  final task = await downloads.submit(url, activeServer);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(task.detail ?? 'Queued: ${task.url}')),
                  );
                },
              ),
              _QuickActionCard(
                icon: Icons.folder_open,
                title: 'Downloads folder',
                subtitle: supportsDirectMode
                    ? 'Open this computer\'s downloads folder'
                    : 'Not available on this platform',
                enabled: supportsDirectMode,
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await FolderLauncher.openDownloadsFolder();
                  } catch (error) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Could not open the folder: $error')),
                    );
                  }
                },
              ),
              _QuickActionCard(
                icon: Icons.history,
                title: 'History',
                subtitle: 'Review past downloads and their status',
                enabled: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                ),
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
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outline;

    return Card(
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: enabled ? null : Theme.of(context).colorScheme.outline,
                          ),
                    ),
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
