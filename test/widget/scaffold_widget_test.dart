import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Scaffold has app bar', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(appBar: AppBar(title: Text('Title'))),
      ),
    );
    expect(find.text('Title'), findsOneWidget);
  });
}
