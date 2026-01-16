import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Time Tracking App'**
  String get appTitle;

  /// Board tab label
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get board;

  /// History tab label
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Statistics tab label
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// To Do column name
  ///
  /// In en, this message translates to:
  /// **'To Do'**
  String get toDo;

  /// In Progress column name
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// Done column name
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// New task button label
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get newTask;

  /// Create task dialog title
  ///
  /// In en, this message translates to:
  /// **'Create New Task'**
  String get createNewTask;

  /// Task title field label
  ///
  /// In en, this message translates to:
  /// **'Task Title'**
  String get taskTitle;

  /// Task title placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter task title'**
  String get enterTaskTitle;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Description placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter task description'**
  String get enterTaskDescription;

  /// Create button
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Edit task dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// Delete task option
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get deleteTask;

  /// Refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Enable dark mode option
  ///
  /// In en, this message translates to:
  /// **'Enable Dark Mode'**
  String get enableDarkMode;

  /// Disable dark mode option
  ///
  /// In en, this message translates to:
  /// **'Disable Dark Mode'**
  String get disableDarkMode;

  /// Clear all tasks option
  ///
  /// In en, this message translates to:
  /// **'Clear All Tasks'**
  String get clearAllTasks;

  /// Clear tasks from column option
  ///
  /// In en, this message translates to:
  /// **'Clear Tasks from Column'**
  String get clearTasksFromColumn;

  /// Confirmation message for clearing all tasks
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all tasks? This action cannot be undone.'**
  String get areYouSureDeleteAll;

  /// Clear all button
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// Time tracker widget title
  ///
  /// In en, this message translates to:
  /// **'Time Tracker'**
  String get timeTracker;

  /// Timer running indicator
  ///
  /// In en, this message translates to:
  /// **'Timer running...'**
  String get timerRunning;

  /// Total time spent label
  ///
  /// In en, this message translates to:
  /// **'Total time spent'**
  String get totalTimeSpent;

  /// Start timer button
  ///
  /// In en, this message translates to:
  /// **'Start Timer'**
  String get startTimer;

  /// Stop timer button
  ///
  /// In en, this message translates to:
  /// **'Stop Timer'**
  String get stopTimer;

  /// Timer disabled message
  ///
  /// In en, this message translates to:
  /// **'Timer disabled for completed tasks'**
  String get timerDisabledForCompleted;

  /// Comments section title
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// Add comment placeholder
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get addComment;

  /// No comments message
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noCommentsYet;

  /// Empty column message
  ///
  /// In en, this message translates to:
  /// **'Drop task here'**
  String get dropTaskHere;

  /// No tracked time message
  ///
  /// In en, this message translates to:
  /// **'No tracked time yet'**
  String get noTrackedTimeYet;

  /// Start tracking time message
  ///
  /// In en, this message translates to:
  /// **'Start tracking time on tasks to see statistics'**
  String get startTrackingTime;

  /// Overall summary section title
  ///
  /// In en, this message translates to:
  /// **'Overall Summary'**
  String get overallSummary;

  /// Total time label
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTime;

  /// Session completed reason
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Average per task label
  ///
  /// In en, this message translates to:
  /// **'Avg per Task'**
  String get avgPerTask;

  /// Sessions label
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// Time by status section title
  ///
  /// In en, this message translates to:
  /// **'Time by Status'**
  String get timeByStatus;

  /// Time by task section title
  ///
  /// In en, this message translates to:
  /// **'Time by Task'**
  String get timeByTask;

  /// Time over time section title
  ///
  /// In en, this message translates to:
  /// **'Time Over Time'**
  String get timeOverTime;

  /// Filters section title
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Date range filter label
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// All dates option
  ///
  /// In en, this message translates to:
  /// **'All dates'**
  String get allDates;

  /// Task filter label
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get task;

  /// All tasks option
  ///
  /// In en, this message translates to:
  /// **'All tasks'**
  String get allTasks;

  /// Status filter label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// All statuses option
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get allStatuses;

  /// Select task dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Task'**
  String get selectTask;

  /// Select status dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Status'**
  String get selectStatus;

  /// No data matches filters message
  ///
  /// In en, this message translates to:
  /// **'No data matches your filters'**
  String get noDataMatchesFilters;

  /// Try adjusting filters message
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters to see statistics'**
  String get tryAdjustingFilters;

  /// No time tracked message
  ///
  /// In en, this message translates to:
  /// **'No time tracked yet'**
  String get noTimeTrackedYet;

  /// No tasks with tracked time message
  ///
  /// In en, this message translates to:
  /// **'No tasks with tracked time'**
  String get noTasksWithTrackedTime;

  /// No time data available message
  ///
  /// In en, this message translates to:
  /// **'No time data available'**
  String get noTimeDataAvailable;

  /// Time history section title
  ///
  /// In en, this message translates to:
  /// **'Time History'**
  String get timeHistory;

  /// Number of sessions
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session} other{{count} sessions}}'**
  String session(int count);

  /// No time history message
  ///
  /// In en, this message translates to:
  /// **'No time history yet'**
  String get noTimeHistoryYet;

  /// Session started reason
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get started;

  /// Session paused reason
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// Session moved to todo reason
  ///
  /// In en, this message translates to:
  /// **'Moved to Todo'**
  String get movedToTodo;

  /// Session reopened reason
  ///
  /// In en, this message translates to:
  /// **'Reopened'**
  String get reopened;

  /// Session resumed reason
  ///
  /// In en, this message translates to:
  /// **'Resumed after restart'**
  String get resumedAfterRestart;

  /// Session app closed reason
  ///
  /// In en, this message translates to:
  /// **'App closed'**
  String get appClosed;

  /// Session label
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get sessionLabel;

  /// Error loading tasks message
  ///
  /// In en, this message translates to:
  /// **'Error loading tasks'**
  String get errorLoadingTasks;

  /// Error loading history message
  ///
  /// In en, this message translates to:
  /// **'Error loading history'**
  String get errorLoadingHistory;

  /// Error loading statistics message
  ///
  /// In en, this message translates to:
  /// **'Error loading statistics'**
  String get errorLoadingStatistics;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No completed tasks message
  ///
  /// In en, this message translates to:
  /// **'No completed tasks yet'**
  String get noCompletedTasksYet;

  /// Complete tasks message
  ///
  /// In en, this message translates to:
  /// **'Complete tasks to see them here'**
  String get completeTasksToSee;

  /// Time spent label
  ///
  /// In en, this message translates to:
  /// **'Time Spent: '**
  String get timeSpent;

  /// Search tasks placeholder
  ///
  /// In en, this message translates to:
  /// **'Search tasks...'**
  String get searchTasks;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Select language dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// German language name
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// Arabic language name
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;
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
      <String>['ar', 'de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
