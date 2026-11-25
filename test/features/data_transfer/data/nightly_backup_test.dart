import 'package:ctrltask/features/data_transfer/data/nightly_backup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the nightly backup waits for the next 2 AM', () {
    expect(
      untilNightly(DateTime(2026, 11, 17, 1, 30)),
      const Duration(minutes: 30),
    );
    expect(untilNightly(DateTime(2026, 11, 17, 2)), const Duration(days: 1));
    expect(untilNightly(DateTime(2026, 11, 17, 21)), const Duration(hours: 5));
  });
}
