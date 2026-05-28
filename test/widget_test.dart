
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dexter/app.dart';

void main() {
  testWidgets('DexterApp loads into LockScreen successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: DexterApp()));
    await tester.pumpAndSettle();

    // Verify that the lock screen setup text is displayed.
    expect(find.text('قم بإعداد كلمة مرور جديدة'), findsWidgets);
  });
}
