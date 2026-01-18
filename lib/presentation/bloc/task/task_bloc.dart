import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../data/repositories/time_tracking_repository.dart';
import '../../../data/repositories/offline_queue_repository.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/task_time_tracking.dart';
import '../../../data/models/offline_task.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/sync_service.dart';
import '../timer/timer_bloc.dart';
import '../timer/timer_event.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  final TimeTrackingRepository _timeTrackingRepository;
  final OfflineQueueRepository _offlineQueue;
  final SyncService? _syncService;
  final TimerBloc? _timerBloc;
  final NotificationService _notificationService = NotificationService();
  final _uuid = const Uuid();

  TaskBloc({
    required TaskRepository taskRepository,
    required TimeTrackingRepository timeTrackingRepository,
    required OfflineQueueRepository offlineQueue,
    SyncService? syncService,
    TimerBloc? timerBloc,
  })  : _taskRepository = taskRepository,
        _timeTrackingRepository = timeTrackingRepository,
        _offlineQueue = offlineQueue,
        _syncService = syncService,
        _timerBloc = timerBloc,
        super(const TaskInitial()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<MoveTaskEvent>(_onMoveTask);
    on<ClearAllTasksEvent>(_onClearAllTasks);
    on<ClearTasksFromColumnEvent>(_onClearTasksFromColumn);
    on<SyncOfflineDataEvent>(_onSyncOfflineData);
    
    // Initialize notification service
    _notificationService.initialize();
    
    // Try to sync offline data on startup
    _trySyncOnStartup();
  }

  Future<void> _trySyncOnStartup() async {
    if (await ConnectivityService.hasConnectionWithTimeout()) {
      add(const SyncOfflineDataEvent());
    }
  }

  Future<void> _onLoadTasks(
    LoadTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    
    // Check connectivity first
    final hasConnection = await ConnectivityService.hasConnectionWithTimeout();
    
    if (!hasConnection) {
      // Offline mode: Load from local storage only
      await _loadTasksFromLocal(emit);
      return;
    }
    
    try {
      final tasks = await _taskRepository.getTasks();
      final timeTrackings = await _timeTrackingRepository.getAllTimeTrackings();
      final timeTrackingMap = {
        for (var tt in timeTrackings) tt.taskId: tt
      };
      
      // Get task IDs from API response
      final apiTaskIds = tasks.map((t) => t.id).toSet();
      
      // Find time tracking entries for tasks that are marked as Done but not in API response
      // (completed tasks are filtered out by Todoist API)
      final doneTaskIds = timeTrackings
          .where((tt) => tt.lastColumn == AppConstants.columnDone && 
                        !apiTaskIds.contains(tt.taskId))
          .map((tt) => tt.taskId)
          .toList();
      
      // Try to fetch completed tasks individually (only if online)
      final completedTasks = <TaskModel>[];
      for (final taskId in doneTaskIds) {
        try {
          final task = await _taskRepository.getTask(taskId);
          completedTasks.add(task);
        } catch (e) {
          // Task might have been deleted, skip it
        }
      }
      
      // Combine API tasks with completed tasks
      final allTasks = [...tasks, ...completedTasks];

      final taskEntities = allTasks.map((task) {
        final timeTracking = timeTrackingMap[task.id];
        final column = _determineColumn(task, timeTracking);
        return TaskEntity(
          task: task,
          timeTracking: timeTracking,
          kanbanColumn: column,
        );
      }).toList();

      emit(TaskLoaded(taskEntities));
    } catch (e) {
      // If API fails, try to load from local storage
      await _loadTasksFromLocal(emit);
    }
  }

  /// Load tasks from local storage (offline mode)
  Future<void> _loadTasksFromLocal(Emitter<TaskState> emit) async {
    try {
      final timeTrackings = await _timeTrackingRepository.getAllTimeTrackings();
      final offlineTasks = await _offlineQueue.getOfflineTasks();
      
      // Create task entities from offline tasks and time tracking
      final taskEntities = <TaskEntity>[];
      
      // Add tasks from time tracking (these are tasks that were previously loaded)
      for (final tracking in timeTrackings) {
        // Check if this is an offline task (starts with 'offline_')
        if (tracking.taskId.startsWith('offline_')) {
          // This is an offline task - find it in offline queue
          final offlineTaskId = tracking.taskId.replaceFirst('offline_', '');
          final offlineTaskList = offlineTasks.where((ot) => ot.id == offlineTaskId).toList();
          final offlineTask = offlineTaskList.isNotEmpty ? offlineTaskList.first : null;
          
          if (offlineTask != null) {
            // Create a mock TaskModel for offline tasks
            final mockTask = TaskModel(
              id: tracking.taskId,
              projectId: 'offline',
              content: offlineTask.content,
              description: offlineTask.description,
              isCompleted: false,
              order: 0,
              priority: offlineTask.priority ?? 1,
              commentCount: 0,
            );
            
            taskEntities.add(TaskEntity(
              task: mockTask,
              timeTracking: tracking,
              kanbanColumn: tracking.lastColumn ?? AppConstants.columnTodo,
            ));
          }
        }
      }
      
      // If no tasks found, show empty state
      if (taskEntities.isEmpty) {
        emit(TaskLoaded([]));
      } else {
        emit(TaskLoaded(taskEntities));
      }
    } catch (e) {
      // Show empty list instead of error in offline mode
      emit(TaskLoaded([]));
    }
  }

  String _determineColumn(TaskModel task, TaskTimeTracking? timeTracking) {
    if (task.isCompleted) {
      return AppConstants.columnDone;
    }
    // Use lastColumn if available, otherwise infer from timer state
    if (timeTracking?.lastColumn != null) {
      return timeTracking!.lastColumn!;
    }
    // If task has a running timer, it's in progress
    if (timeTracking != null && 
        (timeTracking.isRunning || timeTracking.startTime != null)) {
      return AppConstants.columnInProgress;
    }
    return AppConstants.columnTodo;
  }

  Future<void> _onCreateTask(
    CreateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    final hasConnection = await ConnectivityService.hasConnectionWithTimeout();
    
    if (hasConnection) {
      // Try to create task online
      try {
        final task = await _taskRepository.createTask(
          content: event.content,
          description: event.description,
          priority: event.priority,
        );
        // Initialize time tracking with Todo column
        final initialTracking = TaskTimeTracking(
          taskId: task.id,
          totalTrackedTime: Duration.zero,
          startTime: null,
          isRunning: false,
          sessions: [],
          lastColumn: AppConstants.columnTodo,
        );
        await _timeTrackingRepository.saveTimeTracking(initialTracking);
        
        // Schedule notification if task has a due date
        await _scheduleNotificationIfNeeded(task);
        
        add(const LoadTasksEvent());
      } catch (e) {
        // If online creation fails, save to offline queue
        await _saveTaskToOfflineQueue(event);
        add(const LoadTasksEvent());
      }
    } else {
      // No connection - save to offline queue
      await _saveTaskToOfflineQueue(event);
      add(const LoadTasksEvent());
    }
  }

  Future<void> _saveTaskToOfflineQueue(CreateTaskEvent event) async {
    final offlineTask = OfflineTask(
      id: _uuid.v4(),
      content: event.content,
      description: event.description,
      priority: event.priority,
      createdAt: DateTime.now(),
      action: 'create',
    );
    await _offlineQueue.addOfflineTask(offlineTask);
    
    // Create a local task ID for time tracking
    final localTaskId = 'offline_${offlineTask.id}';
    final initialTracking = TaskTimeTracking(
      taskId: localTaskId,
      totalTrackedTime: Duration.zero,
      startTime: null,
      isRunning: false,
      sessions: [],
      lastColumn: AppConstants.columnTodo,
    );
    await _timeTrackingRepository.saveTimeTracking(initialTracking);
  }

  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    final hasConnection = await ConnectivityService.hasConnectionWithTimeout();
    
    if (hasConnection) {
      try {
        final updatedTask = await _taskRepository.updateTask(
          event.id,
          content: event.content,
          description: event.description,
          priority: event.priority,
        );
        
        // Update notification if due date changed
        if (updatedTask != null) {
          await _scheduleNotificationIfNeeded(updatedTask);
        }
        
        add(const LoadTasksEvent());
      } catch (e) {
        // If online update fails, save to offline queue
        await _saveUpdateToOfflineQueue(event);
        add(const LoadTasksEvent());
      }
    } else {
      // No connection - save to offline queue
      await _saveUpdateToOfflineQueue(event);
      add(const LoadTasksEvent());
    }
  }

  Future<void> _saveUpdateToOfflineQueue(UpdateTaskEvent event) async {
    final offlineTask = OfflineTask(
      id: _uuid.v4(),
      content: event.content ?? '',
      description: event.description,
      priority: event.priority,
      createdAt: DateTime.now(),
      action: 'update',
      originalTaskId: event.id,
    );
    await _offlineQueue.addOfflineTask(offlineTask);
  }

  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    final hasConnection = await ConnectivityService.hasConnectionWithTimeout();
    
    if (hasConnection) {
      try {
        await _taskRepository.deleteTask(event.id);
        await _timeTrackingRepository.deleteTimeTracking(event.id);
        
        // Cancel notification for deleted task
        await _notificationService.cancelTaskNotificationByTaskId(event.id);
        
        add(const LoadTasksEvent());
      } catch (e) {
        // If online delete fails, save to offline queue
        await _saveDeleteToOfflineQueue(event);
        // Still delete locally for better UX
        await _timeTrackingRepository.deleteTimeTracking(event.id);
        await _notificationService.cancelTaskNotificationByTaskId(event.id);
        add(const LoadTasksEvent());
      }
    } else {
      // No connection - save to offline queue
      await _saveDeleteToOfflineQueue(event);
      // Still delete locally for better UX
      await _timeTrackingRepository.deleteTimeTracking(event.id);
      await _notificationService.cancelTaskNotificationByTaskId(event.id);
      add(const LoadTasksEvent());
    }
  }

  Future<void> _saveDeleteToOfflineQueue(DeleteTaskEvent event) async {
    final offlineTask = OfflineTask(
      id: _uuid.v4(),
      content: '', // Not needed for delete
      createdAt: DateTime.now(),
      action: 'delete',
      originalTaskId: event.id,
    );
    await _offlineQueue.addOfflineTask(offlineTask);
  }

  Future<void> _onMoveTask(
    MoveTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TaskLoaded) return;

    final task = currentState.tasks.firstWhere(
      (t) => t.task.id == event.taskId,
      orElse: () => throw Exception('Task not found'),
    );
    final oldColumn = task.kanbanColumn;

    // Optimistically update UI
    final updatedTasks = currentState.tasks.map((t) {
      if (t.task.id == event.taskId) {
        return t.copyWith(kanbanColumn: event.newColumn);
      }
      return t;
    }).toList();
    emit(TaskLoaded(updatedTasks));

    try {
      // Handle timer logic based on column movement
      if (_timerBloc != null) {
        // Moving from In Progress → Todo: Stop timer and save time
        if (oldColumn == AppConstants.columnInProgress && 
            event.newColumn == AppConstants.columnTodo) {
          // Stop timer and save time (preserves accumulated time)
          await _timerBloc!.stopAndSave(event.taskId);
          // Update lastColumn
          var tracking = await _timeTrackingRepository.getTimeTracking(event.taskId);
          if (tracking != null) {
            await _timeTrackingRepository.saveTimeTracking(
              tracking.copyWith(lastColumn: event.newColumn),
            );
          }
        }
        
        // Moving to In Progress: Auto-start timer (unless coming from Done, handled above)
        if (event.newColumn == AppConstants.columnInProgress && 
            oldColumn != AppConstants.columnDone) {
          // Get current tracking
          var tracking = await _timeTrackingRepository.getTimeTracking(event.taskId);
          if (tracking == null) {
            // No previous time, start from 0
            tracking = TaskTimeTracking(
              taskId: event.taskId,
              totalTrackedTime: Duration.zero,
              startTime: null,
              isRunning: false,
              sessions: [],
            );
          }
          
          // Resume timer from saved total (or start from 0)
          // Stop any other running timer first
          if (_timerBloc!.state.isActive && 
              _timerBloc!.state.taskId != event.taskId) {
            await _timerBloc!.stopAndSave(_timerBloc!.state.taskId!);
          }
          
          // Start timer for this task
          _timerBloc!.add(StartTimerEvent(event.taskId));
          // Update lastColumn
          var trackingAfter = await _timeTrackingRepository.getTimeTracking(event.taskId);
          if (trackingAfter != null) {
            await _timeTrackingRepository.saveTimeTracking(
              trackingAfter.copyWith(lastColumn: event.newColumn),
            );
          }
        }
        
        // Moving to Done: Stop timer permanently and preserve time
        if (event.newColumn == AppConstants.columnDone) {
          // If already in Done, do nothing (idempotent)
          if (oldColumn == AppConstants.columnDone) {
            // Already done, no action needed
            await _taskRepository.closeTask(event.taskId); // Ensure it's closed
          // Cancel notification if still scheduled
          await _notificationService.cancelTaskNotificationByTaskId(event.taskId);
            add(const LoadTasksEvent());
            return;
          }
          
          // If moving from In Progress → Done: Stop timer and save time
          if (oldColumn == AppConstants.columnInProgress) {
            await _timerBloc!.stopAndSaveForCompletion(event.taskId);
          }
          // If moving from Todo → Done: Do NOT start timer, time remains 0
          // (No timer action needed, just close the task)
          
          await _taskRepository.closeTask(event.taskId);
          // Cancel notification for completed task
          await _notificationService.cancelTaskNotificationByTaskId(event.taskId);
          
          // Update lastColumn
          var tracking = await _timeTrackingRepository.getTimeTracking(event.taskId);
          if (tracking != null) {
            await _timeTrackingRepository.saveTimeTracking(
              tracking.copyWith(lastColumn: event.newColumn),
            );
          }
        }
        
        // Moving from Done → Todo: Keep time unchanged, timer stays stopped
        if (oldColumn == AppConstants.columnDone && 
            event.newColumn == AppConstants.columnTodo) {
          // Time is preserved, timer remains stopped
          // Update lastColumn
          var tracking = await _timeTrackingRepository.getTimeTracking(event.taskId);
          if (tracking != null) {
            await _timeTrackingRepository.saveTimeTracking(
              tracking.copyWith(lastColumn: event.newColumn),
            );
          }
        }
        
        // Moving from Done → In Progress: Resume timer from saved total
        if (oldColumn == AppConstants.columnDone && 
            event.newColumn == AppConstants.columnInProgress) {
          await _taskRepository.reopenTask(event.taskId);
          
          // Get current tracking (time is preserved)
          var tracking = await _timeTrackingRepository.getTimeTracking(event.taskId);
          if (tracking == null) {
            // Shouldn't happen, but create if missing
            tracking = TaskTimeTracking(
              taskId: event.taskId,
              totalTrackedTime: Duration.zero,
              startTime: null,
              isRunning: false,
              sessions: [],
            );
          }
          
          // Resume timer from previously saved totalTrackedTime
          // Stop any other running timer first
          if (_timerBloc!.state.isActive && 
              _timerBloc!.state.taskId != event.taskId) {
            await _timerBloc!.stopAndSave(_timerBloc!.state.taskId!);
          }
          
          // Start timer for this task (resumes from saved total)
          _timerBloc!.add(StartTimerEvent(event.taskId));
          // Update lastColumn
          var trackingAfter = await _timeTrackingRepository.getTimeTracking(event.taskId);
          if (trackingAfter != null) {
            await _timeTrackingRepository.saveTimeTracking(
              trackingAfter.copyWith(lastColumn: event.newColumn),
            );
          }
        }
      } else {
        // No timer bloc, just handle task state
        if (event.newColumn == AppConstants.columnDone) {
          await _taskRepository.closeTask(event.taskId);
        } else if (event.newColumn == AppConstants.columnInProgress && task.isDone) {
          await _taskRepository.reopenTask(event.taskId);
        }
      }
      
      add(const LoadTasksEvent());
    } catch (e) {
      add(const LoadTasksEvent()); // Reload on error
    }
  }

  Future<void> _onClearAllTasks(
    ClearAllTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TaskLoaded) return;

    try {
      // Delete all tasks
      for (final task in currentState.tasks) {
        await _taskRepository.deleteTask(task.task.id);
        await _timeTrackingRepository.deleteTimeTracking(task.task.id);
        // Cancel notification
        await _notificationService.cancelTaskNotificationByTaskId(task.task.id);
      }
      add(const LoadTasksEvent());
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onClearTasksFromColumn(
    ClearTasksFromColumnEvent event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TaskLoaded) return;

    try {
      // If clearing In Progress, stop all running timers first
      if (event.column == AppConstants.columnInProgress && _timerBloc != null) {
        await _timerBloc!.stopAllRunningTimers();
      }

      // Delete all tasks from the specified column
      final tasksToDelete = currentState.tasks
          .where((task) => task.kanbanColumn == event.column)
          .toList();

      for (final task in tasksToDelete) {
        await _taskRepository.deleteTask(task.task.id);
        await _timeTrackingRepository.deleteTimeTracking(task.task.id);
        // Cancel notification
        await _notificationService.cancelTaskNotificationByTaskId(task.task.id);
      }
      add(const LoadTasksEvent());
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  /// Schedule notification if task has a due date
  Future<void> _scheduleNotificationIfNeeded(TaskModel task) async {
    if (task.due?.datetime != null) {
      try {
        // Parse the datetime string (format: "2024-01-15T10:00:00" or with timezone)
        final dateTimeStr = task.due!.datetime!;
        DateTime scheduledTime;
        
        if (dateTimeStr.contains('T')) {
          // ISO 8601 format
          scheduledTime = DateTime.parse(dateTimeStr);
        } else {
          // Date only format, use date + default time (9 AM)
          final dateOnly = DateTime.parse(dateTimeStr);
          scheduledTime = DateTime(
            dateOnly.year,
            dateOnly.month,
            dateOnly.day,
            9, // 9 AM
          );
        }
        
        // Only schedule if time is in the future
        if (scheduledTime.isAfter(DateTime.now())) {
          await _notificationService.scheduleTaskNotification(
            taskId: task.id,
            title: task.content,
            description: task.description,
            scheduledTime: scheduledTime,
          );
        }
      } catch (e) {
        // If parsing fails, skip notification scheduling
        // This is not critical, so we don't throw
      }
    } else if (task.due?.date != null) {
      // Date only (no time specified)
      try {
        final dateOnly = DateTime.parse(task.due!.date!);
        final scheduledTime = DateTime(
          dateOnly.year,
          dateOnly.month,
          dateOnly.day,
          9, // Default to 9 AM
        );
        
        if (scheduledTime.isAfter(DateTime.now())) {
          await _notificationService.scheduleTaskNotification(
            taskId: task.id,
            title: task.content,
            description: task.description,
            scheduledTime: scheduledTime,
          );
        }
      } catch (e) {
        // If parsing fails, skip notification scheduling
      }
    }
  }

  Future<void> _onSyncOfflineData(
    SyncOfflineDataEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (_syncService == null) return;
    
    try {
      final result = await _syncService!.syncAll();
      if (result.success) {
        // Reload tasks after successful sync
        add(const LoadTasksEvent());
      }
    } catch (e) {
      // Silently fail - sync will retry later
    }
  }
}
