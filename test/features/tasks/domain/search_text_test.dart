import 'package:ctrltask/features/tasks/domain/search_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('matchRanges finds every match, ignoring case', () {
    expect(matchRanges('Invoice the invoice', 'INVOICE'), [
      (start: 0, end: 7),
      (start: 12, end: 19),
    ]);
    expect(matchRanges('anything', '  '), isEmpty);
  });

  test('snippet cuts around the first match', () {
    const note = 'Use the invoice template in Drive for every client';
    expect(snippet(note, 'invoice', radius: 4), '…the invoice tem…');
    expect(snippet('invoice', 'invoice'), 'invoice');
    expect(snippet(note, 'nothing'), isNull);
  });

  group('didYouMean', () {
    const words = [
      'Send invoice to Lumen Studio',
      'Chase invoice #0418',
      'Invite the team',
      'Freelance',
    ];

    test('suggests the closest word within two edits', () {
      expect(didYouMean('invoce', words), 'invoice');
      expect(didYouMean('FREELANSE', words), 'freelance');
    });

    test('a tie goes to the more common word', () {
      // "invite" and "invoice" are both two edits from "invice".
      expect(didYouMean('invice', words), 'invoice');
    });

    test('nothing close, or too short, suggests nothing', () {
      expect(didYouMean('xyzzy', words), isNull);
      expect(didYouMean('in', words), isNull);
    });
  });
}
