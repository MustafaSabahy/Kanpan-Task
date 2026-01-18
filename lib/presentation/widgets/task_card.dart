import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/timer/timer_bloc.dart';
import '../bloc/timer/timer_state.dart';
import '../bloc/task/task_bloc.dart';
import '../bloc/task/task_event.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? currentColumn;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onLongPress,
    this.currentColumn,
  });

  @override
  Widget build(BuildContext context) {
    // Use BlocSelector to only rebuild when timer state changes for THIS specific task
    // This prevents unnecessary rebuilds when other tasks' timers tick
    return BlocSelector<TimerBloc, TimerState, _TaskTimerData>(
      selector: (state) {
        final isTimerActive = state.isActive && state.taskId == task.task.id;
        final currentTime = isTimerActive 
            ? state.currentDuration 
            : task.getCurrentTime();
        
        return _TaskTimerData(
          isTimerActive: isTimerActive,
          currentTime: currentTime,
        );
      },
      builder: (context, timerData) {
        return RepaintBoundary(
          child: Draggable<TaskEntity>(
      data: task,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.25,
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            border: Border.all(
              color: AppTheme.primaryColor,
              width: 2,
            ),
          ),
          child: Text(
            task.task.content,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildCard(context, timerData.isTimerActive, timerData.currentTime),
      ),
      child: _buildCard(context, timerData.isTimerActive, timerData.currentTime),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, bool isTimerActive, Duration currentTime) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: isTimerActive
                ? AppTheme.primaryColor
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isTimerActive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.task.content,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                  ),
                ),
                if (isTimerActive)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.timer,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                const SizedBox(width: AppTheme.spacingS),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    context.read<TaskBloc>().add(DeleteTaskEvent(task.task.id));
                  },
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
            if (task.task.description != null) ...[
              const SizedBox(height: AppTheme.spacingS),
              Text(
                task.task.description!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppTheme.spacingS),
            Row(
              children: [
                // Timer display with nice styling
                if (currentTime > Duration.zero || isTimerActive) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isTimerActive
                          ? AppTheme.primaryColor.withOpacity(0.1)
                          : AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isTimerActive
                            ? AppTheme.primaryColor
                            : AppTheme.borderColor,
                        width: isTimerActive ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isTimerActive ? Icons.timer : Icons.access_time,
                          size: 14,
                          color: isTimerActive
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.formatDurationShort(currentTime),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isTimerActive
                                    ? AppTheme.primaryColor
                                    : AppTheme.textSecondary,
                                fontWeight: isTimerActive
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                        ),
                        if (isTimerActive) ...[
                          const SizedBox(width: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                ],
                if (task.task.commentCount > 0) ...[
                  Icon(
                    Icons.comment_outlined,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.task.commentCount}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class to hold timer data for BlocSelector
/// Prevents unnecessary rebuilds when timer ticks for other tasks
class _TaskTimerData {
  final bool isTimerActive;
  final Duration currentTime;

  const _TaskTimerData({
    required this.isTimerActive,
    required this.currentTime,
  });
}
