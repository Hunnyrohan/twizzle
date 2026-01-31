import 'package:flutter_test/flutter_test.dart';

void main() {
  test('String reversal', () {
    String original = 'hello';
    String reversed = original.split('').reversed.join('');
    expect(reversed, 'olleh');
  });
}
