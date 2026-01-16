import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../gen/l10n/app_localizations.dart';
import 'package:task/presentation/widgets/comments_section.dart';
import 'package:task/presentation/widgets/timer_widget.dart';
import 'package:task/presentation/widgets/time_history_widget.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/task_entity.dart';
import '../../data/repositories/comment_repository.dart';
import '../bloc/task/task_bloc.dart';
import '../bloc/task/task_event.dart';
import '../bloc/comment/comment_bloc.dart';
import 'task_card.dart';

class KanbanColumn extends StatelessWidget {
  final String title;
  final List<TaskEntity> tasks;
  final Color color;

  const KanbanColumn({
    super.key,
    required this.title,
    required this.tasks,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingS),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingM,
            ),
            child: Row(
              children: [
                // Vertical colored bar
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                // Title text
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                // Circular count badge
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${tasks.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? DragTarget<TaskEntity>(
                    onAccept: (draggedTask) {
                      if (draggedTask.kanbanColumn != title) {
                        context.read<TaskBloc>().add(
                              MoveTaskEvent(
                                taskId: draggedTask.task.id,
                                newColumn: title,
                              ),
                            );
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                          border: candidateData.isNotEmpty
                              ? Border.all(
                                  color: color,
                                  width: 2,
                                  style: BorderStyle.solid,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Drop task here',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: candidateData.isNotEmpty ? color : AppTheme.textSecondary,
                                ),
                          ),
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.all(AppTheme.spacingS),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return DragTarget<TaskEntity>(
                        onAccept: (draggedTask) {
                          if (draggedTask.kanbanColumn != title &&
                              draggedTask.task.id != task.task.id) {
                            context.read<TaskBloc>().add(
                                  MoveTaskEvent(
                                    taskId: draggedTask.task.id,
                                    newColumn: title,
                                  ),
                                );
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          return Stack(
                            children: [
                              TaskCard(
                                task: task,
                                currentColumn: title,
                                onTap: () => _showTaskDetails(context, task),
                                onLongPress: () => _showTaskOptions(context, task),
                              ),
                              if (candidateData.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                            ],
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showTaskDetails(BuildContext context, TaskEntity task) {
    // Navigate to task details screen
    // For now, show a dialog
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (context) => CommentBloc(
          repository: CommentRepository(),
          taskId: task.task.id,
        ),
        child: TaskDetailsSheet(task: task),
      ),
    );
  }

  void _showTaskOptions(BuildContext context, TaskEntity task) {
    // final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Task'),
              onTap: () {
                Navigator.pop(context);
                _showEditTaskDialog(context, task);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Task'),
              onTap: () {
                context.read<TaskBloc>().add(DeleteTaskEvent(task.task.id));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, TaskEntity task) {
    // final l10n = AppLocalizations.of(context)!;
    final contentController = TextEditingController(text: task.task.content);
    final descriptionController = TextEditingController(
      text: task.task.description ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter task title',
                ),
                autofocus: true,
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter task description',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (contentController.text.trim().isNotEmpty) {
                context.read<TaskBloc>().add(
                      UpdateTaskEvent(
                        id: task.task.id,
                        content: contentController.text.trim(),
                        description: descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text.trim(),
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class TaskDetailsSheet extends StatelessWidget {
  final TaskEntity task;

  const TaskDetailsSheet({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    task.task.content,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.task.description != null) ...[
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      task.task.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                  ],
                  // Timer widget
                  TimerWidget(
                    taskId: task.task.id,
                    isTaskDone: task.isDone,
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  // Time history
                  TimeHistoryWidget(
                    timeTracking: task.timeTracking,
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  // Comments section
                  CommentsSection(taskId: task.task.id),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
