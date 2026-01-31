import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Container has child', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Container(child: Text('Inside'))),
    );
    expect(find.text('Inside'), findsOneWidget);
  });
}
