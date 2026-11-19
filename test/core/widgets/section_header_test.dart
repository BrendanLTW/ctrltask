import 'package:ctrltask/core/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_themed.dart';

void main() {
  testWidgets('a detail sits at the right edge', (tester) async {
    await pumpThemed(
      tester,
      const SizedBox(
        width: 358,
        child: SectionHeader('OVERDUE', detail: '1 task', alert: true),
      ),
    );
    final row = tester.getRect(find.byType(SectionHeader));
    final detail = tester.getRect(find.text('1 task'));
    // 8 px in from the edge.
    expect(detail.right, closeTo(row.right - 8, 1));
  });

  testWidgets('a long detail wraps rather than overflow', (tester) async {
    await pumpThemed(
      tester,
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(2)),
        child: SizedBox(
          width: 358,
          child: SectionHeader('TOMORROW', detail: 'Swipe for quick actions'),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
