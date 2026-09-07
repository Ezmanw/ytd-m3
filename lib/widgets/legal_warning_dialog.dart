import 'package:flutter/material.dart';

/// Shown before a user is allowed to disable the copyright/legal warning.
/// Requires them to type a confirmation phrase — a plain toggle is too easy
/// to flip by accident for something with real legal consequences.
class LegalWarningOptOutDialog extends StatefulWidget {
  const LegalWarningOptOutDialog({super.key});

  static const confirmationPhrase = 'I ACCEPT THE RISK';

  /// Returns true if the user confirmed they want to disable the warning.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LegalWarningOptOutDialog(),
    );
    return result ?? false;
  }

  @override
  State<LegalWarningOptOutDialog> createState() => _LegalWarningOptOutDialogState();
}

class _LegalWarningOptOutDialogState extends State<LegalWarningOptOutDialog> {
  final _controller = TextEditingController();
  bool _matches = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      icon: Icon(Icons.gpp_maybe, color: colorScheme.error, size: 40),
      iconColor: colorScheme.error,
      title: const Text('Turn off the legal warning?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Downloading copyrighted material without permission from the '
              'rights holder is illegal in many countries and can carry '
              'serious civil or criminal penalties. This app is provided for '
              'downloading content you own the rights to, that is licensed '
              'for download, or that is otherwise in the public domain.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'You will not be shown this warning again, and you take '
                'full responsibility for how you use this software.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Type "${LegalWarningOptOutDialog.confirmationPhrase}" to confirm:',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  _matches = value.trim() == LegalWarningOptOutDialog.confirmationPhrase;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'I ACCEPT THE RISK',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          onPressed: _matches ? () => Navigator.of(context).pop(true) : null,
          child: const Text('Disable warning'),
        ),
      ],
    );
  }
}
