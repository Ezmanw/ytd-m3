import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/server_profile.dart';

/// Central app state: theme, saved servers, and the legal-warning
/// preference. Backed by [SharedPreferences] so choices survive restarts.
class SettingsController extends ChangeNotifier {
  SettingsController._(this._prefs);

  static const _keySeedColor = 'seed_color';
  static const _keyThemeMode = 'theme_mode';
  static const _keyLegalWarningEnabled = 'legal_warning_enabled';
  static const _keyServers = 'servers';
  static const _keyActiveServerId = 'active_server_id';

  final SharedPreferences _prefs;

  static Future<SettingsController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final controller = SettingsController._(prefs);
    controller._restore();
    return controller;
  }

  Color _seedColor = Colors.deepPurple;
  ThemeMode _themeMode = ThemeMode.system;
  bool _legalWarningEnabled = true;
  List<ServerProfile> _servers = [];
  String? _activeServerId;

  Color get seedColor => _seedColor;
  ThemeMode get themeMode => _themeMode;
  bool get legalWarningEnabled => _legalWarningEnabled;
  List<ServerProfile> get servers => List.unmodifiable(_servers);
  String? get activeServerId => _activeServerId;

  ServerProfile? get activeServer {
    if (_activeServerId == null) return null;
    for (final server in _servers) {
      if (server.id == _activeServerId) return server;
    }
    return null;
  }

  void _restore() {
    final storedColor = _prefs.getInt(_keySeedColor);
    if (storedColor != null) {
      _seedColor = Color(storedColor);
    }

    final storedMode = _prefs.getString(_keyThemeMode);
    _themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == storedMode,
      orElse: () => ThemeMode.system,
    );

    _legalWarningEnabled = _prefs.getBool(_keyLegalWarningEnabled) ?? true;

    final storedServers = _prefs.getString(_keyServers);
    if (storedServers != null) {
      final decoded = jsonDecode(storedServers) as List<dynamic>;
      _servers = decoded
          .map((e) => ServerProfile.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    _activeServerId = _prefs.getString(_keyActiveServerId);
  }

  Future<void> setSeedColor(Color color) async {
    _seedColor = color;
    notifyListeners();
    await _prefs.setInt(_keySeedColor, color.toARGB32());
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _prefs.setString(_keyThemeMode, mode.name);
  }

  /// Only ever called after the caller has shown an explicit, hard-to-miss
  /// confirmation — see [LegalWarningOptOutDialog].
  Future<void> setLegalWarningEnabled(bool enabled) async {
    _legalWarningEnabled = enabled;
    notifyListeners();
    await _prefs.setBool(_keyLegalWarningEnabled, enabled);
  }

  Future<void> upsertServer(ServerProfile server) async {
    final index = _servers.indexWhere((s) => s.id == server.id);
    if (index == -1) {
      _servers = [..._servers, server];
    } else {
      _servers = [..._servers]..[index] = server;
    }
    _activeServerId ??= server.id;
    notifyListeners();
    await _persistServers();
  }

  Future<void> removeServer(String id) async {
    _servers = _servers.where((s) => s.id != id).toList();
    if (_activeServerId == id) {
      _activeServerId = _servers.isEmpty ? null : _servers.first.id;
      await _prefs.setString(_keyActiveServerId, _activeServerId ?? '');
    }
    notifyListeners();
    await _persistServers();
  }

  Future<void> setActiveServer(String id) async {
    _activeServerId = id;
    notifyListeners();
    await _prefs.setString(_keyActiveServerId, id);
  }

  Future<void> _persistServers() async {
    final encoded = jsonEncode(_servers.map((s) => s.toJson()).toList());
    await _prefs.setString(_keyServers, encoded);
  }
}
