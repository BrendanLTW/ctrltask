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

  /// Minutes are zero-padded: "2h 05m".
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, String minutes);

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

  /// No description provided for @greetingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get greetingWelcome;

  /// No description provided for @blankPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Your day is a blank page'**
  String get blankPageTitle;

  /// No description provided for @blankPageBody.
  ///
  /// In en, this message translates to:
  /// **'Add the first thing you want to get done today. A title is all you need.'**
  String get blankPageBody;

  /// No description provided for @addATask.
  ///
  /// In en, this message translates to:
  /// **'Add a task'**
  String get addATask;

  /// No description provided for @startWithThese.
  ///
  /// In en, this message translates to:
  /// **'OR START WITH ONE OF THESE'**
  String get startWithThese;

  /// No description provided for @createAProject.
  ///
  /// In en, this message translates to:
  /// **'Create a project'**
  String get createAProject;

  /// No description provided for @dayDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Day done. Nice work.'**
  String get dayDoneTitle;

  /// No description provided for @dayDoneTasks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task finished} other{{count} tasks finished}} and {focus} of focus.'**
  String dayDoneTasks(int count, String focus);

  /// No description provided for @dayDoneTasksOnly.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task finished.} other{{count} tasks finished.}}'**
  String dayDoneTasksOnly(int count);

  /// No description provided for @dayDoneStreak.
  ///
  /// In en, this message translates to:
  /// **'Your streak is now {days}.'**
  String dayDoneStreak(String days);

  /// No description provided for @planTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Plan tomorrow'**
  String get planTomorrow;

  /// No description provided for @tomorrowSection.
  ///
  /// In en, this message translates to:
  /// **'TOMORROW · {day}'**
  String tomorrowSection(String day);

  /// No description provided for @anyTime.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get anyTime;

  /// No description provided for @taskTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get taskTitleHint;

  /// No description provided for @priorityLabel.
  ///
  /// In en, this message translates to:
  /// **'PRIORITY'**
  String get priorityLabel;

  /// No description provided for @inbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inbox;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @whenTomorrowAt.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow · {time}'**
  String whenTomorrowAt(String time);

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTask;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'TITLE'**
  String get titleLabel;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'What needs doing?'**
  String get titleHint;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add details'**
  String get descriptionHint;

  /// No description provided for @essentials.
  ///
  /// In en, this message translates to:
  /// **'ESSENTIALS'**
  String get essentials;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @noDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get noDate;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @subtasksHeader.
  ///
  /// In en, this message translates to:
  /// **'SUBTASKS · {done}/{total}'**
  String subtasksHeader(int done, int total);

  /// No description provided for @addSubtask.
  ///
  /// In en, this message translates to:
  /// **'Add subtask'**
  String get addSubtask;

  /// No description provided for @subtaskHint.
  ///
  /// In en, this message translates to:
  /// **'Subtask'**
  String get subtaskHint;

  /// No description provided for @removeSubtask.
  ///
  /// In en, this message translates to:
  /// **'Remove subtask'**
  String get removeSubtask;

  /// No description provided for @notesLinks.
  ///
  /// In en, this message translates to:
  /// **'NOTES & LINKS'**
  String get notesLinks;

  /// No description provided for @addNoteOrLink.
  ///
  /// In en, this message translates to:
  /// **'Add a note or link'**
  String get addNoteOrLink;

  /// No description provided for @addLink.
  ///
  /// In en, this message translates to:
  /// **'Add link'**
  String get addLink;

  /// No description provided for @linkTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title (optional)'**
  String get linkTitleHint;

  /// No description provided for @linkUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://'**
  String get linkUrlHint;

  /// No description provided for @removeLink.
  ///
  /// In en, this message translates to:
  /// **'Remove link'**
  String get removeLink;

  /// No description provided for @linkUrlError.
  ///
  /// In en, this message translates to:
  /// **'Use a link that starts with http:// or https://'**
  String get linkUrlError;

  /// No description provided for @taskScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get taskScreenTitle;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @whenNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get whenNextWeek;

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'DUE {when}'**
  String dueOn(String when);

  /// No description provided for @percent.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String percent(int value);

  /// No description provided for @openLink.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get openLink;

  /// No description provided for @linkFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open this link'**
  String get linkFailed;

  /// No description provided for @deleteTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this task?'**
  String get deleteTaskTitle;

  /// No description provided for @deleteTaskBody.
  ///
  /// In en, this message translates to:
  /// **'“{title}” and its {count, plural, =1{1 subtask} other{{count} subtasks}} will be removed from {project}. This can\'t be undone.'**
  String deleteTaskBody(String title, int count, String project);

  /// No description provided for @deleteTaskBodyNoSubtasks.
  ///
  /// In en, this message translates to:
  /// **'“{title}” will be removed from {project}. This can\'t be undone.'**
  String deleteTaskBodyNoSubtasks(String title, String project);

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get deleteTask;

  /// No description provided for @markDoneInstead.
  ///
  /// In en, this message translates to:
  /// **'Mark as done instead'**
  String get markDoneInstead;

  /// No description provided for @dueDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get dueDateTitle;

  /// No description provided for @weekend.
  ///
  /// In en, this message translates to:
  /// **'Weekend'**
  String get weekend;

  /// No description provided for @noTime.
  ///
  /// In en, this message translates to:
  /// **'No time'**
  String get noTime;

  /// No description provided for @pick.
  ///
  /// In en, this message translates to:
  /// **'Pick'**
  String get pick;

  /// No description provided for @setDue.
  ///
  /// In en, this message translates to:
  /// **'Set {when}'**
  String setDue(String when);

  /// No description provided for @deadlineOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get deadlineOverdue;

  /// No description provided for @deadlineToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get deadlineToday;

  /// No description provided for @newShort.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newShort;

  /// No description provided for @activeCount.
  ///
  /// In en, this message translates to:
  /// **'Active · {count}'**
  String activeCount(int count);

  /// No description provided for @archivedCount.
  ///
  /// In en, this message translates to:
  /// **'Archived · {count}'**
  String archivedCount(int count);

  /// No description provided for @noDeadline.
  ///
  /// In en, this message translates to:
  /// **'No deadline'**
  String get noDeadline;

  /// No description provided for @projectDue.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String projectDue(String date);

  /// No description provided for @completeSuffix.
  ///
  /// In en, this message translates to:
  /// **' complete'**
  String get completeSuffix;

  /// No description provided for @tasksOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} tasks'**
  String tasksOfTotal(int done, int total);

  /// No description provided for @projectTasksDone.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} tasks done'**
  String projectTasksDone(int done, int total);

  /// No description provided for @projectProgressSemantics.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete, {done} of {total} tasks'**
  String projectProgressSemantics(int percent, int done, int total);

  /// No description provided for @openCount.
  ///
  /// In en, this message translates to:
  /// **'Open · {count}'**
  String openCount(int count);

  /// No description provided for @addTaskTo.
  ///
  /// In en, this message translates to:
  /// **'Add task to {project}'**
  String addTaskTo(String project);

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @editProject.
  ///
  /// In en, this message translates to:
  /// **'Edit project'**
  String get editProject;

  /// No description provided for @newProject.
  ///
  /// In en, this message translates to:
  /// **'New project'**
  String get newProject;

  /// No description provided for @projectNameLabel.
  ///
  /// In en, this message translates to:
  /// **'NAME'**
  String get projectNameLabel;

  /// No description provided for @projectNameHint.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get projectNameHint;

  /// No description provided for @projectDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s it for? (optional)'**
  String get projectDescriptionHint;

  /// No description provided for @colourLabel.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get colourLabel;

  /// No description provided for @iconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get iconLabel;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadline;

  /// No description provided for @createProject.
  ///
  /// In en, this message translates to:
  /// **'Create project'**
  String get createProject;

  /// No description provided for @archiveProject.
  ///
  /// In en, this message translates to:
  /// **'Archive project'**
  String get archiveProject;

  /// No description provided for @deleteProject.
  ///
  /// In en, this message translates to:
  /// **'Delete project'**
  String get deleteProject;

  /// No description provided for @removeDeadline.
  ///
  /// In en, this message translates to:
  /// **'Remove deadline'**
  String get removeDeadline;

  /// No description provided for @duplicateProjectName.
  ///
  /// In en, this message translates to:
  /// **'You already have a project called “{name}”'**
  String duplicateProjectName(String name);

  /// No description provided for @colourSemantics.
  ///
  /// In en, this message translates to:
  /// **'{colour, select, orange{Orange} yellow{Yellow} green{Green} blue{Blue} purple{Purple} pink{Pink} red{Red} other{Grey}}'**
  String colourSemantics(String colour);

  /// No description provided for @deleteProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {project}?'**
  String deleteProjectTitle(String project);

  /// No description provided for @deleteProjectBody.
  ///
  /// In en, this message translates to:
  /// **'What should happen to its {count, plural, =1{1 task} other{{count} tasks}}? This can\'t be undone.'**
  String deleteProjectBody(int count);

  /// No description provided for @deleteProjectBodyEmpty.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get deleteProjectBodyEmpty;

  /// No description provided for @moveTasksToInbox.
  ///
  /// In en, this message translates to:
  /// **'Move tasks to Inbox'**
  String get moveTasksToInbox;

  /// No description provided for @deleteTasksToo.
  ///
  /// In en, this message translates to:
  /// **'Delete tasks too'**
  String get deleteTasksToo;

  /// No description provided for @projectsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Group tasks into projects'**
  String get projectsEmptyTitle;

  /// No description provided for @projectsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'A project keeps related tasks together, tracks progress and holds a deadline. Your {count, plural, =0{inbox tasks stay} =1{1 inbox task stays} other{{count} inbox tasks stay}} where they are.'**
  String projectsEmptyBody(int count);

  /// No description provided for @popularStartingPoints.
  ///
  /// In en, this message translates to:
  /// **'Popular starting points'**
  String get popularStartingPoints;

  /// No description provided for @starterWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get starterWork;

  /// No description provided for @starterHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get starterHome;

  /// No description provided for @starterLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get starterLearning;

  /// No description provided for @starterTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get starterTravel;

  /// No description provided for @archivedProjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Archived projects'**
  String get archivedProjectsTitle;

  /// No description provided for @archivedMeta.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task} other{{count} tasks}} · finished {date}'**
  String archivedMeta(int count, String date);

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @projectRestored.
  ///
  /// In en, this message translates to:
  /// **'{project} is active again'**
  String projectRestored(String project);

  /// No description provided for @restoreNameTaken.
  ///
  /// In en, this message translates to:
  /// **'An active project is already called {name}'**
  String restoreNameTaken(String name);

  /// No description provided for @archivedNote.
  ///
  /// In en, this message translates to:
  /// **'Archived projects keep their tasks and stats. Restore one to move it back to Projects.'**
  String get archivedNote;

  /// No description provided for @moveToProject.
  ///
  /// In en, this message translates to:
  /// **'Move to project'**
  String get moveToProject;

  /// No description provided for @searchProjects.
  ///
  /// In en, this message translates to:
  /// **'Search projects'**
  String get searchProjects;

  /// No description provided for @noProject.
  ///
  /// In en, this message translates to:
  /// **'No project'**
  String get noProject;

  /// No description provided for @openTasksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} open'**
  String openTasksCount(int count);

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @iconSemantics.
  ///
  /// In en, this message translates to:
  /// **'{icon, select, globe{Globe} chart{Chart} home{Home} code{Code} plane{Plane} briefcase{Briefcase} bag{Bag} book{Book} box{Box} gift{Gift} palette{Palette} other{Heart}}'**
  String iconSemantics(String icon);

  /// No description provided for @focusedFor.
  ///
  /// In en, this message translates to:
  /// **'{duration} focused'**
  String focusedFor(String duration);

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listView;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get filterToday;

  /// No description provided for @filterUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get filterUpcoming;

  /// No description provided for @filterHigh.
  ///
  /// In en, this message translates to:
  /// **'High priority'**
  String get filterHigh;

  /// No description provided for @filterDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get filterDone;

  /// No description provided for @sectionOverdue.
  ///
  /// In en, this message translates to:
  /// **'OVERDUE'**
  String get sectionOverdue;

  /// No description provided for @sectionToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY · {day}'**
  String sectionToday(String day);

  /// No description provided for @sectionTomorrow.
  ///
  /// In en, this message translates to:
  /// **'TOMORROW'**
  String get sectionTomorrow;

  /// No description provided for @sectionThisWeek.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK'**
  String get sectionThisWeek;

  /// No description provided for @sectionLater.
  ///
  /// In en, this message translates to:
  /// **'LATER'**
  String get sectionLater;

  /// No description provided for @sectionNoDate.
  ///
  /// In en, this message translates to:
  /// **'NO DATE'**
  String get sectionNoDate;

  /// No description provided for @sectionDone.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get sectionDone;

  /// No description provided for @taskCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task} other{{count} tasks}}'**
  String taskCount(int count);

  /// No description provided for @leftOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{left} of {total} left'**
  String leftOfTotal(int left, int total);

  /// No description provided for @swipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe for quick actions'**
  String get swipeHint;

  /// No description provided for @reschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get reschedule;

  /// No description provided for @completeTask.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeTask;

  /// No description provided for @emptyAllTitle.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get emptyAllTitle;

  /// No description provided for @emptyAllBody.
  ///
  /// In en, this message translates to:
  /// **'Add one and it shows up here, sorted by when it\'s due.'**
  String get emptyAllBody;

  /// No description provided for @emptyTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing due today'**
  String get emptyTodayTitle;

  /// No description provided for @emptyTodayBody.
  ///
  /// In en, this message translates to:
  /// **'Enjoy the space, or pull something forward from Upcoming.'**
  String get emptyTodayBody;

  /// No description provided for @emptyUpcomingTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing coming up'**
  String get emptyUpcomingTitle;

  /// No description provided for @emptyUpcomingBody.
  ///
  /// In en, this message translates to:
  /// **'Tasks due after today show up here.'**
  String get emptyUpcomingBody;

  /// No description provided for @emptyHighTitle.
  ///
  /// In en, this message translates to:
  /// **'No high-priority tasks'**
  String get emptyHighTitle;

  /// No description provided for @emptyHighBody.
  ///
  /// In en, this message translates to:
  /// **'Urgent and High tasks show up here.'**
  String get emptyHighBody;

  /// No description provided for @emptyDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing done yet'**
  String get emptyDoneTitle;

  /// No description provided for @emptyDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Tick off a task and it shows up here.'**
  String get emptyDoneBody;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @nameCardDetail.
  ///
  /// In en, this message translates to:
  /// **'Data stored on this phone · Edit name'**
  String get nameCardDetail;

  /// No description provided for @addYourName.
  ///
  /// In en, this message translates to:
  /// **'Add your name'**
  String get addYourName;

  /// No description provided for @insightsBannerLabel.
  ///
  /// In en, this message translates to:
  /// **'PRODUCTIVITY INSIGHTS'**
  String get insightsBannerLabel;

  /// No description provided for @insightsBannerSummary.
  ///
  /// In en, this message translates to:
  /// **'{streak}-day streak · {count, plural, =1{1 task} other{{count} tasks}} done'**
  String insightsBannerSummary(int streak, int count);

  /// No description provided for @manageSection.
  ///
  /// In en, this message translates to:
  /// **'MANAGE'**
  String get manageSection;

  /// No description provided for @settingsFooter.
  ///
  /// In en, this message translates to:
  /// **'ctrlTask {version} · by BrendanLTW'**
  String settingsFooter(String version);

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get editName;

  /// No description provided for @editNameNote.
  ///
  /// In en, this message translates to:
  /// **'Shown in your greeting on Home. It stays on this phone and is never uploaded.'**
  String get editNameNote;

  /// No description provided for @focusModeFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus · {minutes}'**
  String focusModeFocus(int minutes);

  /// No description provided for @focusModeShort.
  ///
  /// In en, this message translates to:
  /// **'Short · {minutes}'**
  String focusModeShort(int minutes);

  /// No description provided for @focusModeLong.
  ///
  /// In en, this message translates to:
  /// **'Long · {minutes}'**
  String focusModeLong(int minutes);

  /// No description provided for @focusStats.
  ///
  /// In en, this message translates to:
  /// **'Focus stats'**
  String get focusStats;

  /// No description provided for @workingOn.
  ///
  /// In en, this message translates to:
  /// **'WORKING ON'**
  String get workingOn;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @noTask.
  ///
  /// In en, this message translates to:
  /// **'No task'**
  String get noTask;

  /// No description provided for @phaseReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get phaseReady;

  /// No description provided for @phaseFocusing.
  ///
  /// In en, this message translates to:
  /// **'Focusing'**
  String get phaseFocusing;

  /// No description provided for @phasePaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get phasePaused;

  /// No description provided for @phaseBreak.
  ///
  /// In en, this message translates to:
  /// **'On a break'**
  String get phaseBreak;

  /// No description provided for @sessionOf.
  ///
  /// In en, this message translates to:
  /// **'Session {session} of {total}'**
  String sessionOf(int session, int total);

  /// No description provided for @nextSessionOf.
  ///
  /// In en, this message translates to:
  /// **'Next: session {session} of {total}'**
  String nextSessionOf(int session, int total);

  /// No description provided for @startTimer.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startTimer;

  /// No description provided for @pauseTimer.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseTimer;

  /// No description provided for @resumeTimer.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeTimer;

  /// No description provided for @resetTimer.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetTimer;

  /// No description provided for @finishSession.
  ///
  /// In en, this message translates to:
  /// **'Finish session'**
  String get finishSession;

  /// No description provided for @timeLeft.
  ///
  /// In en, this message translates to:
  /// **'{time} left'**
  String timeLeft(String time);

  /// No description provided for @focusTodayLine.
  ///
  /// In en, this message translates to:
  /// **'Today {time} focused · long break after session {session}'**
  String focusTodayLine(String time, int session);

  /// No description provided for @sessionDots.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} sessions done this round'**
  String sessionDots(int done, int total);

  /// No description provided for @startFocusSession.
  ///
  /// In en, this message translates to:
  /// **'Start a focus session'**
  String get startFocusSession;

  /// No description provided for @timerSettings.
  ///
  /// In en, this message translates to:
  /// **'Timer settings'**
  String get timerSettings;

  /// No description provided for @durationsSection.
  ///
  /// In en, this message translates to:
  /// **'DURATIONS'**
  String get durationsSection;

  /// No description provided for @behaviourSection.
  ///
  /// In en, this message translates to:
  /// **'BEHAVIOUR'**
  String get behaviourSection;

  /// No description provided for @focusLength.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focusLength;

  /// No description provided for @focusLengthDetail.
  ///
  /// In en, this message translates to:
  /// **'Deep work block'**
  String get focusLengthDetail;

  /// No description provided for @shortBreak.
  ///
  /// In en, this message translates to:
  /// **'Short break'**
  String get shortBreak;

  /// No description provided for @shortBreakDetail.
  ///
  /// In en, this message translates to:
  /// **'Between sessions'**
  String get shortBreakDetail;

  /// No description provided for @longBreak.
  ///
  /// In en, this message translates to:
  /// **'Long break'**
  String get longBreak;

  /// No description provided for @longBreakDetail.
  ///
  /// In en, this message translates to:
  /// **'After a full round'**
  String get longBreakDetail;

  /// No description provided for @sessionsPerRound.
  ///
  /// In en, this message translates to:
  /// **'Sessions per round'**
  String get sessionsPerRound;

  /// No description provided for @sessionsPerRoundDetail.
  ///
  /// In en, this message translates to:
  /// **'Then a long break'**
  String get sessionsPerRoundDetail;

  /// No description provided for @minutesValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesValue(int minutes);

  /// No description provided for @autoStartBreaks.
  ///
  /// In en, this message translates to:
  /// **'Start breaks automatically'**
  String get autoStartBreaks;

  /// No description provided for @autoStartNext.
  ///
  /// In en, this message translates to:
  /// **'Start next session automatically'**
  String get autoStartNext;

  /// No description provided for @silenceWhileFocusing.
  ///
  /// In en, this message translates to:
  /// **'Silence notifications while focusing'**
  String get silenceWhileFocusing;

  /// No description provided for @saveAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Save as default'**
  String get saveAsDefault;

  /// No description provided for @sessionComplete.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get sessionComplete;

  /// No description provided for @minutesOn.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min on {task}'**
  String minutesOn(int minutes, String task);

  /// No description provided for @minutesOfFocus.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min of focus'**
  String minutesOfFocus(int minutes);

  /// No description provided for @focusTodayRound.
  ///
  /// In en, this message translates to:
  /// **'Today {time} focused · {left, plural, =0{long break next} =1{one more for a long break} other{{left} more for a long break}}'**
  String focusTodayRound(String time, int left);

  /// No description provided for @startBreak.
  ///
  /// In en, this message translates to:
  /// **'Start {minutes}-min break'**
  String startBreak(int minutes);

  /// No description provided for @skipBreak.
  ///
  /// In en, this message translates to:
  /// **'Skip break'**
  String get skipBreak;

  /// No description provided for @markTaskDone.
  ///
  /// In en, this message translates to:
  /// **'Mark task done'**
  String get markTaskDone;

  /// No description provided for @phaseBreakOver.
  ///
  /// In en, this message translates to:
  /// **'Break over'**
  String get phaseBreakOver;

  /// No description provided for @startFocusing.
  ///
  /// In en, this message translates to:
  /// **'Start focusing'**
  String get startFocusing;

  /// No description provided for @breakTip.
  ///
  /// In en, this message translates to:
  /// **'Stand up, refill your water and look at something far away.'**
  String get breakTip;

  /// No description provided for @defaultFocusLength.
  ///
  /// In en, this message translates to:
  /// **'Default focus length'**
  String get defaultFocusLength;

  /// No description provided for @preferencesSection.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferencesSection;

  /// No description provided for @calendarDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get calendarDay;

  /// No description provided for @calendarWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get calendarWeek;

  /// No description provided for @calendarMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calendarMonth;

  /// No description provided for @legendPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get legendPending;

  /// No description provided for @legendCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get legendCompleted;

  /// No description provided for @legendOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get legendOverdue;

  /// No description provided for @agendaHeader.
  ///
  /// In en, this message translates to:
  /// **'{date} · {relative}'**
  String agendaHeader(String date, String relative);

  /// No description provided for @nothingDue.
  ///
  /// In en, this message translates to:
  /// **'Nothing due. Tap + to plan this day'**
  String get nothingDue;

  /// No description provided for @anytime.
  ///
  /// In en, this message translates to:
  /// **'ANYTIME'**
  String get anytime;

  /// No description provided for @dueCounts.
  ///
  /// In en, this message translates to:
  /// **'{due} due{overdue, plural, =0{} other{ · {overdue} overdue}}'**
  String dueCounts(int due, int overdue);

  /// No description provided for @focusBlock.
  ///
  /// In en, this message translates to:
  /// **'Focus · {task}'**
  String focusBlock(String task);

  /// No description provided for @focusBlockNoTask.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focusBlockNoTask;

  /// No description provided for @focusSessions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session} other{{count} sessions}}'**
  String focusSessions(int count);

  /// No description provided for @timeRange.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String timeRange(String start, String end);

  /// No description provided for @nowLine.
  ///
  /// In en, this message translates to:
  /// **'Now, {time}'**
  String nowLine(String time);

  /// No description provided for @doneOn.
  ///
  /// In en, this message translates to:
  /// **'Done · {date}'**
  String doneOn(String date);

  /// No description provided for @filterSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter & sort'**
  String get filterSortTitle;

  /// No description provided for @filterSort.
  ///
  /// In en, this message translates to:
  /// **'Filter and sort'**
  String get filterSort;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'SORT BY'**
  String get sortBy;

  /// No description provided for @sortDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get sortDueDate;

  /// No description provided for @sortPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get sortPriority;

  /// No description provided for @sortProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get sortProject;

  /// No description provided for @sortAdded.
  ///
  /// In en, this message translates to:
  /// **'Date added'**
  String get sortAdded;

  /// No description provided for @projectsSection.
  ///
  /// In en, this message translates to:
  /// **'PROJECTS'**
  String get projectsSection;

  /// No description provided for @showCompleted.
  ///
  /// In en, this message translates to:
  /// **'Show completed tasks'**
  String get showCompleted;

  /// No description provided for @showTasks.
  ///
  /// In en, this message translates to:
  /// **'Show {count, plural, =1{1 task} other{{count} tasks}}'**
  String showTasks(int count);

  /// No description provided for @sectionCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get sectionCompleted;

  /// No description provided for @sectionByAdded.
  ///
  /// In en, this message translates to:
  /// **'NEWEST FIRST'**
  String get sectionByAdded;

  /// No description provided for @sectionInbox.
  ///
  /// In en, this message translates to:
  /// **'INBOX'**
  String get sectionInbox;

  /// No description provided for @filtersOn.
  ///
  /// In en, this message translates to:
  /// **'Filter and sort, filters on'**
  String get filtersOn;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search tasks, projects and tags'**
  String get searchHint;

  /// No description provided for @tasksSection.
  ///
  /// In en, this message translates to:
  /// **'TASKS'**
  String get tasksSection;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'RECENT SEARCHES'**
  String get recentSearches;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @noteMatches.
  ///
  /// In en, this message translates to:
  /// **'Note matches “{snippet}”'**
  String noteMatches(String snippet);

  /// No description provided for @noMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches for “{query}”'**
  String noMatchesTitle(String query);

  /// No description provided for @noMatchesBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing in your tasks, projects or tags. Check the spelling or try a shorter word.'**
  String get noMatchesBody;

  /// No description provided for @didYouMean.
  ///
  /// In en, this message translates to:
  /// **'Did you mean {word}?'**
  String didYouMean(String word);

  /// No description provided for @createTaskNamed.
  ///
  /// In en, this message translates to:
  /// **'Create task “{title}”'**
  String createTaskNamed(String title);

  /// No description provided for @searchTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchTypeAll;

  /// No description provided for @searchTypeTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get searchTypeTasks;

  /// No description provided for @searchTypeProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get searchTypeProjects;

  /// No description provided for @searchTypeDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get searchTypeDone;

  /// No description provided for @repeatTitle.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatTitle;

  /// No description provided for @repeatNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get repeatNever;

  /// No description provided for @repeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get repeatDaily;

  /// No description provided for @repeatWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get repeatWeekdays;

  /// No description provided for @repeatWeekdaysDetail.
  ///
  /// In en, this message translates to:
  /// **'Monday to Friday'**
  String get repeatWeekdaysDetail;

  /// No description provided for @repeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get repeatWeekly;

  /// No description provided for @repeatWeeklyDetail.
  ///
  /// In en, this message translates to:
  /// **'Pick the days below'**
  String get repeatWeeklyDetail;

  /// No description provided for @repeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get repeatMonthly;

  /// No description provided for @repeatMonthlyDetail.
  ///
  /// In en, this message translates to:
  /// **'On the {day}'**
  String repeatMonthlyDetail(String day);

  /// No description provided for @repeatCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get repeatCustom;

  /// No description provided for @repeatCustomDetail.
  ///
  /// In en, this message translates to:
  /// **'Every few days, weeks or months'**
  String get repeatCustomDetail;

  /// No description provided for @ordinalDay.
  ///
  /// In en, this message translates to:
  /// **'{day, select, 1{1st} 2{2nd} 3{3rd} 21{21st} 22{22nd} 23{23rd} 31{31st} other{{day}th}}'**
  String ordinalDay(String day);

  /// No description provided for @onTheseDays.
  ///
  /// In en, this message translates to:
  /// **'ON THESE DAYS'**
  String get onTheseDays;

  /// No description provided for @every.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get every;

  /// No description provided for @ends.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get ends;

  /// No description provided for @removeEndDate.
  ///
  /// In en, this message translates to:
  /// **'Remove end date'**
  String get removeEndDate;

  /// No description provided for @summaryWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get summaryWeekdays;

  /// No description provided for @summaryWeekly.
  ///
  /// In en, this message translates to:
  /// **'Every {days}'**
  String summaryWeekly(String days);

  /// No description provided for @summaryMonthly.
  ///
  /// In en, this message translates to:
  /// **'Every month on the {day}'**
  String summaryMonthly(String day);

  /// No description provided for @summaryEveryDays.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Every day} other{Every {n} days}}'**
  String summaryEveryDays(int n);

  /// No description provided for @summaryEveryWeeks.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Every week} other{Every {n} weeks}}'**
  String summaryEveryWeeks(int n);

  /// No description provided for @summaryEveryMonths.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Every month} other{Every {n} months}}'**
  String summaryEveryMonths(int n);

  /// No description provided for @summaryUntil.
  ///
  /// In en, this message translates to:
  /// **'{rule} until {date}'**
  String summaryUntil(String rule, String date);

  /// No description provided for @repeatButtonNever.
  ///
  /// In en, this message translates to:
  /// **'Don\'t repeat'**
  String get repeatButtonNever;

  /// No description provided for @repeatButtonDaily.
  ///
  /// In en, this message translates to:
  /// **'Repeat every day'**
  String get repeatButtonDaily;

  /// No description provided for @repeatButtonWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Repeat on weekdays'**
  String get repeatButtonWeekdays;

  /// No description provided for @repeatButtonWeekly.
  ///
  /// In en, this message translates to:
  /// **'Repeat every {days}'**
  String repeatButtonWeekly(String days);

  /// No description provided for @repeatButtonMonthly.
  ///
  /// In en, this message translates to:
  /// **'Repeat every month on the {day}'**
  String repeatButtonMonthly(String day);

  /// No description provided for @repeatButtonDays.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Repeat every day} other{Repeat every {n} days}}'**
  String repeatButtonDays(int n);

  /// No description provided for @repeatButtonWeeks.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Repeat every week} other{Repeat every {n} weeks}}'**
  String repeatButtonWeeks(int n);

  /// No description provided for @repeatButtonMonths.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Repeat every month} other{Repeat every {n} months}}'**
  String repeatButtonMonths(int n);

  /// No description provided for @moreDetails.
  ///
  /// In en, this message translates to:
  /// **'MORE DETAILS'**
  String get moreDetails;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **' · optional'**
  String get optional;

  /// No description provided for @repeatUnitDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get repeatUnitDays;

  /// No description provided for @repeatUnitWeeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get repeatUnitWeeks;

  /// No description provided for @repeatUnitMonths.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get repeatUnitMonths;

  /// No description provided for @tagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsTitle;

  /// No description provided for @searchOrCreateTag.
  ///
  /// In en, this message translates to:
  /// **'Search or create a tag'**
  String get searchOrCreateTag;

  /// No description provided for @tapToRemove.
  ///
  /// In en, this message translates to:
  /// **'Tap to remove'**
  String get tapToRemove;

  /// No description provided for @createTag.
  ///
  /// In en, this message translates to:
  /// **'Create tag “#{name}”'**
  String createTag(String name);

  /// No description provided for @saveTags.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Save without tags} =1{Save 1 tag} other{Save {count} tags}}'**
  String saveTags(int count);

  /// No description provided for @addTagChip.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get addTagChip;

  /// No description provided for @searchTagsCount.
  ///
  /// In en, this message translates to:
  /// **'Search {count, plural, =1{1 tag} other{{count} tags}}'**
  String searchTagsCount(int count);

  /// No description provided for @mostUsed.
  ///
  /// In en, this message translates to:
  /// **'MOST USED'**
  String get mostUsed;

  /// No description provided for @addShort.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addShort;

  /// No description provided for @tagsNote.
  ///
  /// In en, this message translates to:
  /// **'Tap a tag here to rename, merge or delete it.'**
  String get tagsNote;

  /// No description provided for @tagTaskCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task} other{{count} tasks}}'**
  String tagTaskCount(int count);

  /// No description provided for @showTaggedTasks.
  ///
  /// In en, this message translates to:
  /// **'Show tasks'**
  String get showTaggedTasks;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @deleteTag.
  ///
  /// In en, this message translates to:
  /// **'Delete tag'**
  String get deleteTag;

  /// No description provided for @newTag.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get newTag;

  /// No description provided for @renameTag.
  ///
  /// In en, this message translates to:
  /// **'Rename tag'**
  String get renameTag;

  /// No description provided for @tagNameHint.
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get tagNameHint;

  /// No description provided for @createTagButton.
  ///
  /// In en, this message translates to:
  /// **'Create tag'**
  String get createTagButton;

  /// No description provided for @mergeTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Merge #{from} into #{into}?'**
  String mergeTagTitle(String from, String into);

  /// No description provided for @mergeTagBody.
  ///
  /// In en, this message translates to:
  /// **'Tasks tagged #{from} will be tagged #{into} instead. This can\'t be undone.'**
  String mergeTagBody(String from, String into);

  /// No description provided for @mergeTag.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get mergeTag;

  /// No description provided for @deleteTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete #{name}?'**
  String deleteTagTitle(String name);

  /// No description provided for @deleteTagBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No tasks use it.} =1{It comes off 1 task.} other{It comes off {count} tasks.}} This can\'t be undone.'**
  String deleteTagBody(int count);

  /// No description provided for @tagNameTaken.
  ///
  /// In en, this message translates to:
  /// **'You already have #{name}'**
  String tagNameTaken(String name);

  /// No description provided for @noTagsYet.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get noTagsYet;

  /// No description provided for @notifyPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Your plan for today'**
  String get notifyPlanTitle;

  /// No description provided for @notifyPlanBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task} other{{count} tasks}} due · first: {title}'**
  String notifyPlanBody(int count, String title);

  /// No description provided for @notifyOverdueBody.
  ///
  /// In en, this message translates to:
  /// **'Open ctrlTask to catch up on what slipped.'**
  String get notifyOverdueBody;

  /// No description provided for @notifyWeeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly review'**
  String get notifyWeeklyTitle;

  /// No description provided for @notifyWeeklyBody.
  ///
  /// In en, this message translates to:
  /// **'See how your week went and plan the next one.'**
  String get notifyWeeklyBody;

  /// No description provided for @notifySessionBody.
  ///
  /// In en, this message translates to:
  /// **'Nice focus. Time for a break.'**
  String get notifySessionBody;

  /// No description provided for @notifyBreakOverBody.
  ///
  /// In en, this message translates to:
  /// **'Ready for the next session?'**
  String get notifyBreakOverBody;

  /// No description provided for @notifyDue.
  ///
  /// In en, this message translates to:
  /// **'{when}'**
  String notifyDue(String when);

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminderTitle;

  /// No description provided for @reminderOption.
  ///
  /// In en, this message translates to:
  /// **'{offset, select, none{No reminder} atTime{At due time} min10{10 minutes before} min30{30 minutes before} hour1{1 hour before} morningOf{Morning of} other{Day before}}'**
  String reminderOption(String offset);

  /// No description provided for @reminderShort.
  ///
  /// In en, this message translates to:
  /// **'{offset, select, none{None} atTime{At due time} min10{10 min before} min30{30 min before} hour1{1 hour before} morningOf{Morning of} other{Day before}}'**
  String reminderShort(String offset);

  /// No description provided for @reminderNote.
  ///
  /// In en, this message translates to:
  /// **'Due {due}. You\'ll be reminded {when}.'**
  String reminderNote(String due, String when);

  /// No description provided for @reminderNoteNone.
  ///
  /// In en, this message translates to:
  /// **'Due {due}. No reminder.'**
  String reminderNoteNone(String due);

  /// No description provided for @reminderNoteNoDate.
  ///
  /// In en, this message translates to:
  /// **'Set a due date to get a reminder.'**
  String get reminderNoteNoDate;

  /// No description provided for @remindedAt.
  ///
  /// In en, this message translates to:
  /// **'at {time}'**
  String remindedAt(String time);

  /// No description provided for @remindedOn.
  ///
  /// In en, this message translates to:
  /// **'on {day} at {time}'**
  String remindedOn(String day, String time);

  /// No description provided for @needsDueTime.
  ///
  /// In en, this message translates to:
  /// **'Needs a due time'**
  String get needsDueTime;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notifyRemindersDetail.
  ///
  /// In en, this message translates to:
  /// **'At the time set on each task'**
  String get notifyRemindersDetail;

  /// No description provided for @notifyPlanDetail.
  ///
  /// In en, this message translates to:
  /// **'What\'s due today, each morning'**
  String get notifyPlanDetail;

  /// No description provided for @notifyOverdueDetail.
  ///
  /// In en, this message translates to:
  /// **'6:00 PM, if anything slipped'**
  String get notifyOverdueDetail;

  /// No description provided for @focusSessionEnd.
  ///
  /// In en, this message translates to:
  /// **'Focus session end'**
  String get focusSessionEnd;

  /// No description provided for @notifyFocusDetail.
  ///
  /// In en, this message translates to:
  /// **'Soft bell when a session or break ends'**
  String get notifyFocusDetail;

  /// No description provided for @weeklyReview.
  ///
  /// In en, this message translates to:
  /// **'Weekly review'**
  String get weeklyReview;

  /// No description provided for @notifyWeeklyDetail.
  ///
  /// In en, this message translates to:
  /// **'Sunday 8:00 PM, your week in numbers'**
  String get notifyWeeklyDetail;

  /// No description provided for @timingSection.
  ///
  /// In en, this message translates to:
  /// **'TIMING'**
  String get timingSection;

  /// No description provided for @dailyPlanAtRow.
  ///
  /// In en, this message translates to:
  /// **'Daily plan at'**
  String get dailyPlanAtRow;

  /// No description provided for @defaultTaskReminder.
  ///
  /// In en, this message translates to:
  /// **'Default task reminder'**
  String get defaultTaskReminder;

  /// No description provided for @quietHours.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get quietHours;

  /// No description provided for @timeSpan.
  ///
  /// In en, this message translates to:
  /// **'{from} – {to}'**
  String timeSpan(String from, String to);

  /// No description provided for @quietFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get quietFrom;

  /// No description provided for @quietTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get quietTo;

  /// No description provided for @notificationsOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for ctrlTask'**
  String get notificationsOffTitle;

  /// No description provided for @notificationsOffBody.
  ///
  /// In en, this message translates to:
  /// **'Your choices below are saved. Turn notifications on so they can reach you.'**
  String get notificationsOffBody;

  /// No description provided for @notificationsNotAsked.
  ///
  /// In en, this message translates to:
  /// **'ctrlTask hasn\'t asked to send notifications yet.'**
  String get notificationsNotAsked;

  /// No description provided for @openPhoneSettings.
  ///
  /// In en, this message translates to:
  /// **'Open phone settings'**
  String get openPhoneSettings;

  /// No description provided for @turnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get turnOn;

  /// No description provided for @notificationsOnCount.
  ///
  /// In en, this message translates to:
  /// **'{count} on'**
  String notificationsOnCount(int count);

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @themeName.
  ///
  /// In en, this message translates to:
  /// **'{theme, select, light{Light} dark{Dark} other{System}}'**
  String themeName(String theme);

  /// No description provided for @themeNote.
  ///
  /// In en, this message translates to:
  /// **'System follows your phone\'s setting and switches automatically at night.'**
  String get themeNote;

  /// No description provided for @weekStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get weekStartTitle;

  /// No description provided for @weekStartName.
  ///
  /// In en, this message translates to:
  /// **'{day, select, sun{Sunday} sat{Saturday} other{Monday}}'**
  String weekStartName(String day);

  /// No description provided for @weekStartMonDetail.
  ///
  /// In en, this message translates to:
  /// **'Common in Malaysia and Europe'**
  String get weekStartMonDetail;

  /// No description provided for @weekStartSunDetail.
  ///
  /// In en, this message translates to:
  /// **'Common in the US'**
  String get weekStartSunDetail;

  /// No description provided for @weekStartNote.
  ///
  /// In en, this message translates to:
  /// **'Changes the calendar grid, “This week” in Tasks and your weekly insights.'**
  String get weekStartNote;

  /// No description provided for @defaultPriorityTitle.
  ///
  /// In en, this message translates to:
  /// **'Default priority'**
  String get defaultPriorityTitle;

  /// No description provided for @priorityUrgentDetail.
  ///
  /// In en, this message translates to:
  /// **'Red ring, always shows a tag'**
  String get priorityUrgentDetail;

  /// No description provided for @priorityHighDetail.
  ///
  /// In en, this message translates to:
  /// **'Orange ring, shows a tag'**
  String get priorityHighDetail;

  /// No description provided for @priorityMediumDetail.
  ///
  /// In en, this message translates to:
  /// **'Blue ring'**
  String get priorityMediumDetail;

  /// No description provided for @priorityLowDetail.
  ///
  /// In en, this message translates to:
  /// **'Plain ring'**
  String get priorityLowDetail;

  /// No description provided for @defaultPriorityNote.
  ///
  /// In en, this message translates to:
  /// **'New tasks start at this priority. You can change it in quick add with one tap.'**
  String get defaultPriorityNote;

  /// No description provided for @rangeLast7.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get rangeLast7;

  /// No description provided for @rangeThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get rangeThisMonth;

  /// No description provided for @completionRateLabel.
  ///
  /// In en, this message translates to:
  /// **'COMPLETION RATE'**
  String get completionRateLabel;

  /// No description provided for @completionRateSemantics.
  ///
  /// In en, this message translates to:
  /// **'Completion rate {rate}'**
  String completionRateSemantics(String rate);

  /// No description provided for @rateChangeWeek.
  ///
  /// In en, this message translates to:
  /// **'{points} pts vs previous 7 days'**
  String rateChangeWeek(String points);

  /// No description provided for @rateChangeMonth.
  ///
  /// In en, this message translates to:
  /// **'{points} pts vs same days last month'**
  String rateChangeMonth(String points);

  /// No description provided for @rateNoCompare.
  ///
  /// In en, this message translates to:
  /// **'Nothing was due before to compare'**
  String get rateNoCompare;

  /// No description provided for @rateNothingDue.
  ///
  /// In en, this message translates to:
  /// **'No tasks were due'**
  String get rateNothingDue;

  /// No description provided for @statCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get statCompleted;

  /// No description provided for @statFocus.
  ///
  /// In en, this message translates to:
  /// **'FOCUS'**
  String get statFocus;

  /// No description provided for @completedSemantics.
  ///
  /// In en, this message translates to:
  /// **'Completed, {count}'**
  String completedSemantics(int count);

  /// No description provided for @focusSemantics.
  ///
  /// In en, this message translates to:
  /// **'Focus, {duration}'**
  String focusSemantics(String duration);

  /// No description provided for @tasksCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'TASKS COMPLETED'**
  String get tasksCompletedLabel;

  /// No description provided for @tasksCompletedName.
  ///
  /// In en, this message translates to:
  /// **'Tasks completed'**
  String get tasksCompletedName;

  /// No description provided for @bestLabel.
  ///
  /// In en, this message translates to:
  /// **'Best:'**
  String get bestLabel;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'{day}, {count}'**
  String bestValue(String day, int count);

  /// No description provided for @focusTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'FOCUS TIME'**
  String get focusTimeLabel;

  /// No description provided for @focusTimeName.
  ///
  /// In en, this message translates to:
  /// **'Focus time'**
  String get focusTimeName;

  /// No description provided for @dailyAvgLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily avg'**
  String get dailyAvgLabel;

  /// No description provided for @trendLabel.
  ///
  /// In en, this message translates to:
  /// **'6-WEEK TREND'**
  String get trendLabel;

  /// No description provided for @trendName.
  ///
  /// In en, this message translates to:
  /// **'6-week trend'**
  String get trendName;

  /// No description provided for @trendPoints.
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String trendPoints(int points);

  /// No description provided for @trendThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week · {rate}'**
  String trendThisWeek(String rate);

  /// No description provided for @trendWeekSemantics.
  ///
  /// In en, this message translates to:
  /// **'week of {date} {rate}'**
  String trendWeekSemantics(String date, String rate);

  /// No description provided for @chartSemantics.
  ///
  /// In en, this message translates to:
  /// **'{chart}: {values}'**
  String chartSemantics(String chart, String values);

  /// No description provided for @chartValue.
  ///
  /// In en, this message translates to:
  /// **'{label} {value}'**
  String chartValue(String label, String value);

  /// No description provided for @powerDayTitle.
  ///
  /// In en, this message translates to:
  /// **'{weekday} is your power day'**
  String powerDayTitle(String weekday);

  /// No description provided for @powerDayBody.
  ///
  /// In en, this message translates to:
  /// **'You finish {average} tasks on average, mostly {beforeNoon, select, true{before noon} other{after noon}}.'**
  String powerDayBody(String average, String beforeNoon);

  /// No description provided for @notEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet'**
  String get notEnoughData;

  /// No description provided for @exportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportTitle;

  /// No description provided for @formatSection.
  ///
  /// In en, this message translates to:
  /// **'FORMAT'**
  String get formatSection;

  /// No description provided for @rangeSection.
  ///
  /// In en, this message translates to:
  /// **'RANGE'**
  String get rangeSection;

  /// No description provided for @includeSection.
  ///
  /// In en, this message translates to:
  /// **'INCLUDE'**
  String get includeSection;

  /// No description provided for @rangeAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get rangeAllTime;

  /// No description provided for @rangeThisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get rangeThisYear;

  /// No description provided for @rangeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get rangeCustom;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// No description provided for @includeCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed tasks'**
  String get includeCompleted;

  /// No description provided for @includeFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus sessions'**
  String get includeFocus;

  /// No description provided for @projectCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 project} other{{count} projects}}'**
  String projectCount(int count);

  /// No description provided for @focusSessionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 focus session} other{{count} focus sessions}}'**
  String focusSessionCount(int count);

  /// No description provided for @exportButton.
  ///
  /// In en, this message translates to:
  /// **'Export {format} · {size}'**
  String exportButton(String format, String size);

  /// No description provided for @sizeKb.
  ///
  /// In en, this message translates to:
  /// **'{size} KB'**
  String sizeKb(String size);

  /// No description provided for @sizeMb.
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String sizeMb(String size);

  /// No description provided for @exportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'CSV or JSON'**
  String get exportSubtitle;
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
