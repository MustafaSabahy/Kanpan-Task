import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/time_tracking_repository.dart';
import '../../../data/models/task_time_tracking.dart';
import '../../../core/constants/app_constants.dart';
import 'timer_event.dart';
import 'timer_state.dart';

/// TimerBloc following exact business logic:
/// - Time calculated on-the-fly while running (not saved every second)
/// - Time only saved when stopped or completed
/// - Only one task can run at a time
/// - Timers resume automatically on app restart
class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final TimeTrackingRepository _repository;
  Timer? _tickTimer;
  
  // Callback to move task to In Progress (set by UI layer if needed)
  void Function(String taskId)? onMoveToInProgress;

  TimerBloc({
    required TimeTrackingRepository repository,
  })  : _repository = repository,
        super(const TimerState()) {
    on<StartTimerEvent>(_onStartTimer);
    on<StopTimerEvent>(_onStopTimer);
    on<TimerTickEvent>(_onTimerTick);
    on<ResumeTimersEvent>(_onResumeTimers);
    _startTickTimer();
  }

  /// Start periodic timer for UI updates (doesn't save time)
  /// Optimized: Only ticks when timer is active, reduces battery usage
  void _startTickTimer() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (state.isActive) {
          add(const TimerTickEvent());
        }
      },
    );
  }

  /// Resume timers on app restart
  /// Closes any active sessions that were running when app was killed
  Future<void> _onResumeTimers(
    ResumeTimersEvent event,
    Emitter<TimerState> emit,
  ) async {
    try {
      final allTrackings = await _repository.getAllTimeTrackings();
      final now = DateTime.now();
      
      // Find tasks that were running (In Progress with startTime)
      for (final tracking in allTrackings) {
        if (tracking.isRunning && 
            tracking.startTime != null &&
            tracking.completedAt == null) {
          
          // Close the previous session that was active when app was killed
          // Use 'now' as endTime since we don't know exactly when app was killed
          // This gives the user credit for time up to when they reopen the app
          final updatedSessions = tracking.sessions.map((session) {
            if (session.isActive && session.startTime == tracking.startTime) {
              // Close using current time (when app reopened)
              return session.closeSession(now, reason: 'app_killed');
            }
            return session;
          }).toList();
          
          // Calculate total from closed sessions
          final totalFromSessions = updatedSessions
              .where((s) => s.isClosed)
              .fold<Duration>(
                Duration.zero,
                (sum, session) => sum + session.duration,
              );
          
          // Create new session for the resumed timer
          final newSession = TimeSession(
            startTime: now,
            statusChangeReason: 'resumed',
          );
          final finalSessions = [...updatedSessions, newSession];
          
          // Update tracking
          final updatedTracking = tracking.copyWith(
            startTime: now, // New start time
            totalTrackedTime: totalFromSessions,
            sessions: finalSessions,
          );
          
          await _repository.saveTimeTracking(updatedTracking);
          
          // Resume this timer
          emit(TimerState(
            taskId: tracking.taskId,
            startTime: now,
            totalTrackedTime: totalFromSessions,
          ));
          break; // Only one timer can run at a time
        }
      }
    } catch (e) {
      // Silently fail - app can still work
    }
  }

  /// Start timer for a task
  /// Business logic:
  /// - If another task is running, stop it first and save its time
  /// - Move task to In Progress
  /// - Set startTime = now
  /// - Mark task as running
  Future<void> _onStartTimer(
    StartTimerEvent event,
    Emitter<TimerState> emit,
  ) async {
    // Check if task is Done - timers are disabled for Done tasks
    final currentTracking = await _repository.getTimeTracking(event.taskId);
    if (currentTracking?.completedAt != null) {
      return; // Cannot start timer for completed task
    }

    // If another task is running, stop it first
    if (state.isActive && state.taskId != event.taskId) {
      await _stopCurrentTimer(emit);
    }

    // If already running for this task, do nothing
    if (state.isActive && state.taskId == event.taskId) {
      return;
    }

    // Get or create tracking
    var tracking = await _repository.getTimeTracking(event.taskId);
    if (tracking == null) {
      tracking = TaskTimeTracking(
        taskId: event.taskId,
        totalTrackedTime: Duration.zero,
        startTime: null,
        isRunning: false,
        sessions: [],
      );
    }

    // Move task to In Progress if callback is set
    // (UI layer should handle this via TaskBloc)
    if (onMoveToInProgress != null) {
      onMoveToInProgress!(event.taskId);
    }

    // Start timer: set startTime = now, mark as running
    final now = DateTime.now();
    
    // Check if this is a reopen (Done → In Progress)
    final isReopen = tracking.completedAt != null;
    final reason = isReopen ? 'reopened' : 'start';
    
    // Create new history session
    final newSession = TimeSession(
      startTime: now,
      statusChangeReason: reason,
    );
    final updatedSessions = [...tracking.sessions, newSession];
    
    // Ensure totalTrackedTime = sum of all closed sessions
    final totalFromSessions = updatedSessions
        .where((s) => s.isClosed)
        .fold<Duration>(
          Duration.zero,
          (sum, session) => sum + session.duration,
        );
    
    final updatedTracking = tracking.copyWith(
      startTime: now,
      isRunning: true,
      sessions: updatedSessions,
      totalTrackedTime: totalFromSessions, // Recalculate from sessions
      completedAt: isReopen ? null : tracking.completedAt, // Clear completedAt on reopen
    );

    await _repository.saveTimeTracking(updatedTracking);

    emit(TimerState(
      taskId: event.taskId,
      startTime: now,
      totalTrackedTime: totalFromSessions,
    ));
  }

  /// Stop/pause timer
  /// Business logic:
  /// - Calculate elapsed = now - startTime
  /// - Close active history session
  /// - Update totalTrackedTime from all closed sessions
  /// - Clear startTime
  /// - Set isRunning = false
  /// - Task remains in In Progress
  Future<void> _onStopTimer(
    StopTimerEvent event,
    Emitter<TimerState> emit,
  ) async {
    await _stopCurrentTimer(emit, reason: 'pause');
  }

  /// Internal method to stop current timer
  /// Closes the active history session and updates totalTrackedTime
  Future<void> _stopCurrentTimer(Emitter<TimerState> emit, {String? reason}) async {
    if (!state.isActive) return;

    final taskId = state.taskId!;
    final startTime = state.startTime!;

    // Get current tracking
    var tracking = await _repository.getTimeTracking(taskId);
    if (tracking == null) {
      emit(const TimerState());
      return;
    }

    // Calculate elapsed time
    final now = DateTime.now();

    // Close the active history session (immutable once closed)
    final updatedSessions = tracking.sessions.map((session) {
      if (session.isActive && session.startTime == startTime) {
        return session.closeSession(now, reason: reason ?? 'pause');
      }
      return session; // Keep closed sessions as-is (immutable)
    }).toList();

    // Calculate totalTrackedTime from all closed sessions
    final newTotalTrackedTime = updatedSessions
        .where((s) => s.isClosed)
        .fold<Duration>(
          Duration.zero,
          (sum, session) => sum + session.duration,
        );

    // Save: clear startTime, set isRunning = false, update totalTrackedTime and sessions
    final updatedTracking = tracking.copyWith(
      totalTrackedTime: newTotalTrackedTime,
      startTime: null,
      isRunning: false,
      sessions: updatedSessions,
    );

    await _repository.saveTimeTracking(updatedTracking);

    emit(const TimerState());
  }

  /// Timer tick - just update UI, don't save anything
  void _onTimerTick(
    TimerTickEvent event,
    Emitter<TimerState> emit,
  ) {
    if (state.isActive) {
      // Just trigger rebuild - time is calculated on-the-fly
      emit(state.copyWith());
    }
  }

  /// Stop timer and save time (for Todo movement or completion)
  /// Preserves time, doesn't mark as completed
  /// Closes active history session with reason 'moved'
  Future<void> stopAndSave(String taskId) async {
    if (state.isActive && state.taskId == taskId) {
      final startTime = state.startTime!;
      final now = DateTime.now();

      var tracking = await _repository.getTimeTracking(taskId);
      if (tracking != null) {
        // Close active session
        final updatedSessions = tracking.sessions.map((session) {
          if (session.isActive && session.startTime == startTime) {
            return session.closeSession(now, reason: 'moved');
          }
          return session;
        }).toList();

        // Calculate total from all closed sessions
        final newTotalTrackedTime = updatedSessions
            .where((s) => s.isClosed)
            .fold<Duration>(
              Duration.zero,
              (sum, session) => sum + session.duration,
            );

        final updatedTracking = tracking.copyWith(
          totalTrackedTime: newTotalTrackedTime,
          startTime: null,
          isRunning: false,
          sessions: updatedSessions,
        );

        await _repository.saveTimeTracking(updatedTracking);
      }

      add(const StopTimerEvent());
    } else {
      // Task not running, check storage for active session
      var tracking = await _repository.getTimeTracking(taskId);
      if (tracking != null && tracking.isRunning && tracking.startTime != null) {
        final now = DateTime.now();
        final startTime = tracking.startTime!;

        // Close active session
        final updatedSessions = tracking.sessions.map((session) {
          if (session.isActive && session.startTime == startTime) {
            return session.closeSession(now, reason: 'moved');
          }
          return session;
        }).toList();

        // Calculate total from all closed sessions
        final newTotalTrackedTime = updatedSessions
            .where((s) => s.isClosed)
            .fold<Duration>(
              Duration.zero,
              (sum, session) => sum + session.duration,
            );

        final updatedTracking = tracking.copyWith(
          totalTrackedTime: newTotalTrackedTime,
          startTime: null,
          isRunning: false,
          sessions: updatedSessions,
        );
        await _repository.saveTimeTracking(updatedTracking);
      }
    }
  }

  /// Stop timer and save time when task is completed
  /// Called by TaskBloc when moving task to Done
  /// Closes active history session with reason 'done'
  Future<void> stopAndSaveForCompletion(String taskId) async {
    if (state.isActive && state.taskId == taskId) {
      final startTime = state.startTime!;
      final now = DateTime.now();

      var tracking = await _repository.getTimeTracking(taskId);
      if (tracking != null) {
        // Close active session with reason 'done'
        final updatedSessions = tracking.sessions.map((session) {
          if (session.isActive && session.startTime == startTime) {
            return session.closeSession(now, reason: 'done');
          }
          return session;
        }).toList();

        // Calculate total from all closed sessions
        final newTotalTrackedTime = updatedSessions
            .where((s) => s.isClosed)
            .fold<Duration>(
              Duration.zero,
              (sum, session) => sum + session.duration,
            );

        final updatedTracking = tracking.copyWith(
          totalTrackedTime: newTotalTrackedTime,
          startTime: null,
          isRunning: false,
          completedAt: now,
          sessions: updatedSessions,
        );

        await _repository.saveTimeTracking(updatedTracking);
      }

      add(const StopTimerEvent());
    } else {
      // Task not running, just mark as completed and close any active session
      var tracking = await _repository.getTimeTracking(taskId);
      if (tracking != null && tracking.completedAt == null) {
        final now = DateTime.now();
        
        // Close any active session
        final updatedSessions = tracking.sessions.map((session) {
          if (session.isActive) {
            return session.closeSession(now, reason: 'done');
          }
          return session;
        }).toList();

        // Recalculate total from closed sessions
        final newTotalTrackedTime = updatedSessions
            .where((s) => s.isClosed)
            .fold<Duration>(
              Duration.zero,
              (sum, session) => sum + session.duration,
            );

        final updatedTracking = tracking.copyWith(
          totalTrackedTime: newTotalTrackedTime,
          completedAt: now,
          isRunning: false,
          startTime: null,
          sessions: updatedSessions,
        );
        await _repository.saveTimeTracking(updatedTracking);
      }
    }
  }

  /// Stop all running timers (used when clearing In Progress column)
  Future<void> stopAllRunningTimers() async {
    if (state.isActive) {
      final taskId = state.taskId!;
      final startTime = state.startTime!;
      final now = DateTime.now();
      final elapsed = now.difference(startTime);

      var tracking = await _repository.getTimeTracking(taskId);
      if (tracking != null) {
        final newTotalTrackedTime = tracking.totalTrackedTime + elapsed;
        final updatedTracking = tracking.copyWith(
          totalTrackedTime: newTotalTrackedTime,
          startTime: null,
          isRunning: false,
        );
        await _repository.saveTimeTracking(updatedTracking);
      }
      
      add(const StopTimerEvent());
    }

    // Also check for any other running timers in storage
    final allTrackings = await _repository.getAllTimeTrackings();
    for (final tracking in allTrackings) {
      if (tracking.isRunning && tracking.startTime != null) {
        final now = DateTime.now();
        final elapsed = now.difference(tracking.startTime!);
        final newTotalTrackedTime = tracking.totalTrackedTime + elapsed;
        
        final updatedTracking = tracking.copyWith(
          totalTrackedTime: newTotalTrackedTime,
          startTime: null,
          isRunning: false,
        );
        await _repository.saveTimeTracking(updatedTracking);
      }
    }
  }

  /// Get current displayed time for a task
  /// Returns totalTrackedTime + elapsed if running
  Future<Duration> getCurrentTime(String taskId) async {
    final tracking = await _repository.getTimeTracking(taskId);
    if (tracking == null) return Duration.zero;

    if (state.isActive && state.taskId == taskId && state.startTime != null) {
      // Task is currently running
      return tracking.totalTrackedTime + 
             DateTime.now().difference(state.startTime!);
    }

    if (tracking.isRunning && tracking.startTime != null) {
      // Task was running but timer state not synced (app restart scenario)
      return tracking.totalTrackedTime + 
             DateTime.now().difference(tracking.startTime!);
    }

    return tracking.totalTrackedTime;
  }

  @override
  Future<void> close() {
    _tickTimer?.cancel();
    return super.close();
  }
}
