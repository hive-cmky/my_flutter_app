import 'package:flutter_test/flutter_test.dart';
import 'package:edistrict_odisha/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the login screen is displayed.
    expect(find.text('ServicePlus Portal'), findsOneWidget);
  });
}
