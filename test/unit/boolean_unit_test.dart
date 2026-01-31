import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Boolean AND operation', () {
    bool a = true;
    bool b = false;
    expect(a && b, false);
  });
}
