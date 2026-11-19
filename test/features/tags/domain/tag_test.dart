import 'package:ctrltask/features/tags/domain/tag.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normaliseTagName trims, drops a leading # and lowercases', () {
    expect(normaliseTagName('  #Work '), 'work');
    expect(normaliseTagName('# Design'), 'design');
    expect(normaliseTagName('Q4-report'), 'q4-report');
    expect(normaliseTagName('x' * 24), 'x' * 24);
  });

  test('normaliseTagName rejects blank, long or #-containing names', () {
    for (final bad in ['', '  ', '#', '# ', 'x' * 25, 'a#b']) {
      expect(() => normaliseTagName(bad), throwsArgumentError, reason: bad);
    }
  });
}
