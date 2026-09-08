import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/download_task.dart';
import '../state/downloads_controller.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final downloads = context.watch<DownloadsController>();
    final history = downloads.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear history',
              onPressed: () => context.read<DownloadsController>().clearHistory(),
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Text(
                'No downloads yet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: history.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final task = history[index];
                return Card(
                  child: ListTile(
                    leading: _StatusIcon(status: task.status),
                    title: Text(task.url, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      '${task.targetLabel} · ${_formatTimestamp(task.addedAt)}'
                      '${task.detail != null ? '\n${task.detail}' : ''}',
                    ),
                    isThreeLine: task.detail != null,
                    trailing: _StatusChip(status: task.status),
                  ),
                );
              },
            ),
    );
  }

  static String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final DownloadStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (status) {
      DownloadStatus.queued => Icon(Icons.schedule, color: colorScheme.primary),
      DownloadStatus.sentToServer => Icon(Icons.cloud_done_outlined, color: colorScheme.primary),
      DownloadStatus.failed => Icon(Icons.error_outline, color: colorScheme.error),
      DownloadStatus.unsupported => Icon(Icons.info_outline, color: colorScheme.outline),
    };
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final DownloadStatus status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      DownloadStatus.queued => 'Queued',
      DownloadStatus.sentToServer => 'Sent to server',
      DownloadStatus.failed => 'Failed',
      DownloadStatus.unsupported => 'Not supported',
    };
    return Chip(label: Text(label));
  }
}
