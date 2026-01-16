import 'package:json_annotation/json_annotation.dart';

part 'task_time_tracking.g.dart';

/// Model for tracking time spent on tasks (stored locally)
/// Follows business logic: time calculated on-the-fly while running, saved only when stopped
@JsonSerializable()
class TaskTimeTracking {
  final String taskId;
  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  final Duration totalTrackedTime; // Saved time (only updated when stopped)
  final DateTime? startTime; // Only set while running, otherwise null
  final bool isRunning; // Whether timer is currently running
  final List<TimeSession> sessions; // Historical sessions (for reference)
  final DateTime? completedAt;
  final String? lastColumn; // Last known column state (Todo, In Progress, Done)

  TaskTimeTracking({
    required this.taskId,
    required this.totalTrackedTime,
    this.startTime,
    this.isRunning = false,
    required this.sessions,
    this.completedAt,
    this.lastColumn,
  });

  // Legacy support: totalDuration maps to totalTrackedTime
  @Deprecated('Use totalTrackedTime instead')
  Duration get totalDuration => totalTrackedTime;

  factory TaskTimeTracking.fromJson(Map<String, dynamic> json) =>
      _$TaskTimeTrackingFromJson(json);

  Map<String, dynamic> toJson() => _$TaskTimeTrackingToJson(this);

  TaskTimeTracking copyWith({
    String? taskId,
    Duration? totalTrackedTime,
    DateTime? startTime,
    bool? isRunning,
    List<TimeSession>? sessions,
    DateTime? completedAt,
    String? lastColumn,
  }) {
    return TaskTimeTracking(
      taskId: taskId ?? this.taskId,
      totalTrackedTime: totalTrackedTime ?? this.totalTrackedTime,
      startTime: startTime,
      isRunning: isRunning ?? this.isRunning,
      sessions: sessions ?? this.sessions,
      completedAt: completedAt ?? this.completedAt,
      lastColumn: lastColumn ?? this.lastColumn,
    );
  }

  /// Calculate current displayed time (totalTrackedTime + elapsed if running)
  Duration getCurrentTime() {
    if (isRunning && startTime != null) {
      return totalTrackedTime + DateTime.now().difference(startTime!);
    }
    return totalTrackedTime;
  }
  
  /// Calculate total tracked time from all closed sessions
  /// This ensures totalTrackedTime = sum of all session durations
  Duration calculateTotalFromSessions() {
    return sessions
        .where((s) => s.isClosed)
        .fold<Duration>(
          Duration.zero,
          (sum, session) => sum + session.duration,
        );
  }
  
  /// Get all closed history sessions (immutable)
  List<TimeSession> getHistorySessions() {
    return sessions.where((s) => s.isClosed).toList();
  }
  
  /// Get active session (if any)
  TimeSession? getActiveSession() {
    try {
      return sessions.firstWhere((s) => s.isActive);
    } catch (e) {
      return null;
    }
  }
}

@JsonSerializable()
class TimeSession {
  final DateTime startTime;
  final DateTime? endTime;
  final String? statusChangeReason; // start, pause, moved, done, reopened

  TimeSession({
    required this.startTime,
    this.endTime,
    this.statusChangeReason,
  });

  /// Calculate duration - immutable once closed
  Duration get duration {
    if (endTime == null) {
      // Active session: calculate from current time
      return DateTime.now().difference(startTime);
    }
    // Closed session: return stored duration (immutable)
    return endTime!.difference(startTime);
  }

  /// Check if session is active (not closed)
  bool get isActive => endTime == null;
  
  /// Check if session is closed (immutable)
  bool get isClosed => endTime != null;

  /// Create a closed copy of this session (for immutability)
  TimeSession closeSession(DateTime endTime, {String? reason}) {
    if (this.endTime != null) {
      // Already closed, return as-is (immutable)
      return this;
    }
    return TimeSession(
      startTime: startTime,
      endTime: endTime,
      statusChangeReason: reason ?? statusChangeReason,
    );
  }

  factory TimeSession.fromJson(Map<String, dynamic> json) =>
      _$TimeSessionFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSessionToJson(this);
}

// Helper functions for Duration serialization
Duration _durationFromJson(int milliseconds) =>
    Duration(milliseconds: milliseconds);

int _durationToJson(Duration duration) => duration.inMilliseconds;
