// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Zeiterfassungs-App';

  @override
  String get board => 'Board';

  @override
  String get history => 'Verlauf';

  @override
  String get statistics => 'Statistiken';

  @override
  String get toDo => 'Zu erledigen';

  @override
  String get inProgress => 'In Bearbeitung';

  @override
  String get done => 'Erledigt';

  @override
  String get newTask => 'Neue Aufgabe';

  @override
  String get createNewTask => 'Neue Aufgabe erstellen';

  @override
  String get taskTitle => 'Aufgabentitel';

  @override
  String get enterTaskTitle => 'Aufgabentitel eingeben';

  @override
  String get description => 'Beschreibung';

  @override
  String get enterTaskDescription => 'Aufgabenbeschreibung eingeben';

  @override
  String get create => 'Erstellen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get editTask => 'Aufgabe bearbeiten';

  @override
  String get deleteTask => 'Aufgabe löschen';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get enableDarkMode => 'Dunklen Modus aktivieren';

  @override
  String get disableDarkMode => 'Dunklen Modus deaktivieren';

  @override
  String get clearAllTasks => 'Alle Aufgaben löschen';

  @override
  String get clearTasksFromColumn => 'Aufgaben aus Spalte löschen';

  @override
  String get areYouSureDeleteAll =>
      'Möchten Sie wirklich alle Aufgaben löschen? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get clearAll => 'Alle löschen';

  @override
  String get timeTracker => 'Zeiterfassung';

  @override
  String get timerRunning => 'Timer läuft...';

  @override
  String get totalTimeSpent => 'Gesamte Zeit';

  @override
  String get startTimer => 'Timer starten';

  @override
  String get stopTimer => 'Timer stoppen';

  @override
  String get timerDisabledForCompleted =>
      'Timer für abgeschlossene Aufgaben deaktiviert';

  @override
  String get comments => 'Kommentare';

  @override
  String get addComment => 'Kommentar hinzufügen...';

  @override
  String get noCommentsYet => 'Noch keine Kommentare';

  @override
  String get dropTaskHere => 'Aufgabe hier ablegen';

  @override
  String get noTrackedTimeYet => 'Noch keine Zeit erfasst';

  @override
  String get startTrackingTime =>
      'Beginnen Sie mit der Zeiterfassung für Aufgaben, um Statistiken zu sehen';

  @override
  String get overallSummary => 'Gesamtübersicht';

  @override
  String get totalTime => 'Gesamtzeit';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get avgPerTask => 'Ø pro Aufgabe';

  @override
  String get sessions => 'Sitzungen';

  @override
  String get timeByStatus => 'Zeit nach Status';

  @override
  String get timeByTask => 'Zeit nach Aufgabe';

  @override
  String get timeOverTime => 'Zeit im Zeitverlauf';

  @override
  String get filters => 'Filter';

  @override
  String get dateRange => 'Datumsbereich';

  @override
  String get allDates => 'Alle Daten';

  @override
  String get task => 'Aufgabe';

  @override
  String get allTasks => 'Alle Aufgaben';

  @override
  String get status => 'Status';

  @override
  String get allStatuses => 'Alle Status';

  @override
  String get selectTask => 'Aufgabe auswählen';

  @override
  String get selectStatus => 'Status auswählen';

  @override
  String get noDataMatchesFilters => 'Keine Daten entsprechen Ihren Filtern';

  @override
  String get tryAdjustingFilters =>
      'Versuchen Sie, Ihre Filter anzupassen, um Statistiken zu sehen';

  @override
  String get noTimeTrackedYet => 'Noch keine Zeit erfasst';

  @override
  String get noTasksWithTrackedTime => 'Keine Aufgaben mit erfasster Zeit';

  @override
  String get noTimeDataAvailable => 'Keine Zeitdaten verfügbar';

  @override
  String get timeHistory => 'Zeitverlauf';

  @override
  String session(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sitzungen',
      one: '1 Sitzung',
    );
    return '$_temp0';
  }

  @override
  String get noTimeHistoryYet => 'Noch kein Zeitverlauf';

  @override
  String get started => 'Gestartet';

  @override
  String get paused => 'Pausiert';

  @override
  String get movedToTodo => 'Zu erledigen verschoben';

  @override
  String get reopened => 'Wiedereröffnet';

  @override
  String get resumedAfterRestart => 'Nach Neustart fortgesetzt';

  @override
  String get appClosed => 'App geschlossen';

  @override
  String get sessionLabel => 'Sitzung';

  @override
  String get errorLoadingTasks => 'Fehler beim Laden der Aufgaben';

  @override
  String get errorLoadingHistory => 'Fehler beim Laden des Verlaufs';

  @override
  String get errorLoadingStatistics => 'Fehler beim Laden der Statistiken';

  @override
  String get retry => 'Wiederholen';

  @override
  String get noCompletedTasksYet => 'Noch keine abgeschlossenen Aufgaben';

  @override
  String get completeTasksToSee =>
      'Schließen Sie Aufgaben ab, um sie hier zu sehen';

  @override
  String get timeSpent => 'Verbrachte Zeit: ';

  @override
  String get searchTasks => 'Aufgaben suchen...';

  @override
  String get language => 'Sprache';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get english => 'Englisch';

  @override
  String get german => 'Deutsch';

  @override
  String get arabic => 'Arabisch';
}
