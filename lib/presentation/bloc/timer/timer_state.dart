import 'package:equatable/equatable.dart';

/// TimerState following business logic:
/// - totalTrackedTime: saved time (only updated when stopped)
/// - startTime: only set while running
/// - currentDuration calculated on-the-fly: totalTrackedTime + (now - startTime)
class TimerState extends Equatable {
  final String? taskId;
  final DateTime? startTime;
  final Duration totalTrackedTime; // Saved time (not updated while running)

  const TimerState({
    this.taskId,
    this.startTime,
    this.totalTrackedTime = Duration.zero,
  });

  bool get isActive => taskId != null && startTime != null;
  
  /// Calculate current displayed time on-the-fly
  /// totalTrackedTime + elapsed time since startTime
  Duration get currentDuration {
    if (startTime != null) {
      return totalTrackedTime + DateTime.now().difference(startTime!);
    }
    return totalTrackedTime;
  }

  TimerState copyWith({
    String? taskId,
    DateTime? startTime,
    Duration? totalTrackedTime,
  }) {
    return TimerState(
      taskId: taskId ?? this.taskId,
      startTime: startTime ?? this.startTime,
      totalTrackedTime: totalTrackedTime ?? this.totalTrackedTime,
    );
  }

  @override
  List<Object?> get props => [taskId, startTime, totalTrackedTime];
}
