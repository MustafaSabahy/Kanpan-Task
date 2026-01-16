// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Time Tracking App';

  @override
  String get board => 'Board';

  @override
  String get history => 'History';

  @override
  String get statistics => 'Statistics';

  @override
  String get toDo => 'To Do';

  @override
  String get inProgress => 'In Progress';

  @override
  String get done => 'Done';

  @override
  String get newTask => 'New Task';

  @override
  String get createNewTask => 'Create New Task';

  @override
  String get taskTitle => 'Task Title';

  @override
  String get enterTaskTitle => 'Enter task title';

  @override
  String get description => 'Description';

  @override
  String get enterTaskDescription => 'Enter task description';

  @override
  String get create => 'Create';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get editTask => 'Edit Task';

  @override
  String get deleteTask => 'Delete Task';

  @override
  String get refresh => 'Refresh';

  @override
  String get enableDarkMode => 'Enable Dark Mode';

  @override
  String get disableDarkMode => 'Disable Dark Mode';

  @override
  String get clearAllTasks => 'Clear All Tasks';

  @override
  String get clearTasksFromColumn => 'Clear Tasks from Column';

  @override
  String get areYouSureDeleteAll =>
      'Are you sure you want to delete all tasks? This action cannot be undone.';

  @override
  String get clearAll => 'Clear All';

  @override
  String get timeTracker => 'Time Tracker';

  @override
  String get timerRunning => 'Timer running...';

  @override
  String get totalTimeSpent => 'Total time spent';

  @override
  String get startTimer => 'Start Timer';

  @override
  String get stopTimer => 'Stop Timer';

  @override
  String get timerDisabledForCompleted => 'Timer disabled for completed tasks';

  @override
  String get comments => 'Comments';

  @override
  String get addComment => 'Add a comment...';

  @override
  String get noCommentsYet => 'No comments yet';

  @override
  String get dropTaskHere => 'Drop task here';

  @override
  String get noTrackedTimeYet => 'No tracked time yet';

  @override
  String get startTrackingTime =>
      'Start tracking time on tasks to see statistics';

  @override
  String get overallSummary => 'Overall Summary';

  @override
  String get totalTime => 'Total Time';

  @override
  String get completed => 'Completed';

  @override
  String get avgPerTask => 'Avg per Task';

  @override
  String get sessions => 'Sessions';

  @override
  String get timeByStatus => 'Time by Status';

  @override
  String get timeByTask => 'Time by Task';

  @override
  String get timeOverTime => 'Time Over Time';

  @override
  String get filters => 'Filters';

  @override
  String get dateRange => 'Date Range';

  @override
  String get allDates => 'All dates';

  @override
  String get task => 'Task';

  @override
  String get allTasks => 'All tasks';

  @override
  String get status => 'Status';

  @override
  String get allStatuses => 'All statuses';

  @override
  String get selectTask => 'Select Task';

  @override
  String get selectStatus => 'Select Status';

  @override
  String get noDataMatchesFilters => 'No data matches your filters';

  @override
  String get tryAdjustingFilters =>
      'Try adjusting your filters to see statistics';

  @override
  String get noTimeTrackedYet => 'No time tracked yet';

  @override
  String get noTasksWithTrackedTime => 'No tasks with tracked time';

  @override
  String get noTimeDataAvailable => 'No time data available';

  @override
  String get timeHistory => 'Time History';

  @override
  String session(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
    );
    return '$_temp0';
  }

  @override
  String get noTimeHistoryYet => 'No time history yet';

  @override
  String get started => 'Started';

  @override
  String get paused => 'Paused';

  @override
  String get movedToTodo => 'Moved to Todo';

  @override
  String get reopened => 'Reopened';

  @override
  String get resumedAfterRestart => 'Resumed after restart';

  @override
  String get appClosed => 'App closed';

  @override
  String get sessionLabel => 'Session';

  @override
  String get errorLoadingTasks => 'Error loading tasks';

  @override
  String get errorLoadingHistory => 'Error loading history';

  @override
  String get errorLoadingStatistics => 'Error loading statistics';

  @override
  String get retry => 'Retry';

  @override
  String get noCompletedTasksYet => 'No completed tasks yet';

  @override
  String get completeTasksToSee => 'Complete tasks to see them here';

  @override
  String get timeSpent => 'Time Spent: ';

  @override
  String get searchTasks => 'Search tasks...';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get german => 'German';

  @override
  String get arabic => 'Arabic';
}
