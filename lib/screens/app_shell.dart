import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'servers_screen.dart';
import 'settings_screen.dart';

/// Top-level layout. Desktop and tablet widths get an M3 [NavigationRail]
/// alongside the page; narrow (phone) widths get a bottom [NavigationBar]
/// instead, per Material's navigation guidance for compact screens.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _icons = [
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.dns_outlined, Icons.dns, 'Servers'),
    (Icons.settings_outlined, Icons.settings, 'Settings'),
  ];

  static const _pages = [
    HomeScreen(),
    ServersScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 600;
    final isWide = width >= 720;

    final page = IndexedStack(index: _index, children: _pages);

    if (isCompact) {
      return Scaffold(
        body: page,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: [
            for (final (icon, selectedIcon, label) in _icons)
              NavigationDestination(icon: Icon(icon), selectedIcon: Icon(selectedIcon), label: label),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: isWide,
            minExtendedWidth: 200,
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Icon(Icons.download_for_offline, size: 32),
            ),
            destinations: [
              for (final (icon, selectedIcon, label) in _icons)
                NavigationRailDestination(
                  icon: Icon(icon),
                  selectedIcon: Icon(selectedIcon),
                  label: Text(label),
                ),
            ],
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: page),
        ],
      ),
    );
  }
}
