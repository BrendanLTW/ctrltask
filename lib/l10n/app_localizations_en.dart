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

  @override
  String get editTask => 'Edit task';

  @override
  String get save => 'Save';

  @override
  String get titleLabel => 'TITLE';

  @override
  String get titleHint => 'What needs doing?';

  @override
  String get descriptionHint => 'Add details';

  @override
  String get essentials => 'ESSENTIALS';

  @override
  String get due => 'Due';

  @override
  String get noDate => 'No date';

  @override
  String get priority => 'Priority';

  @override
  String subtasksHeader(int done, int total) {
    return 'SUBTASKS · $done/$total';
  }

  @override
  String get addSubtask => 'Add subtask';

  @override
  String get subtaskHint => 'Subtask';

  @override
  String get removeSubtask => 'Remove subtask';

  @override
  String get notesLinks => 'NOTES & LINKS';

  @override
  String get addNoteOrLink => 'Add a note or link';

  @override
  String get addLink => 'Add link';

  @override
  String get linkTitleHint => 'Title (optional)';

  @override
  String get linkUrlHint => 'https://';

  @override
  String get removeLink => 'Remove link';

  @override
  String get linkUrlError => 'Use a link that starts with http:// or https://';

  @override
  String get taskScreenTitle => 'Task';

  @override
  String get edit => 'Edit';

  @override
  String get whenNextWeek => 'Next week';

  @override
  String dueOn(String when) {
    return 'DUE $when';
  }

  @override
  String percent(int value) {
    return '$value%';
  }

  @override
  String get openLink => 'Open link';

  @override
  String get linkFailed => 'Couldn\'t open this link';

  @override
  String get deleteTaskTitle => 'Delete this task?';

  @override
  String deleteTaskBody(String title, int count, String project) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subtasks',
      one: '1 subtask',
    );
    return '“$title” and its $_temp0 will be removed from $project. This can\'t be undone.';
  }

  @override
  String deleteTaskBodyNoSubtasks(String title, String project) {
    return '“$title” will be removed from $project. This can\'t be undone.';
  }

  @override
  String get deleteTask => 'Delete task';

  @override
  String get markDoneInstead => 'Mark as done instead';

  @override
  String get dueDateTitle => 'Due date';

  @override
  String get weekend => 'Weekend';

  @override
  String get noTime => 'No time';

  @override
  String get pick => 'Pick';

  @override
  String setDue(String when) {
    return 'Set $when';
  }

  @override
  String get deadlineOverdue => 'Overdue';

  @override
  String get deadlineToday => 'Due today';

  @override
  String get newShort => 'New';

  @override
  String activeCount(int count) {
    return 'Active · $count';
  }

  @override
  String archivedCount(int count) {
    return 'Archived · $count';
  }

  @override
  String get noDeadline => 'No deadline';

  @override
  String projectDue(String date) {
    return 'Due $date';
  }

  @override
  String get completeSuffix => ' complete';

  @override
  String tasksOfTotal(int done, int total) {
    return '$done of $total tasks';
  }

  @override
  String projectTasksDone(int done, int total) {
    return '$done of $total tasks done';
  }

  @override
  String projectProgressSemantics(int percent, int done, int total) {
    return '$percent% complete, $done of $total tasks';
  }

  @override
  String openCount(int count) {
    return 'Open · $count';
  }

  @override
  String addTaskTo(String project) {
    return 'Add task to $project';
  }

  @override
  String get completed => 'Completed';

  @override
  String get editProject => 'Edit project';

  @override
  String get newProject => 'New project';

  @override
  String get projectNameLabel => 'NAME';

  @override
  String get projectNameHint => 'Project name';

  @override
  String get projectDescriptionHint => 'What\'s it for? (optional)';

  @override
  String get colourLabel => 'Colour';

  @override
  String get iconLabel => 'Icon';

  @override
  String get deadline => 'Deadline';

  @override
  String get createProject => 'Create project';

  @override
  String get archiveProject => 'Archive project';

  @override
  String get deleteProject => 'Delete project';

  @override
  String get removeDeadline => 'Remove deadline';

  @override
  String duplicateProjectName(String name) {
    return 'You already have a project called “$name”';
  }

  @override
  String colourSemantics(String colour) {
    String _temp0 = intl.Intl.selectLogic(colour, {
      'orange': 'Orange',
      'yellow': 'Yellow',
      'green': 'Green',
      'blue': 'Blue',
      'purple': 'Purple',
      'pink': 'Pink',
      'red': 'Red',
      'other': 'Grey',
    });
    return '$_temp0';
  }

  @override
  String deleteProjectTitle(String project) {
    return 'Delete $project?';
  }

  @override
  String deleteProjectBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return 'What should happen to its $_temp0? This can\'t be undone.';
  }

  @override
  String get deleteProjectBodyEmpty => 'This can\'t be undone.';

  @override
  String get moveTasksToInbox => 'Move tasks to Inbox';

  @override
  String get deleteTasksToo => 'Delete tasks too';

  @override
  String get projectsEmptyTitle => 'Group tasks into projects';

  @override
  String projectsEmptyBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count inbox tasks stay',
      one: '1 inbox task stays',
      zero: 'inbox tasks stay',
    );
    return 'A project keeps related tasks together, tracks progress and holds a deadline. Your $_temp0 where they are.';
  }

  @override
  String get popularStartingPoints => 'Popular starting points';

  @override
  String get starterWork => 'Work';

  @override
  String get starterHome => 'Home';

  @override
  String get starterLearning => 'Learning';

  @override
  String get starterTravel => 'Travel';

  @override
  String get archivedProjectsTitle => 'Archived projects';

  @override
  String archivedMeta(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '$_temp0 · finished $date';
  }

  @override
  String get restore => 'Restore';

  @override
  String projectRestored(String project) {
    return '$project is active again';
  }

  @override
  String restoreNameTaken(String name) {
    return 'An active project is already called $name';
  }

  @override
  String get archivedNote =>
      'Archived projects keep their tasks and stats. Restore one to move it back to Projects.';

  @override
  String get moveToProject => 'Move to project';

  @override
  String get searchProjects => 'Search projects';

  @override
  String get noProject => 'No project';

  @override
  String openTasksCount(int count) {
    return '$count open';
  }

  @override
  String get moreOptions => 'More options';

  @override
  String iconSemantics(String icon) {
    String _temp0 = intl.Intl.selectLogic(icon, {
      'globe': 'Globe',
      'chart': 'Chart',
      'home': 'Home',
      'code': 'Code',
      'plane': 'Plane',
      'briefcase': 'Briefcase',
      'bag': 'Bag',
      'book': 'Book',
      'box': 'Box',
      'gift': 'Gift',
      'palette': 'Palette',
      'other': 'Heart',
    });
    return '$_temp0';
  }

  @override
  String focusedFor(String duration) {
    return '$duration focused';
  }

  @override
  String get listView => 'List';

  @override
  String get filterAll => 'All';

  @override
  String get filterToday => 'Today';

  @override
  String get filterUpcoming => 'Upcoming';

  @override
  String get filterHigh => 'High priority';

  @override
  String get filterDone => 'Done';

  @override
  String get sectionOverdue => 'OVERDUE';

  @override
  String sectionToday(String day) {
    return 'TODAY · $day';
  }

  @override
  String get sectionTomorrow => 'TOMORROW';

  @override
  String get sectionThisWeek => 'THIS WEEK';

  @override
  String get sectionLater => 'LATER';

  @override
  String get sectionNoDate => 'NO DATE';

  @override
  String get sectionDone => 'DONE';

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '$_temp0';
  }

  @override
  String leftOfTotal(int left, int total) {
    return '$left of $total left';
  }

  @override
  String get swipeHint => 'Swipe for quick actions';

  @override
  String get reschedule => 'Reschedule';

  @override
  String get completeTask => 'Complete';

  @override
  String get emptyAllTitle => 'No tasks yet';

  @override
  String get emptyAllBody =>
      'Add one and it shows up here, sorted by when it\'s due.';

  @override
  String get emptyTodayTitle => 'Nothing due today';

  @override
  String get emptyTodayBody =>
      'Enjoy the space, or pull something forward from Upcoming.';

  @override
  String get emptyUpcomingTitle => 'Nothing coming up';

  @override
  String get emptyUpcomingBody => 'Tasks due after today show up here.';

  @override
  String get emptyHighTitle => 'No high-priority tasks';

  @override
  String get emptyHighBody => 'Urgent and High tasks show up here.';

  @override
  String get emptyDoneTitle => 'Nothing done yet';

  @override
  String get emptyDoneBody => 'Tick off a task and it shows up here.';

  @override
  String get delete => 'Delete';

  @override
  String get nameCardDetail => 'Data stored on this phone · Edit name';

  @override
  String get addYourName => 'Add your name';

  @override
  String get insightsBannerLabel => 'PRODUCTIVITY INSIGHTS';

  @override
  String insightsBannerSummary(int streak, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '$streak-day streak · $_temp0 done';
  }

  @override
  String get manageSection => 'MANAGE';

  @override
  String settingsFooter(String version) {
    return 'ctrlTask $version · by BrendanLTW';
  }

  @override
  String get editName => 'Edit name';

  @override
  String get editNameNote =>
      'Shown in your greeting on Home. It stays on this phone and is never uploaded.';

  @override
  String focusModeFocus(int minutes) {
    return 'Focus · $minutes';
  }

  @override
  String focusModeShort(int minutes) {
    return 'Short · $minutes';
  }

  @override
  String focusModeLong(int minutes) {
    return 'Long · $minutes';
  }

  @override
  String get focusStats => 'Focus stats';

  @override
  String get workingOn => 'WORKING ON';

  @override
  String get change => 'Change';

  @override
  String get noTask => 'No task';

  @override
  String get phaseReady => 'Ready';

  @override
  String get phaseFocusing => 'Focusing';

  @override
  String get phasePaused => 'Paused';

  @override
  String get phaseBreak => 'On a break';

  @override
  String sessionOf(int session, int total) {
    return 'Session $session of $total';
  }

  @override
  String nextSessionOf(int session, int total) {
    return 'Next: session $session of $total';
  }

  @override
  String get startTimer => 'Start';

  @override
  String get pauseTimer => 'Pause';

  @override
  String get resumeTimer => 'Resume';

  @override
  String get resetTimer => 'Reset';

  @override
  String get finishSession => 'Finish session';

  @override
  String timeLeft(String time) {
    return '$time left';
  }

  @override
  String focusTodayLine(String time, int session) {
    return 'Today $time focused · long break after session $session';
  }

  @override
  String sessionDots(int done, int total) {
    return '$done of $total sessions done this round';
  }

  @override
  String get startFocusSession => 'Start a focus session';

  @override
  String get timerSettings => 'Timer settings';

  @override
  String get durationsSection => 'DURATIONS';

  @override
  String get behaviourSection => 'BEHAVIOUR';

  @override
  String get focusLength => 'Focus';

  @override
  String get focusLengthDetail => 'Deep work block';

  @override
  String get shortBreak => 'Short break';

  @override
  String get shortBreakDetail => 'Between sessions';

  @override
  String get longBreak => 'Long break';

  @override
  String get longBreakDetail => 'After a full round';

  @override
  String get sessionsPerRound => 'Sessions per round';

  @override
  String get sessionsPerRoundDetail => 'Then a long break';

  @override
  String minutesValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get autoStartBreaks => 'Start breaks automatically';

  @override
  String get autoStartNext => 'Start next session automatically';

  @override
  String get silenceWhileFocusing => 'Silence notifications while focusing';

  @override
  String get saveAsDefault => 'Save as default';

  @override
  String get sessionComplete => 'Session complete';

  @override
  String minutesOn(int minutes, String task) {
    return '$minutes min on $task';
  }

  @override
  String minutesOfFocus(int minutes) {
    return '$minutes min of focus';
  }

  @override
  String focusTodayRound(String time, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: '$left more for a long break',
      one: 'one more for a long break',
      zero: 'long break next',
    );
    return 'Today $time focused · $_temp0';
  }

  @override
  String startBreak(int minutes) {
    return 'Start $minutes-min break';
  }

  @override
  String get skipBreak => 'Skip break';

  @override
  String get markTaskDone => 'Mark task done';

  @override
  String get phaseBreakOver => 'Break over';

  @override
  String get startFocusing => 'Start focusing';

  @override
  String get breakTip =>
      'Stand up, refill your water and look at something far away.';

  @override
  String get defaultFocusLength => 'Default focus length';

  @override
  String get preferencesSection => 'PREFERENCES';

  @override
  String get calendarDay => 'Day';

  @override
  String get calendarWeek => 'Week';

  @override
  String get calendarMonth => 'Month';

  @override
  String get legendPending => 'Pending';

  @override
  String get legendCompleted => 'Completed';

  @override
  String get legendOverdue => 'Overdue';

  @override
  String agendaHeader(String date, String relative) {
    return '$date · $relative';
  }

  @override
  String get nothingDue => 'Nothing due. Tap + to plan this day';

  @override
  String get anytime => 'ANYTIME';

  @override
  String dueCounts(int due, int overdue) {
    String _temp0 = intl.Intl.pluralLogic(
      overdue,
      locale: localeName,
      other: ' · $overdue overdue',
      zero: '',
    );
    return '$due due$_temp0';
  }

  @override
  String focusBlock(String task) {
    return 'Focus · $task';
  }

  @override
  String get focusBlockNoTask => 'Focus';

  @override
  String focusSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
    );
    return '$_temp0';
  }

  @override
  String timeRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String nowLine(String time) {
    return 'Now, $time';
  }

  @override
  String doneOn(String date) {
    return 'Done · $date';
  }

  @override
  String get filterSortTitle => 'Filter & sort';

  @override
  String get filterSort => 'Filter and sort';

  @override
  String get reset => 'Reset';

  @override
  String get sortBy => 'SORT BY';

  @override
  String get sortDueDate => 'Due date';

  @override
  String get sortPriority => 'Priority';

  @override
  String get sortProject => 'Project';

  @override
  String get sortAdded => 'Date added';

  @override
  String get projectsSection => 'PROJECTS';

  @override
  String get showCompleted => 'Show completed tasks';

  @override
  String showTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return 'Show $_temp0';
  }

  @override
  String get sectionCompleted => 'COMPLETED';

  @override
  String get sectionByAdded => 'NEWEST FIRST';

  @override
  String get sectionInbox => 'INBOX';

  @override
  String get filtersOn => 'Filter and sort, filters on';

  @override
  String get searchHint => 'Search tasks, projects and tags';

  @override
  String get tasksSection => 'TASKS';

  @override
  String get recentSearches => 'RECENT SEARCHES';

  @override
  String get clear => 'Clear';

  @override
  String noteMatches(String snippet) {
    return 'Note matches “$snippet”';
  }

  @override
  String noMatchesTitle(String query) {
    return 'No matches for “$query”';
  }

  @override
  String get noMatchesBody =>
      'Nothing in your tasks, projects or tags. Check the spelling or try a shorter word.';

  @override
  String didYouMean(String word) {
    return 'Did you mean $word?';
  }

  @override
  String createTaskNamed(String title) {
    return 'Create task “$title”';
  }

  @override
  String get searchTypeAll => 'All';

  @override
  String get searchTypeTasks => 'Tasks';

  @override
  String get searchTypeProjects => 'Projects';

  @override
  String get searchTypeDone => 'Done';

  @override
  String get repeatTitle => 'Repeat';

  @override
  String get repeatNever => 'Never';

  @override
  String get repeatDaily => 'Every day';

  @override
  String get repeatWeekdays => 'Weekdays';

  @override
  String get repeatWeekdaysDetail => 'Monday to Friday';

  @override
  String get repeatWeekly => 'Every week';

  @override
  String get repeatWeeklyDetail => 'Pick the days below';

  @override
  String get repeatMonthly => 'Every month';

  @override
  String repeatMonthlyDetail(String day) {
    return 'On the $day';
  }

  @override
  String get repeatCustom => 'Custom';

  @override
  String get repeatCustomDetail => 'Every few days, weeks or months';

  @override
  String ordinalDay(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      '1': '1st',
      '2': '2nd',
      '3': '3rd',
      '21': '21st',
      '22': '22nd',
      '23': '23rd',
      '31': '31st',
      'other': '${day}th',
    });
    return '$_temp0';
  }

  @override
  String get onTheseDays => 'ON THESE DAYS';

  @override
  String get every => 'Every';

  @override
  String get ends => 'Ends';

  @override
  String get removeEndDate => 'Remove end date';

  @override
  String get summaryWeekdays => 'Weekdays';

  @override
  String summaryWeekly(String days) {
    return 'Every $days';
  }

  @override
  String summaryMonthly(String day) {
    return 'Every month on the $day';
  }

  @override
  String summaryEveryDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Every $n days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String summaryEveryWeeks(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Every $n weeks',
      one: 'Every week',
    );
    return '$_temp0';
  }

  @override
  String summaryEveryMonths(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Every $n months',
      one: 'Every month',
    );
    return '$_temp0';
  }

  @override
  String summaryUntil(String rule, String date) {
    return '$rule until $date';
  }

  @override
  String get repeatButtonNever => 'Don\'t repeat';

  @override
  String get repeatButtonDaily => 'Repeat every day';

  @override
  String get repeatButtonWeekdays => 'Repeat on weekdays';

  @override
  String repeatButtonWeekly(String days) {
    return 'Repeat every $days';
  }

  @override
  String repeatButtonMonthly(String day) {
    return 'Repeat every month on the $day';
  }

  @override
  String repeatButtonDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Repeat every $n days',
      one: 'Repeat every day',
    );
    return '$_temp0';
  }

  @override
  String repeatButtonWeeks(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Repeat every $n weeks',
      one: 'Repeat every week',
    );
    return '$_temp0';
  }

  @override
  String repeatButtonMonths(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Repeat every $n months',
      one: 'Repeat every month',
    );
    return '$_temp0';
  }

  @override
  String get moreDetails => 'MORE DETAILS';

  @override
  String get optional => ' · optional';

  @override
  String get repeatUnitDays => 'Days';

  @override
  String get repeatUnitWeeks => 'Weeks';

  @override
  String get repeatUnitMonths => 'Months';

  @override
  String get tagsTitle => 'Tags';

  @override
  String get searchOrCreateTag => 'Search or create a tag';

  @override
  String get tapToRemove => 'Tap to remove';

  @override
  String createTag(String name) {
    return 'Create tag “#$name”';
  }

  @override
  String saveTags(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Save $count tags',
      one: 'Save 1 tag',
      zero: 'Save without tags',
    );
    return '$_temp0';
  }

  @override
  String get addTagChip => 'Tag';

  @override
  String searchTagsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tags',
      one: '1 tag',
    );
    return 'Search $_temp0';
  }

  @override
  String get mostUsed => 'MOST USED';

  @override
  String get addShort => 'Add';

  @override
  String get tagsNote => 'Tap a tag here to rename, merge or delete it.';

  @override
  String tagTaskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '$_temp0';
  }

  @override
  String get showTaggedTasks => 'Show tasks';

  @override
  String get rename => 'Rename';

  @override
  String get deleteTag => 'Delete tag';

  @override
  String get newTag => 'New tag';

  @override
  String get renameTag => 'Rename tag';

  @override
  String get tagNameHint => 'Tag name';

  @override
  String get createTagButton => 'Create tag';

  @override
  String mergeTagTitle(String from, String into) {
    return 'Merge #$from into #$into?';
  }

  @override
  String mergeTagBody(String from, String into) {
    return 'Tasks tagged #$from will be tagged #$into instead. This can\'t be undone.';
  }

  @override
  String get mergeTag => 'Merge';

  @override
  String deleteTagTitle(String name) {
    return 'Delete #$name?';
  }

  @override
  String deleteTagBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'It comes off $count tasks.',
      one: 'It comes off 1 task.',
      zero: 'No tasks use it.',
    );
    return '$_temp0 This can\'t be undone.';
  }

  @override
  String tagNameTaken(String name) {
    return 'You already have #$name';
  }

  @override
  String get noTagsYet => 'No tags yet';

  @override
  String get notifyPlanTitle => 'Your plan for today';

  @override
  String notifyPlanBody(int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '$_temp0 due · first: $title';
  }

  @override
  String get notifyOverdueBody => 'Open ctrlTask to catch up on what slipped.';

  @override
  String get notifyWeeklyTitle => 'Weekly review';

  @override
  String get notifyWeeklyBody =>
      'See how your week went and plan the next one.';

  @override
  String get notifySessionBody => 'Nice focus. Time for a break.';

  @override
  String get notifyBreakOverBody => 'Ready for the next session?';

  @override
  String notifyDue(String when) {
    return '$when';
  }

  @override
  String get reminderTitle => 'Reminder';

  @override
  String reminderOption(String offset) {
    String _temp0 = intl.Intl.selectLogic(offset, {
      'none': 'No reminder',
      'atTime': 'At due time',
      'min10': '10 minutes before',
      'min30': '30 minutes before',
      'hour1': '1 hour before',
      'morningOf': 'Morning of',
      'other': 'Day before',
    });
    return '$_temp0';
  }

  @override
  String reminderShort(String offset) {
    String _temp0 = intl.Intl.selectLogic(offset, {
      'none': 'None',
      'atTime': 'At due time',
      'min10': '10 min before',
      'min30': '30 min before',
      'hour1': '1 hour before',
      'morningOf': 'Morning of',
      'other': 'Day before',
    });
    return '$_temp0';
  }

  @override
  String reminderNote(String due, String when) {
    return 'Due $due. You\'ll be reminded $when.';
  }

  @override
  String reminderNoteNone(String due) {
    return 'Due $due. No reminder.';
  }

  @override
  String get reminderNoteNoDate => 'Set a due date to get a reminder.';

  @override
  String remindedAt(String time) {
    return 'at $time';
  }

  @override
  String remindedOn(String day, String time) {
    return 'on $day at $time';
  }

  @override
  String get needsDueTime => 'Needs a due time';

  @override
  String get done => 'Done';
}
