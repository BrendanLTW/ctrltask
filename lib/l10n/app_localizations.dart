import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'ctrlTask'**
  String get appName;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tabTasks;

  /// No description provided for @tabProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get tabProjects;

  /// No description provided for @tabFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get tabFocus;

  /// No description provided for @quickAddTask.
  ///
  /// In en, this message translates to:
  /// **'Quick add task'**
  String get quickAddTask;

  /// No description provided for @searchTasks.
  ///
  /// In en, this message translates to:
  /// **'Search tasks'**
  String get searchTasks;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTask;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @task.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get task;

  /// No description provided for @project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// No description provided for @relativeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get relativeToday;

  /// No description provided for @relativeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get relativeYesterday;

  /// No description provided for @relativeTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get relativeTomorrow;

  /// "Today, 10:00 AM" or "Thu, 19 Nov, 3:00 PM".
  ///
  /// In en, this message translates to:
  /// **'{day}, {time}'**
  String dayWithTime(String day, String time);

  /// Meta line of an overdue task; day is the short weekday.
  ///
  /// In en, this message translates to:
  /// **'Overdue · {day}'**
  String overdueOn(String day);

  /// No description provided for @wasDueYesterday.
  ///
  /// In en, this message translates to:
  /// **'was due yesterday'**
  String get wasDueYesterday;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day left} other{{count} days left}}'**
  String daysLeft(int count);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String durationHours(int hours);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String durationMinutes(int minutes);

  /// No description provided for @completeToast.
  ///
  /// In en, this message translates to:
  /// **'Nice. “{title}” is done'**
  String completeToast(String title);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Screen-reader label of an open task's checkbox.
  ///
  /// In en, this message translates to:
  /// **'Complete: {title}'**
  String checkboxComplete(String title);

  /// Screen-reader label of a done task's checkbox.
  ///
  /// In en, this message translates to:
  /// **'Mark not done: {title}'**
  String checkboxReopen(String title);

  /// No description provided for @priorityUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get priorityUrgent;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @todaysProgress.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S PROGRESS'**
  String get todaysProgress;

  /// After the big done count: "2" + " of 6 done".
  ///
  /// In en, this message translates to:
  /// **' of {total} done'**
  String heroOfDone(int total);

  /// No description provided for @nothingPlanned.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned'**
  String get nothingPlanned;

  /// No description provided for @heroSemantics.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} tasks done today'**
  String heroSemantics(int done, int total);

  /// No description provided for @subtaskCount.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total}'**
  String subtaskCount(int done, int total);

  /// No description provided for @subtaskSemantics.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} subtasks done'**
  String subtaskSemantics(int done, int total);

  /// No description provided for @repeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get repeats;

  /// No description provided for @tagLabel.
  ///
  /// In en, this message translates to:
  /// **'#{name}'**
  String tagLabel(String name);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @stepIndicator.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepIndicator(int current, int total);

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increase;

  /// No description provided for @decrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decrease;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get notSet;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Get today done.'**
  String get splashTagline;

  /// No description provided for @makerPrefix.
  ///
  /// In en, this message translates to:
  /// **'by '**
  String get makerPrefix;

  /// No description provided for @makerName.
  ///
  /// In en, this message translates to:
  /// **'BrendanLTW'**
  String get makerName;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Get today done, one tap at a time.'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Capture tasks in seconds, focus on what matters and watch your day fill up.'**
  String get welcomeBody;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @skipSetup.
  ///
  /// In en, this message translates to:
  /// **'Skip setup'**
  String get skipSetup;

  /// No description provided for @welcomeDoneChip.
  ///
  /// In en, this message translates to:
  /// **'Pay TNB bill'**
  String get welcomeDoneChip;

  /// No description provided for @welcomeFocusChip.
  ///
  /// In en, this message translates to:
  /// **'Focus 25:00'**
  String get welcomeFocusChip;

  /// No description provided for @welcomeRingValue.
  ///
  /// In en, this message translates to:
  /// **'4 of 6'**
  String get welcomeRingValue;

  /// No description provided for @welcomeRingLabel.
  ///
  /// In en, this message translates to:
  /// **'done today'**
  String get welcomeRingLabel;

  /// No description provided for @welcomeTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish Q4 revenue slides'**
  String get welcomeTaskTitle;

  /// No description provided for @welcomeTaskTime.
  ///
  /// In en, this message translates to:
  /// **'5:00 PM'**
  String get welcomeTaskTime;

  /// No description provided for @nameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get nameTitle;

  /// No description provided for @nameBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s only used for your greeting and stays on this phone.'**
  String get nameBody;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get nameHint;

  /// No description provided for @nameHelp.
  ///
  /// In en, this message translates to:
  /// **'You can change this any time in Settings.'**
  String get nameHelp;

  /// No description provided for @firstTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s one thing to get done today?'**
  String get firstTaskTitle;

  /// No description provided for @firstTaskTitleNamed.
  ///
  /// In en, this message translates to:
  /// **'What\'s one thing to get done today, {name}?'**
  String firstTaskTitleNamed(String name);

  /// No description provided for @firstTaskBody.
  ///
  /// In en, this message translates to:
  /// **'Just a title is fine. You can add dates, priorities and projects later.'**
  String get firstTaskBody;

  /// No description provided for @firstTaskHint.
  ///
  /// In en, this message translates to:
  /// **'Type a task'**
  String get firstTaskHint;

  /// No description provided for @orPickOne.
  ///
  /// In en, this message translates to:
  /// **'OR PICK ONE'**
  String get orPickOne;

  /// No description provided for @suggestionPlanWeek.
  ///
  /// In en, this message translates to:
  /// **'Plan my week'**
  String get suggestionPlanWeek;

  /// No description provided for @suggestionClearInbox.
  ///
  /// In en, this message translates to:
  /// **'Clear my inbox'**
  String get suggestionClearInbox;

  /// No description provided for @suggestionWalk.
  ///
  /// In en, this message translates to:
  /// **'30-minute walk'**
  String get suggestionWalk;

  /// No description provided for @suggestionCallMum.
  ///
  /// In en, this message translates to:
  /// **'Call mum'**
  String get suggestionCallMum;

  /// No description provided for @whenLabel.
  ///
  /// In en, this message translates to:
  /// **'WHEN'**
  String get whenLabel;

  /// No description provided for @whenToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get whenToday;

  /// No description provided for @whenTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get whenTomorrow;

  /// No description provided for @whenNoDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get whenNoDate;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get addTask;

  /// No description provided for @doItLater.
  ///
  /// In en, this message translates to:
  /// **'I\'ll do it later'**
  String get doItLater;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Want a nudge?'**
  String get remindersTitle;

  /// No description provided for @remindersBody.
  ///
  /// In en, this message translates to:
  /// **'ctrlTask can remind you when tasks are due and help you plan each morning.'**
  String get remindersBody;

  /// No description provided for @taskReminders.
  ///
  /// In en, this message translates to:
  /// **'Task reminders'**
  String get taskReminders;

  /// No description provided for @taskRemindersDetail.
  ///
  /// In en, this message translates to:
  /// **'At the time you set on a task'**
  String get taskRemindersDetail;

  /// No description provided for @dailyPlan.
  ///
  /// In en, this message translates to:
  /// **'Daily plan'**
  String get dailyPlan;

  /// No description provided for @dailyPlanDetail.
  ///
  /// In en, this message translates to:
  /// **'A short list of what\'s due today'**
  String get dailyPlanDetail;

  /// No description provided for @overdueNudges.
  ///
  /// In en, this message translates to:
  /// **'Overdue nudges'**
  String get overdueNudges;

  /// No description provided for @overdueNudgesDetail.
  ///
  /// In en, this message translates to:
  /// **'Once a day, if something slips'**
  String get overdueNudgesDetail;

  /// No description provided for @dailyPlanAt.
  ///
  /// In en, this message translates to:
  /// **'DAILY PLAN AT'**
  String get dailyPlanAt;

  /// No description provided for @allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get allowNotifications;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @allSetTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set'**
  String get allSetTitle;

  /// No description provided for @allSetTitleNamed.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set, {name}'**
  String allSetTitleNamed(String name);

  /// No description provided for @allSetBody.
  ///
  /// In en, this message translates to:
  /// **'Your first task is on today\'s list. Tick it off to start your streak.'**
  String get allSetBody;

  /// No description provided for @allSetBodyNoTask.
  ///
  /// In en, this message translates to:
  /// **'Add your first task from Today whenever you\'re ready.'**
  String get allSetBodyNoTask;

  /// No description provided for @yourSetup.
  ///
  /// In en, this message translates to:
  /// **'YOUR SETUP'**
  String get yourSetup;

  /// No description provided for @setupName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get setupName;

  /// No description provided for @setupFirstTask.
  ///
  /// In en, this message translates to:
  /// **'First task'**
  String get setupFirstTask;

  /// No description provided for @setupDailyPlan.
  ///
  /// In en, this message translates to:
  /// **'Daily plan'**
  String get setupDailyPlan;

  /// No description provided for @setupWeekStart.
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get setupWeekStart;

  /// No description provided for @goToToday.
  ///
  /// In en, this message translates to:
  /// **'Go to Today'**
  String get goToToday;

  /// No description provided for @createProjectFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a project first'**
  String get createProjectFirst;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @greetingNamed.
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name}'**
  String greetingNamed(String greeting, String name);

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'DUE TODAY'**
  String get dueToday;

  /// No description provided for @allTasks.
  ///
  /// In en, this message translates to:
  /// **'All tasks'**
  String get allTasks;

  /// No description provided for @upcomingDeadlines.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING DEADLINES'**
  String get upcomingDeadlines;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @statStreak.
  ///
  /// In en, this message translates to:
  /// **'STREAK'**
  String get statStreak;

  /// No description provided for @statFocused.
  ///
  /// In en, this message translates to:
  /// **'FOCUSED'**
  String get statFocused;

  /// No description provided for @statThisWeek.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK'**
  String get statThisWeek;

  /// No description provided for @unitDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{ day} other{ days}}'**
  String unitDays(int count);

  /// No description provided for @unitDone.
  ///
  /// In en, this message translates to:
  /// **' done'**
  String get unitDone;

  /// No description provided for @unitHours.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get unitHours;

  /// No description provided for @unitMinutes.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get unitMinutes;

  /// No description provided for @streakSemantics.
  ///
  /// In en, this message translates to:
  /// **'Streak, {count, plural, =1{1 day} other{{count} days}}'**
  String streakSemantics(int count);

  /// No description provided for @focusedSemantics.
  ///
  /// In en, this message translates to:
  /// **'Focused today, {duration}'**
  String focusedSemantics(String duration);

  /// No description provided for @thisWeekSemantics.
  ///
  /// In en, this message translates to:
  /// **'This week, {count} done'**
  String thisWeekSemantics(int count);

  /// No description provided for @overdueCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 overdue task} other{{count} overdue tasks}}'**
  String overdueCount(int count);

  /// No description provided for @wasDueOn.
  ///
  /// In en, this message translates to:
  /// **'was due {date}'**
  String wasDueOn(String date);

  /// No description provided for @wasDueAt.
  ///
  /// In en, this message translates to:
  /// **'was due at {time}'**
  String wasDueAt(String time);

  /// No description provided for @titleWithDetail.
  ///
  /// In en, this message translates to:
  /// **'{title} · {detail}'**
  String titleWithDetail(String title, String detail);

  /// No description provided for @heroLeftNext.
  ///
  /// In en, this message translates to:
  /// **'{left} left · next: {title}'**
  String heroLeftNext(int left, String title);

  /// No description provided for @heroEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your ring fills as you tick things off'**
  String get heroEmpty;

  /// No description provided for @heroAllClear.
  ///
  /// In en, this message translates to:
  /// **'All clear. Enjoy your evening.'**
  String get heroAllClear;

  /// No description provided for @dayCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String dayCount(int count);

  /// No description provided for @projectDeadline.
  ///
  /// In en, this message translates to:
  /// **'Project deadline'**
  String get projectDeadline;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
