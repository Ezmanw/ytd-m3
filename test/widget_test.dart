import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ytd_m3/app.dart';
import 'package:ytd_m3/state/downloads_controller.dart';
import 'package:ytd_m3/state/settings_controller.dart';

void main() {
  testWidgets('App launches and shows the home screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final settingsController = await SettingsController.load();
    final downloadsController = await DownloadsController.load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settingsController),
          ChangeNotifierProvider.value(value: downloadsController),
        ],
        child: const YtdM3App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('YTD M3'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Servers'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });
}
