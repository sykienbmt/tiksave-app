import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiksave_app/main.dart';

void main() {
  testWidgets('TikSaveApp renders HomeScreen title and controls', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const TikSaveApp());
    await tester.pump();

    expect(find.text('TikSave Original'), findsOneWidget);
    expect(find.text('Dán & Phân Tích'), findsOneWidget);
    expect(find.text('Tải Gốc Ngay'), findsOneWidget);
  });
}
