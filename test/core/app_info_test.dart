import 'dart:io';

import 'package:ctrltask/core/app_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('matches the pubspec version', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version:\s*([^+\s]+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);
    expect(appVersion, version);
  });

  test('the short form is major.minor', () {
    expect(appVersionShort, '1.0');
  });
}
