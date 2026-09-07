import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'state/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsController = await SettingsController.load();

  runApp(
    ChangeNotifierProvider.value(
      value: settingsController,
      child: const YtdM3App(),
    ),
  );
}
