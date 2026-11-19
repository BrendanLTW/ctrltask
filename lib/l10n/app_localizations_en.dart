// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ctrlTask';

  @override
  String get tabHome => 'Home';

  @override
  String get tabTasks => 'Tasks';

  @override
  String get tabProjects => 'Projects';

  @override
  String get tabFocus => 'Focus';

  @override
  String get quickAddTask => 'Quick add task';

  @override
  String get searchTasks => 'Search tasks';

  @override
  String get settings => 'Settings';

  @override
  String get newTask => 'New task';

  @override
  String get search => 'Search';

  @override
  String get insights => 'Insights';

  @override
  String get task => 'Task';

  @override
  String get project => 'Project';

  @override
  String get finishOnboarding => 'Finish onboarding';

  @override
  String get relativeToday => 'Today';

  @override
  String get relativeYesterday => 'Yesterday';

  @override
  String get relativeTomorrow => 'Tomorrow';

  @override
  String dayWithTime(String day, String time) {
    return '$day, $time';
  }

  @override
  String overdueOn(String day) {
    return 'Overdue · $day';
  }

  @override
  String get wasDueYesterday => 'was due yesterday';

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String durationHours(int hours) {
    return '${hours}h';
  }

  @override
  String durationMinutes(int minutes) {
    return '${minutes}m';
  }
}
