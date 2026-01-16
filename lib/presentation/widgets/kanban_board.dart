import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../gen/l10n/app_localizations.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/task/task_bloc.dart';
import '../bloc/task/task_state.dart';
import '../bloc/task/task_event.dart';
import 'kanban_column.dart';

class KanbanBoard extends StatelessWidget {
  final String searchQuery;
  
  const KanbanBoard({
    super.key,
    this.searchQuery = '',
  });

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
                  'Error loading tasks',
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
          // final l10n = AppLocalizations.of(context)!;
          // Filter tasks by search query if provided
          final filteredTasks = searchQuery.isEmpty
              ? state.tasks
              : state.tasks.where((task) {
                  final content = task.task.content.toLowerCase();
                  final description = task.task.description?.toLowerCase() ?? '';
                  return content.contains(searchQuery) || 
                         description.contains(searchQuery);
                }).toList();
          
          final todoTasks = filteredTasks.where((t) => t.isTodo).toList();
          final inProgressTasks = filteredTasks.where((t) => t.isInProgress).toList();
          final doneTasks = filteredTasks.where((t) => t.isDone).toList();

          return Container(
            color: Theme.of(context).colorScheme.background,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: KanbanColumn(
                      title: 'To Do',
                      tasks: todoTasks,
                      color: AppTheme.todoColor,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: KanbanColumn(
                      title: 'In Progress',
                      tasks: inProgressTasks,
                      color: AppTheme.inProgressColor,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: KanbanColumn(
                      title: 'Done',
                      tasks: doneTasks,
                      color: AppTheme.doneColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
