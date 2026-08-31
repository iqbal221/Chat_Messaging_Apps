import 'package:ChatVani/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChatVani app starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ChatVani());

    await tester.pumpAndSettle();

    expect(find.byType(ChatVani), findsOneWidget);
  });
}
