import 'package:flutter/foundation.dart';

/// A remote download server — your own box on the network, or one a friend
/// is hosting for you. Using a server is optional: this app works directly
/// on the local computer with no server configured at all (see
/// [SettingsController.activeServer] returning null for "Direct" mode).
@immutable
class ServerProfile {
  const ServerProfile({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    this.useTls = false,
  });

  final String id;
  final String name;
  final String host;
  final int port;
  final bool useTls;

  String get baseUrl => '${useTls ? 'https' : 'http'}://$host:$port';

  ServerProfile copyWith({
    String? name,
    String? host,
    int? port,
    bool? useTls,
  }) {
    return ServerProfile(
      id: id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      useTls: useTls ?? this.useTls,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'host': host,
        'port': port,
        'useTls': useTls,
      };

  factory ServerProfile.fromJson(Map<String, dynamic> json) => ServerProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        host: json['host'] as String,
        port: json['port'] as int,
        useTls: json['useTls'] as bool? ?? false,
      );
}
