import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task_time_tracking.dart';

/// Repository for time tracking operations (local storage)
class TimeTrackingRepository {
  static const String _keyPrefix = 'time_tracking_';

  Future<void> saveTimeTracking(TaskTimeTracking tracking) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${tracking.taskId}';
    final json = jsonEncode({
      'taskId': tracking.taskId,
      'totalTrackedTime': tracking.totalTrackedTime.inMilliseconds,
      'startTime': tracking.startTime?.toIso8601String(),
      'isRunning': tracking.isRunning,
      'sessions': tracking.sessions.map((s) => {
            'startTime': s.startTime.toIso8601String(),
            'endTime': s.endTime?.toIso8601String(),
            'statusChangeReason': s.statusChangeReason,
          }).toList(),
      'completedAt': tracking.completedAt?.toIso8601String(),
      'lastColumn': tracking.lastColumn,
    });
    await prefs.setString(key, json);
  }

  Future<TaskTimeTracking?> getTimeTracking(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$taskId';
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;

    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    
    // Handle legacy format (totalDuration) and new format (totalTrackedTime)
    final totalTime = json['totalTrackedTime'] as int? ?? 
                     json['totalDuration'] as int? ?? 0;
    
    return TaskTimeTracking(
      taskId: json['taskId'] as String,
      totalTrackedTime: Duration(milliseconds: totalTime),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      isRunning: json['isRunning'] as bool? ?? false,
      sessions: (json['sessions'] as List? ?? [])
          .map((s) => TimeSession(
                startTime: DateTime.parse(s['startTime'] as String),
                endTime: s['endTime'] != null
                    ? DateTime.parse(s['endTime'] as String)
                    : null,
                statusChangeReason: s['statusChangeReason'] as String?,
              ))
          .toList(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      lastColumn: json['lastColumn'] as String?,
    );
  }

  Future<List<TaskTimeTracking>> getAllTimeTrackings() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));
    final trackings = <TaskTimeTracking>[];

    for (final key in keys) {
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final totalTime = json['totalTrackedTime'] as int? ?? 
                         json['totalDuration'] as int? ?? 0;
        
        trackings.add(TaskTimeTracking(
          taskId: json['taskId'] as String,
          totalTrackedTime: Duration(milliseconds: totalTime),
          startTime: json['startTime'] != null
              ? DateTime.parse(json['startTime'] as String)
              : null,
          isRunning: json['isRunning'] as bool? ?? false,
          sessions: (json['sessions'] as List? ?? [])
              .map((s) => TimeSession(
                    startTime: DateTime.parse(s['startTime'] as String),
                    endTime: s['endTime'] != null
                        ? DateTime.parse(s['endTime'] as String)
                        : null,
                  ))
              .toList(),
          completedAt: json['completedAt'] != null
              ? DateTime.parse(json['completedAt'] as String)
              : null,
          lastColumn: json['lastColumn'] as String?,
        ));
      }
    }

    return trackings;
  }

  Future<void> deleteTimeTracking(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$taskId';
    await prefs.remove(key);
  }
}
