import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('logo asset is bundled', () async {
    final data = await rootBundle.load('assets/images/logo.png');
    expect(data.lengthInBytes, greaterThan(0));
  });
}
