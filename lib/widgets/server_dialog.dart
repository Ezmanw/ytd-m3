import 'package:flutter/material.dart';

import '../models/server_profile.dart';

/// Add or edit a remote [ServerProfile] — your own box on the network, or
/// one a friend is hosting for you. This computer itself never needs one of
/// these; Direct mode covers that with no setup.
class ServerDialog extends StatefulWidget {
  const ServerDialog({super.key, this.existing});

  final ServerProfile? existing;

  static Future<ServerProfile?> show(BuildContext context, {ServerProfile? existing}) {
    return showDialog<ServerProfile>(
      context: context,
      builder: (context) => ServerDialog(existing: existing),
    );
  }

  @override
  State<ServerDialog> createState() => _ServerDialogState();
}

class _ServerDialogState extends State<ServerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  late bool _useTls;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _hostController = TextEditingController(text: existing?.host ?? '');
    _portController = TextEditingController(text: (existing?.port ?? 8266).toString());
    _useTls = existing?.useTls ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit server' : 'Add remote server'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. Home NAS, Alex\'s server',
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Give this server a name' : null,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _hostController,
                      decoration: const InputDecoration(
                        labelText: 'Host / address',
                        border: OutlineInputBorder(),
                        hintText: 'e.g. 192.168.1.42 or my-server.duckdns.org',
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _portController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Port',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final port = int.tryParse(value ?? '');
                        if (port == null || port <= 0 || port > 65535) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Use HTTPS'),
                value: _useTls,
                onChanged: (value) => setState(() => _useTls = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final profile = ServerProfile(
              id: widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
              name: _nameController.text.trim(),
              host: _hostController.text.trim(),
              port: int.parse(_portController.text.trim()),
              useTls: _useTls,
            );
            Navigator.of(context).pop(profile);
          },
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
