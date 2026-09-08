import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/download_task.dart';
import '../models/server_profile.dart';

/// Tracks download requests the user has queued, and (best-effort) submits
/// them to the active remote server. There is no bundled local download
/// engine yet, so Direct-mode submissions are recorded as unsupported
/// rather than silently doing nothing.
class DownloadsController extends ChangeNotifier {
  DownloadsController._(this._prefs);

  static const _keyHistory = 'download_history';

  final SharedPreferences _prefs;

  static Future<DownloadsController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final controller = DownloadsController._(prefs);
    controller._restore();
    return controller;
  }

  List<DownloadTask> _history = [];

  List<DownloadTask> get history => List.unmodifiable(_history.reversed);

  void _restore() {
    final stored = _prefs.getString(_keyHistory);
    if (stored == null) return;
    final decoded = jsonDecode(stored) as List<dynamic>;
    _history = decoded.map((e) => DownloadTask.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _persist() async {
    final encoded = jsonEncode(_history.map((t) => t.toJson()).toList());
    await _prefs.setString(_keyHistory, encoded);
  }

  /// Queues [url] against [server] (or Direct mode if [server] is null),
  /// returning the resulting task once the initial attempt finishes.
  Future<DownloadTask> submit(String url, ServerProfile? server) async {
    var task = DownloadTask(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      url: url,
      addedAt: DateTime.now(),
      status: DownloadStatus.queued,
      targetLabel: server?.name ?? 'Direct (this computer)',
    );
    _history = [..._history, task];
    notifyListeners();
    await _persist();

    if (server == null) {
      task = task.copyWith(
        status: DownloadStatus.unsupported,
        detail: 'Direct-mode downloading isn\'t implemented yet — this app currently '
            'only hands URLs off to a remote server. Add a server in Settings to '
            'actually download this.',
      );
    } else {
      try {
        final response = await http
            .post(
              Uri.parse('${server.baseUrl}/api/downloads'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'url': url}),
            )
            .timeout(const Duration(seconds: 5));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          task = task.copyWith(status: DownloadStatus.sentToServer);
        } else {
          task = task.copyWith(
            status: DownloadStatus.failed,
            detail: 'Server responded with HTTP ${response.statusCode}.',
          );
        }
      } catch (error) {
        task = task.copyWith(
          status: DownloadStatus.failed,
          detail: 'Could not reach ${server.baseUrl}: $error',
        );
      }
    }

    _history = [
      for (final existing in _history)
        if (existing.id == task.id) task else existing,
    ];
    notifyListeners();
    await _persist();
    return task;
  }

  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    await _persist();
  }
}
