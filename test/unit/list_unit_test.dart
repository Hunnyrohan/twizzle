import 'package:flutter_test/flutter_test.dart';

void main() {
  test('List contains element', () {
    List<int> numbers = [1, 2, 3];
    expect(numbers.contains(2), true);
  });
}
