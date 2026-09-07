import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A curated set of seed colors offered by the theme customizer. All are
/// standard Material palette colors — no custom colors are invented.
const List<Color> kSeedColorOptions = [
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.lime,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.red,
  Colors.pink,
  Colors.brown,
  Colors.blueGrey,
];

/// Builds the app's [ThemeData] for a given seed color and brightness,
/// using only Material 3 [ColorScheme] tokens and the Google Sans font
/// family applied across the whole [TextTheme].
ThemeData buildAppTheme({required Color seedColor, required Brightness brightness}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
  );

  // "Google Sans" itself is a proprietary Google product font and is not
  // published on Google Fonts, so google_fonts has no matching family to
  // fetch. Roboto is Google's own open-source Material typeface and the
  // closest faithful, properly-licensed stand-in — swap this call if a
  // licensed Google Sans font file ever becomes available to the project.
  final googleSansTextTheme = GoogleFonts.robotoTextTheme(base.textTheme);

  return base.copyWith(
    textTheme: googleSansTextTheme,
    primaryTextTheme: GoogleFonts.robotoTextTheme(base.primaryTextTheme),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: colorScheme.surface,
      selectedIconTheme: IconThemeData(color: colorScheme.primary),
      selectedLabelTextStyle: googleSansTextTheme.labelLarge?.copyWith(
        color: colorScheme.primary,
      ),
      unselectedLabelTextStyle: googleSansTextTheme.labelLarge,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      titleTextStyle: googleSansTextTheme.titleLarge,
      scrolledUnderElevation: 1,
    ),
    cardTheme: const CardThemeData(
      clipBehavior: Clip.antiAlias,
    ),
  );
}
