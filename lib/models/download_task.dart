import 'package:flutter/foundation.dart';

enum DownloadStatus {
  queued,
  sentToServer,
  failed,
  unsupported,
}

@immutable
class DownloadTask {
  const DownloadTask({
    required this.id,
    required this.url,
    required this.addedAt,
    required this.status,
    this.targetLabel = 'Direct (this computer)',
    this.detail,
  });

  final String id;
  final String url;
  final DateTime addedAt;
  final DownloadStatus status;
  final String targetLabel;
  final String? detail;

  DownloadTask copyWith({DownloadStatus? status, String? detail}) => DownloadTask(
        id: id,
        url: url,
        addedAt: addedAt,
        status: status ?? this.status,
        targetLabel: targetLabel,
        detail: detail ?? this.detail,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'addedAt': addedAt.toIso8601String(),
        'status': status.name,
        'targetLabel': targetLabel,
        'detail': detail,
      };

  factory DownloadTask.fromJson(Map<String, dynamic> json) => DownloadTask(
        id: json['id'] as String,
        url: json['url'] as String,
        addedAt: DateTime.parse(json['addedAt'] as String),
        status: DownloadStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => DownloadStatus.failed,
        ),
        targetLabel: json['targetLabel'] as String? ?? 'Direct (this computer)',
        detail: json['detail'] as String?,
      );
}
