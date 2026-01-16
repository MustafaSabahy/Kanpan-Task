import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../gen/l10n/app_localizations.dart';
import 'package:task/domain/entities/task_entity.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../bloc/task/task_bloc.dart';
import '../bloc/task/task_state.dart';
import '../bloc/task/task_event.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TaskError) {
          // final l10n = AppLocalizations.of(context)!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Error loading history',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingL),
                ElevatedButton(
                  onPressed: () => context.read<TaskBloc>().add(const LoadTasksEvent()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is TaskLoaded) {
          final allTasks = state.tasks;
        // Filter completed tasks
        final completedTasks = allTasks.where((task) => task.isCompleted).toList();

        if (completedTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'No completed tasks yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'Complete tasks to see them here',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          );
        }

        // Sort by completion date (newest first)
        // We'll use the task's updated time or time tracking completion date
        completedTasks.sort((a, b) {
          final dateA = a.timeTracking?.completedAt ?? DateTime(0);
          final dateB = b.timeTracking?.completedAt ?? DateTime(0);
          return dateB.compareTo(dateA);
        });

          return RefreshIndicator(
            onRefresh: () {
              context.read<TaskBloc>().add(const LoadTasksEvent());
              return Future.value();
            },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            itemCount: completedTasks.length,
            itemBuilder: (context, index) {
              final task = completedTasks[index];
              return _HistoryCard(task: task);
            },
          ),
        );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final TaskEntity task;

  const _HistoryCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final timeTracking = task.timeTracking;
    final completedAt = timeTracking?.completedAt;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.doneColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.doneColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.task.content,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (completedAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        DateFormatter.formatDate(completedAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ] else if (task.task.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.task.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (timeTracking != null && timeTracking.totalDuration > Duration.zero) ...[
            const SizedBox(height: AppTheme.spacingM),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 20,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  Text(
                    'Time Spent: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    DateFormatter.formatDuration(timeTracking.totalDuration),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
