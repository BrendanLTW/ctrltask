import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Colours outside `core/theme/` that are deliberate, with how many times
/// each file may use them and why. Anything else must come from the theme
/// tokens (CLAUDE.md UI).
const _allowed = {
  // The toggle's thumb is white when off in both themes (DESIGN §7).
  'lib/core/widgets/app_toggle.dart': 1,
};

final _literal = RegExp(
  r'\bColor\(0x|\bColor\.from(RGBO|ARGB)|\bColors\.(?!transparent\b)\w+',
);

void main() {
  test('widgets take colours from the theme', () {
    final found = <String, int>{};
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (f) =>
              f.path.endsWith('.dart') &&
              !f.path.startsWith('lib/core/theme/') &&
              !f.path.endsWith('.g.dart') &&
              !f.path.endsWith('.freezed.dart') &&
              !f.path.startsWith('lib/l10n/app_localizations'),
        );
    for (final file in files) {
      final count = _literal.allMatches(file.readAsStringSync()).length;
      if (count > 0) found[file.path] = count;
    }
    expect(found, _allowed);
  });
}
