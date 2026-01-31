import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Button displays text', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ElevatedButton(onPressed: () {}, child: Text('Press')),
      ),
    );
    expect(find.text('Press'), findsOneWidget);
  });
}
