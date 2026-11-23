import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/bar_chart.dart';
import 'package:ctrltask/core/widgets/large_text.dart';
import 'package:ctrltask/core/widgets/segmented_control.dart';
import 'package:ctrltask/core/widgets/stat_tile.dart';
import 'package:ctrltask/core/widgets/sub_screen_bar.dart';
import 'package:ctrltask/core/widgets/trend_line.dart';
import 'package:ctrltask/features/insights/domain/insights_calculations.dart';
import 'package:ctrltask/features/insights/presentation/insights_card.dart';
import 'package:ctrltask/features/insights/presentation/insights_hero.dart';
import 'package:ctrltask/features/insights/presentation/insights_providers.dart';
import 'package:ctrltask/features/insights/presentation/power_day_card.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tasks/domain/task_calculations.dart';
import 'package:ctrltask/l10n/date_text.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S34 Insights (PRD §5.9): the last 7 days or this month, all computed
/// from data (PRD §8).
class InsightsScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  InsightsRange _range = InsightsRange.week;

  // shortcut: today is read when the screen opens, so it doesn't roll over
  // at midnight while it stays open; as Home (Phase 4 review).
  late final DateTime _today = _dayOf(ref.read(clockProvider)());

  static DateTime _dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final labels = DateLabels(Localizations.localeOf(context).toLanguageTag());
    final purple = context.projectColors.of(ProjectColorKey.purple);
    final weekStart =
        ref.watch(preferencesProvider).value?.weekStart ?? WeekStart.mon;
    final tasks = ref.watch(insightsTasksProvider).value ?? const [];
    final range = rangeFor(_range, _today);
    final sessions =
        ref.watch(insightsSessionsProvider(range.start, range.end)).value ??
        const [];

    final week = _range == InsightsRange.week;
    final days = daysOf(range);
    final enough = enoughHistory(tasks, _today);

    final rate = completionRate(tasks, range);
    final change = changeInPoints(
      rate,
      completionRate(tasks, previousRange(_range, _today)),
    );
    final subline = switch ((rate, change)) {
      (null, _) => l10n.rateNothingDue,
      (_, null) => l10n.rateNoCompare,
      (_, final c?) => (week ? l10n.rateChangeWeek : l10n.rateChangeMonth)(
        c > 0 ? '+$c' : '$c',
      ),
    };

    final completed = completionsPerDay(tasks, range);
    final completedTotal = completed.fold(0, (a, b) => a + b);
    final focus = focusMinutesPerDay(sessions, range);
    final focusTotal = Duration(minutes: focus.fold(0, (a, b) => a + b));
    final (focusValue, focusUnit) = l10n.durationParts(focusTotal);
    final streakDays = streak(tasks, _today);

    // "W" under a week's bars; every 7th day of the month.
    final barLabels = [
      for (final d in days)
        if (week)
          labels.weekdayNarrow(d.weekday)
        else if (d.day % 7 == 1)
          '${d.day}'
        else
          '',
    ];
    String dayName(DateTime d) =>
        week ? labels.weekdayLong(d) : labels.dayMonth(d);
    String chartText(String chart, List<String> values) => l10n.chartSemantics(
      chart,
      [
        for (final (i, d) in days.indexed)
          l10n.chartValue(dayName(d), values[i]),
      ].join(', '),
    );
    final bestDone = bestIndex(completed);
    final bestFocus = bestIndex(focus);

    final trend = weeklyTrend(tasks, today: _today, weekStart: weekStart);
    final trendDelta = trendChange(trend);
    String percent(double? r) => r == null ? '—' : '${(r * 100).round()}%';
    final power = powerDay(tasks, today: _today, weekStart: weekStart);

    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        child: Column(
          children: [
            SubScreenBar(title: l10n.insights),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenX,
                  8,
                  AppSpacing.screenX,
                  40,
                ),
                children: [
                  SegmentedControl<InsightsRange>(
                    segments: [
                      (
                        value: InsightsRange.week,
                        label: l10n.rangeLast7,
                        icon: null,
                      ),
                      (
                        value: InsightsRange.month,
                        label: l10n.rangeThisMonth,
                        icon: null,
                      ),
                    ],
                    selected: _range,
                    onChanged: (r) => setState(() => _range = r),
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  InsightsHero(rate: rate, subline: subline),
                  const SizedBox(height: AppSpacing.cardGap),
                  PairOrStack(
                    gap: 10,
                    children: [
                      StatTile(
                        icon: AppIcon.check,
                        color: ProjectColorKey.green,
                        label: l10n.statCompleted,
                        value: '$completedTotal',
                        semanticLabel: l10n.completedSemantics(completedTotal),
                      ),
                      StatTile(
                        icon: AppIcon.flame,
                        color: ProjectColorKey.orange,
                        label: l10n.statStreak,
                        value: '$streakDays',
                        unit: l10n.unitDays(streakDays),
                        semanticLabel: l10n.streakSemantics(streakDays),
                      ),
                      StatTile(
                        icon: AppIcon.timer,
                        color: ProjectColorKey.purple,
                        label: l10n.statFocus,
                        value: focusValue,
                        unit: focusUnit,
                        semanticLabel: l10n.focusSemantics(
                          l10n.durationLabel(focusTotal),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  InsightsCard(
                    label: l10n.tasksCompletedLabel,
                    detail: bestDone == null
                        ? null
                        : CardDetail(
                            label: l10n.bestLabel,
                            value: l10n.bestValue(
                              week
                                  ? labels.weekday(days[bestDone])
                                  : labels.dayMonth(days[bestDone]),
                              completed[bestDone],
                            ),
                          ),
                    child: enough
                        ? BarChart(
                            values: completed,
                            labels: barLabels,
                            best: bestDone,
                            showValues: week,
                            color: colors.raised,
                            bestColor: colors.ink,
                            semanticLabel: chartText(l10n.tasksCompletedName, [
                              for (final v in completed) '$v',
                            ]),
                          )
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  InsightsCard(
                    label: l10n.focusTimeLabel,
                    detail: CardDetail(
                      label: l10n.dailyAvgLabel,
                      value: l10n.minutesValue(
                        (focusTotal.inMinutes / days.length).round(),
                      ),
                    ),
                    child: enough
                        ? BarChart(
                            values: focus,
                            labels: barLabels,
                            best: bestFocus,
                            color: purple.tile,
                            bestColor: purple.solid,
                            semanticLabel: chartText(l10n.focusTimeName, [
                              for (final v in focus) l10n.minutesValue(v),
                            ]),
                          )
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  InsightsCard(
                    label: l10n.trendLabel,
                    detail: trendDelta == null
                        ? null
                        : _TrendDelta(points: trendDelta),
                    child: enough
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TrendLine(
                                values: [for (final w in trend) w.rate],
                                semanticLabel: l10n.chartSemantics(
                                  l10n.trendName,
                                  [
                                    for (final w in trend)
                                      l10n.trendWeekSemantics(
                                        labels.dayMonth(w.start),
                                        percent(w.rate),
                                      ),
                                  ].join(', '),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ExcludeSemantics(
                                child: Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  children: [
                                    CardDetail(
                                      label: '',
                                      value: labels.dayMonth(trend.first.start),
                                      color: colors.muted,
                                    ),
                                    CardDetail(
                                      label: '',
                                      value: l10n.trendThisWeek(
                                        percent(trend.last.rate),
                                      ),
                                      color: colors.muted,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                  if (enough && power != null) ...[
                    const SizedBox(height: AppSpacing.cardGap),
                    PowerDayCard(
                      weekday: labels.weekdayLong(
                        DateTime(2024, 1, power.weekday),
                      ),
                      average: power.average,
                      beforeNoon: power.beforeNoon,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "▲ 17 pts" in green, "▼ 5 pts" in red, or "0 pts".
class _TrendDelta extends StatelessWidget {
  const new({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = points > 0
        ? colors.positive
        : points < 0
        ? colors.negative
        : colors.muted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (points != 0) ...[
          CustomPaint(
            size: const Size(12, 10),
            painter: _Triangle(color: color, up: points > 0),
          ),
          const SizedBox(width: 6),
        ],
        CardDetail(
          label: '',
          value: context.l10n.trendPoints(points.abs()),
          color: color,
        ),
      ],
    );
  }
}

class _Triangle extends CustomPainter {
  new({required this.color, required this.up});

  final Color color;
  final bool up;

  @override
  void paint(Canvas canvas, Size size) {
    final path = up
        ? (Path()
            ..moveTo(size.width / 2, 0)
            ..lineTo(size.width, size.height)
            ..lineTo(0, size.height))
        : (Path()
            ..moveTo(0, 0)
            ..lineTo(size.width, 0)
            ..lineTo(size.width / 2, size.height));
    canvas.drawPath(path..close(), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_Triangle old) => old.color != color || old.up != up;
}
