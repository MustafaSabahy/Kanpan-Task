import '../../data/models/task_model.dart';
import '../../data/models/task_time_tracking.dart';
import '../../core/constants/app_constants.dart';

/// Domain entity representing a task with its state
class TaskEntity {
  final TaskModel task;
  final TaskTimeTracking? timeTracking;
  final String kanbanColumn;

  TaskEntity({
    required this.task,
    this.timeTracking,
    required this.kanbanColumn,
  });

  bool get isCompleted => task.isCompleted;
  bool get isInProgress => kanbanColumn == AppConstants.columnInProgress;
  bool get isTodo => kanbanColumn == AppConstants.columnTodo;
  bool get isDone => kanbanColumn == AppConstants.columnDone;

  /// Get current displayed time
  /// Returns totalTrackedTime + elapsed if running, otherwise totalTrackedTime
  Duration getCurrentTime() {
    if (timeTracking == null) return Duration.zero;
    return timeTracking!.getCurrentTime();
  }

  /// Legacy support
  @Deprecated('Use getCurrentTime() instead')
  Duration get totalTimeSpent => getCurrentTime();

  /// Check if task has an active timer (isRunning and startTime set)
  bool get hasActiveTimer {
    if (timeTracking == null) return false;
    return timeTracking!.isRunning && timeTracking!.startTime != null;
  }

  /// Check if task is completed (Done) - timers are disabled
  bool get isTimerDisabled => isDone;

  TaskEntity copyWith({
    TaskModel? task,
    TaskTimeTracking? timeTracking,
    String? kanbanColumn,
  }) {
    return TaskEntity(
      task: task ?? this.task,
      timeTracking: timeTracking ?? this.timeTracking,
      kanbanColumn: kanbanColumn ?? this.kanbanColumn,
    );
  }
}
