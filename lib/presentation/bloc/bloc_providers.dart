import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/time_tracking_repository.dart';
import '../../data/repositories/comment_repository.dart';
import 'task/task_bloc.dart';
import 'task/task_event.dart';
import 'timer/timer_bloc.dart';
import 'timer/timer_event.dart';
import 'comment/comment_bloc.dart';

class BlocProviders {
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
        // Create TaskBloc with TimerBloc reference
        BlocProvider<TaskBloc>(
          create: (context) {
            final timerBloc = context.read<TimerBloc>();
            return TaskBloc(
              taskRepository: TaskRepository(),
              timeTrackingRepository: TimeTrackingRepository(),
              timerBloc: timerBloc,
            )..add(const LoadTasksEvent());
          },
        ),
      ];

  static BlocProvider<CommentBloc> commentBlocProvider(String taskId) {
    return BlocProvider<CommentBloc>(
      create: (context) => CommentBloc(
        repository: CommentRepository(),
        taskId: taskId,
      ),
    );
  }
}
