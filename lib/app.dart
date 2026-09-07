import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/app_shell.dart';
import 'state/settings_controller.dart';
import 'theme/app_theme.dart';

class YtdM3App extends StatelessWidget {
  const YtdM3App({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return MaterialApp(
      title: 'YTD M3',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: buildAppTheme(seedColor: settings.seedColor, brightness: Brightness.light),
      darkTheme: buildAppTheme(seedColor: settings.seedColor, brightness: Brightness.dark),
      home: const AppShell(),
    );
  }
}
