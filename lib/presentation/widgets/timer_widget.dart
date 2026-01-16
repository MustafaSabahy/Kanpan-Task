import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../bloc/timer/timer_bloc.dart';
import '../bloc/timer/timer_state.dart';
import '../bloc/timer/timer_event.dart';
import '../bloc/task/task_bloc.dart';
import '../bloc/task/task_event.dart';
import '../../core/constants/app_constants.dart';

class TimerWidget extends StatefulWidget {
  final String taskId;
  final bool isTaskDone; // Whether task is in Done column

  const TimerWidget({
    super.key,
    required this.taskId,
    this.isTaskDone = false,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _startUpdateTimer();
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, timerState) {
        final isActive = timerState.isActive && timerState.taskId == widget.taskId;
        
        // Calculate current displayed time
        Duration currentDuration;
        if (isActive) {
          // Timer is running: totalTrackedTime + (now - startTime)
          currentDuration = timerState.currentDuration;
        } else {
          // Timer not running: get from storage
          // Use FutureBuilder to get async time
          return FutureBuilder<Duration>(
            future: context.read<TimerBloc>().getCurrentTime(widget.taskId),
            builder: (context, snapshot) {
              currentDuration = snapshot.data ?? Duration.zero;
              return _buildTimerUI(context, timerState, isActive, currentDuration);
            },
          );
        }

        return _buildTimerUI(context, timerState, isActive, currentDuration);
      },
    );
  }

  Widget _buildTimerUI(
    BuildContext context,
    TimerState timerState,
    bool isActive,
    Duration currentDuration,
  ) {
    // Timers are disabled for Done tasks
    final isDisabled = widget.isTaskDone;

    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: isDisabled 
              ? theme.colorScheme.outline.withOpacity(0.5) 
              : theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 20,
                color: isDisabled 
                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                    : theme.colorScheme.primary,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Time Tracker',
                style: theme.textTheme.titleMedium?.copyWith(
                      color: isDisabled 
                          ? theme.colorScheme.onSurface.withOpacity(0.5)
                          : null,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          // Total time spent
          Center(
            child: Column(
              children: [
                Text(
                  DateFormatter.formatDuration(currentDuration),
                  style: theme.textTheme.displaySmall?.copyWith(
                        color: isDisabled 
                            ? theme.colorScheme.onSurface.withOpacity(0.5)
                            : theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (isActive) ...[
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Timer running...',
                    style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                  ),
                ] else if (currentDuration > Duration.zero && !isDisabled) ...[
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Total time spent',
                    style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                ],
                if (isDisabled) ...[
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Timer disabled for completed tasks',
                    style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Center(
            child: ElevatedButton.icon(
              onPressed: isDisabled
                  ? null
                  : (isActive
                      ? () {
                          context.read<TimerBloc>().add(const StopTimerEvent());
                        }
                      : () {
                          // Move task to In Progress when starting timer
                          context.read<TaskBloc>().add(
                                MoveTaskEvent(
                                  taskId: widget.taskId,
                                  newColumn: AppConstants.columnInProgress,
                                ),
                              );
                          // Start timer
                          context.read<TimerBloc>().add(StartTimerEvent(widget.taskId));
                        }),
              icon: Icon(isActive ? Icons.stop : Icons.play_arrow),
              label: Text(isActive ? 'Stop Timer' : 'Start Timer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDisabled
                    ? theme.colorScheme.outline.withOpacity(0.3)
                    : (isActive ? theme.colorScheme.error : theme.colorScheme.primary),
                foregroundColor: isDisabled 
                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                    : Colors.white,
                disabledBackgroundColor: theme.colorScheme.outline.withOpacity(0.3),
                disabledForegroundColor: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
