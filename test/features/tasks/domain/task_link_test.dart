import 'package:ctrltask/features/tasks/domain/task_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('displayUrl drops the scheme, www and a trailing slash', () {
    expect(
      displayUrl('https://www.figma.com/file/website-v2/'),
      'figma.com/file/website-v2',
    );
    expect(displayUrl('HTTP://example.com'), 'example.com');
    expect(displayUrl('docs.google.com/d/1'), 'docs.google.com/d/1');
  });

  test('isWebLink accepts http and https only', () {
    expect(isWebLink('https://figma.com'), isTrue);
    expect(isWebLink('ftp://figma.com'), isFalse);
  });
}
