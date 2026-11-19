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
  String durationHoursMinutes(int hours, String minutes) {
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

  @override
  String completeToast(String title) {
    return 'Nice. “$title” is done';
  }

  @override
  String get undo => 'Undo';

  @override
  String checkboxComplete(String title) {
    return 'Complete: $title';
  }

  @override
  String checkboxReopen(String title) {
    return 'Mark not done: $title';
  }

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get todaysProgress => 'TODAY\'S PROGRESS';

  @override
  String heroOfDone(int total) {
    return ' of $total done';
  }

  @override
  String get nothingPlanned => 'Nothing planned';

  @override
  String heroSemantics(int done, int total) {
    return '$done of $total tasks done today';
  }

  @override
  String subtaskCount(int done, int total) {
    return '$done/$total';
  }

  @override
  String subtaskSemantics(int done, int total) {
    return '$done of $total subtasks done';
  }

  @override
  String get repeats => 'Repeats';

  @override
  String tagLabel(String name) {
    return '#$name';
  }

  @override
  String get close => 'Close';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get cancel => 'Cancel';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String stepIndicator(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get increase => 'Increase';

  @override
  String get decrease => 'Decrease';

  @override
  String get back => 'Back';

  @override
  String get skip => 'Skip';

  @override
  String get continueAction => 'Continue';

  @override
  String get notSet => '—';

  @override
  String get off => 'Off';

  @override
  String get splashTagline => 'Get today done.';

  @override
  String get makerPrefix => 'by ';

  @override
  String get makerName => 'BrendanLTW';

  @override
  String get welcomeTitle => 'Get today done, one tap at a time.';

  @override
  String get welcomeBody =>
      'Capture tasks in seconds, focus on what matters and watch your day fill up.';

  @override
  String get getStarted => 'Get started';

  @override
  String get skipSetup => 'Skip setup';

  @override
  String get welcomeDoneChip => 'Pay TNB bill';

  @override
  String get welcomeFocusChip => 'Focus 25:00';

  @override
  String get welcomeRingValue => '4 of 6';

  @override
  String get welcomeRingLabel => 'done today';

  @override
  String get welcomeTaskTitle => 'Finish Q4 revenue slides';

  @override
  String get welcomeTaskTime => '5:00 PM';

  @override
  String get nameTitle => 'What should we call you?';

  @override
  String get nameBody =>
      'It\'s only used for your greeting and stays on this phone.';

  @override
  String get nameHint => 'Your name';

  @override
  String get nameHelp => 'You can change this any time in Settings.';

  @override
  String get firstTaskTitle => 'What\'s one thing to get done today?';

  @override
  String firstTaskTitleNamed(String name) {
    return 'What\'s one thing to get done today, $name?';
  }

  @override
  String get firstTaskBody =>
      'Just a title is fine. You can add dates, priorities and projects later.';

  @override
  String get firstTaskHint => 'Type a task';

  @override
  String get orPickOne => 'OR PICK ONE';

  @override
  String get suggestionPlanWeek => 'Plan my week';

  @override
  String get suggestionClearInbox => 'Clear my inbox';

  @override
  String get suggestionWalk => '30-minute walk';

  @override
  String get suggestionCallMum => 'Call mum';

  @override
  String get whenLabel => 'WHEN';

  @override
  String get whenToday => 'Today';

  @override
  String get whenTomorrow => 'Tomorrow';

  @override
  String get whenNoDate => 'No date';

  @override
  String get addTask => 'Add task';

  @override
  String get doItLater => 'I\'ll do it later';

  @override
  String get remindersTitle => 'Want a nudge?';

  @override
  String get remindersBody =>
      'ctrlTask can remind you when tasks are due and help you plan each morning.';

  @override
  String get taskReminders => 'Task reminders';

  @override
  String get taskRemindersDetail => 'At the time you set on a task';

  @override
  String get dailyPlan => 'Daily plan';

  @override
  String get dailyPlanDetail => 'A short list of what\'s due today';

  @override
  String get overdueNudges => 'Overdue nudges';

  @override
  String get overdueNudgesDetail => 'Once a day, if something slips';

  @override
  String get dailyPlanAt => 'DAILY PLAN AT';

  @override
  String get allowNotifications => 'Allow notifications';

  @override
  String get notNow => 'Not now';

  @override
  String get allSetTitle => 'You\'re all set';

  @override
  String allSetTitleNamed(String name) {
    return 'You\'re all set, $name';
  }

  @override
  String get allSetBody =>
      'Your first task is on today\'s list. Tick it off to start your streak.';

  @override
  String get allSetBodyNoTask =>
      'Add your first task from Today whenever you\'re ready.';

  @override
  String get yourSetup => 'YOUR SETUP';

  @override
  String get setupName => 'Name';

  @override
  String get setupFirstTask => 'First task';

  @override
  String get setupDailyPlan => 'Daily plan';

  @override
  String get setupWeekStart => 'Week starts on';

  @override
  String get goToToday => 'Go to Today';

  @override
  String get createProjectFirst => 'Create a project first';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String greetingNamed(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get dueToday => 'DUE TODAY';

  @override
  String get allTasks => 'All tasks';

  @override
  String get upcomingDeadlines => 'UPCOMING DEADLINES';

  @override
  String get calendar => 'Calendar';

  @override
  String get statStreak => 'STREAK';

  @override
  String get statFocused => 'FOCUSED';

  @override
  String get statThisWeek => 'THIS WEEK';

  @override
  String unitDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' days',
      one: ' day',
    );
    return '$_temp0';
  }

  @override
  String get unitDone => ' done';

  @override
  String get unitHours => 'h';

  @override
  String get unitMinutes => 'm';

  @override
  String streakSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return 'Streak, $_temp0';
  }

  @override
  String focusedSemantics(String duration) {
    return 'Focused today, $duration';
  }

  @override
  String thisWeekSemantics(int count) {
    return 'This week, $count done';
  }

  @override
  String overdueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue tasks',
      one: '1 overdue task',
    );
    return '$_temp0';
  }

  @override
  String wasDueOn(String date) {
    return 'was due $date';
  }

  @override
  String wasDueAt(String time) {
    return 'was due at $time';
  }

  @override
  String titleWithDetail(String title, String detail) {
    return '$title · $detail';
  }

  @override
  String heroLeftNext(int left, String title) {
    return '$left left · next: $title';
  }

  @override
  String get heroEmpty => 'Your ring fills as you tick things off';

  @override
  String get heroAllClear => 'All clear. Enjoy your evening.';

  @override
  String dayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get projectDeadline => 'Project deadline';

  @override
  String get greetingWelcome => 'Welcome';

  @override
  String get blankPageTitle => 'Your day is a blank page';

  @override
  String get blankPageBody =>
      'Add the first thing you want to get done today. A title is all you need.';

  @override
  String get addATask => 'Add a task';

  @override
  String get startWithThese => 'OR START WITH ONE OF THESE';

  @override
  String get createAProject => 'Create a project';

  @override
  String get dayDoneTitle => 'Day done. Nice work.';

  @override
  String dayDoneTasks(int count, String focus) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks finished',
      one: '1 task finished',
    );
    return '$_temp0 and $focus of focus.';
  }

  @override
  String dayDoneTasksOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks finished.',
      one: '1 task finished.',
    );
    return '$_temp0';
  }

  @override
  String dayDoneStreak(String days) {
    return 'Your streak is now $days.';
  }

  @override
  String get planTomorrow => 'Plan tomorrow';

  @override
  String tomorrowSection(String day) {
    return 'TOMORROW · $day';
  }

  @override
  String get anyTime => 'Any time';

  @override
  String get taskTitleHint => 'Task title';

  @override
  String get priorityLabel => 'PRIORITY';

  @override
  String get inbox => 'Inbox';

  @override
  String get more => 'More';

  @override
  String whenTomorrowAt(String time) {
    return 'Tomorrow · $time';
  }
}
