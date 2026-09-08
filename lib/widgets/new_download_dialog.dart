import 'package:flutter/material.dart';

/// Collects a URL to queue for download. Returns the entered URL, or null
/// if the user cancelled.
class NewDownloadDialog extends StatefulWidget {
  const NewDownloadDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => const NewDownloadDialog(),
    );
  }

  @override
  State<NewDownloadDialog> createState() => _NewDownloadDialogState();
}

class _NewDownloadDialogState extends State<NewDownloadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New download'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 420,
          child: TextFormField(
            controller: _urlController,
            autofocus: true,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'URL',
              border: OutlineInputBorder(),
              hintText: 'https://…',
            ),
            validator: (value) {
              final uri = Uri.tryParse(value?.trim() ?? '');
              if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                return 'Enter a valid URL';
              }
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Queue'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_urlController.text.trim());
  }
}
