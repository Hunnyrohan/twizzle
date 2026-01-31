import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Icon renders', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Icon(Icons.star)));
    expect(find.byIcon(Icons.star), findsOneWidget);
  });
}
