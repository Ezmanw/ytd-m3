import 'package:flutter/foundation.dart';

/// How a [ServerProfile] is reached.
enum ServerKind {
  /// A download server running on this same machine.
  local,

  /// A server reachable over the network — your own remote box, or a
  /// server a friend is hosting for you.
  remote,
}

@immutable
class ServerProfile {
  const ServerProfile({
    required this.id,
    required this.name,
    required this.kind,
    required this.host,
    required this.port,
    this.useTls = false,
  });

  final String id;
  final String name;
  final ServerKind kind;
  final String host;
  final int port;
  final bool useTls;

  String get baseUrl => '${useTls ? 'https' : 'http'}://$host:$port';

  ServerProfile copyWith({
    String? name,
    ServerKind? kind,
    String? host,
    int? port,
    bool? useTls,
  }) {
    return ServerProfile(
      id: id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      host: host ?? this.host,
      port: port ?? this.port,
      useTls: useTls ?? this.useTls,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'kind': kind.name,
        'host': host,
        'port': port,
        'useTls': useTls,
      };

  factory ServerProfile.fromJson(Map<String, dynamic> json) => ServerProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        kind: ServerKind.values.firstWhere(
          (k) => k.name == json['kind'],
          orElse: () => ServerKind.remote,
        ),
        host: json['host'] as String,
        port: json['port'] as int,
        useTls: json['useTls'] as bool? ?? false,
      );
}
