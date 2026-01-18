import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/time_tracking_repository.dart';
import '../../data/repositories/comment_repository.dart';
import '../../data/repositories/offline_queue_repository.dart';
import '../../core/services/sync_service.dart';
import 'task/task_bloc.dart';
import 'task/task_event.dart';
import 'timer/timer_bloc.dart';
import 'timer/timer_event.dart';
import 'comment/comment_bloc.dart';

class BlocProviders {
  // Shared repositories
  static final _offlineQueue = OfflineQueueRepository();
  static final _taskRepository = TaskRepository();
  static final _commentRepository = CommentRepository();
  static final _syncService = SyncService(
    offlineQueue: _offlineQueue,
    taskRepository: _taskRepository,
    commentRepository: _commentRepository,
  );

  static List<BlocProvider> get providers => [
        // Create TimerBloc first (it doesn't depend on TaskBloc)
        BlocProvider<TimerBloc>(
          create: (context) {
            final timerBloc = TimerBloc(
              repository: TimeTrackingRepository(),
            );
            // Resume timers on app start
            timerBloc.add(const ResumeTimersEvent());
            return timerBloc;
          },
        ),
        // Create TaskBloc with TimerBloc reference and offline support
        BlocProvider<TaskBloc>(
          create: (context) {
            final timerBloc = context.read<TimerBloc>();
            return TaskBloc(
              taskRepository: _taskRepository,
              timeTrackingRepository: TimeTrackingRepository(),
              offlineQueue: _offlineQueue,
              syncService: _syncService,
              timerBloc: timerBloc,
            )..add(const LoadTasksEvent());
          },
        ),
      ];

  static BlocProvider<CommentBloc> commentBlocProvider(String taskId) {
    return BlocProvider<CommentBloc>(
      create: (context) => CommentBloc(
        repository: _commentRepository,
        offlineQueue: _offlineQueue,
        taskId: taskId,
      ),
    );
  }
}
