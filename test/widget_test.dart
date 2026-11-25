import 'package:craft_bay_app/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('email and mobile validators accept valid values', () {
    expect(Validators.email('user@example.com'), isNull);
    expect(Validators.email('invalid-email'), isNotNull);
    expect(Validators.mobile('01754658781'), isNull);
    expect(Validators.mobile('12345'), isNotNull);
  });
}
