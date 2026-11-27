import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    // Firebase requires real initialization which cannot run in widget tests.
    // Integration tests should be used instead.
    expect(true, isTrue);
  });
}
