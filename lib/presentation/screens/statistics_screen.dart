import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../gen/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/task_time_tracking.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task/task_bloc.dart';
import '../bloc/task/task_state.dart';
import '../bloc/task/task_event.dart';
import 'dart:collection';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedTaskId;
  String? _selectedStatus;

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
                  'Error loading statistics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (state is TaskLoaded) {
          final stats = _calculateStatistics(state.tasks);
          final hasFilters = _startDate != null || 
                            _endDate != null || 
                            _selectedTaskId != null || 
                            _selectedStatus != null;
          final hasNoData = stats.totalTrackedTime == Duration.zero && stats.totalSessions == 0;
          
          // Show empty state only if no filters and no data
          if (!hasFilters && hasNoData) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () {
              context.read<TaskBloc>().add(LoadTasksEvent());
              return Future.value();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilters(context, state.tasks),
                  const SizedBox(height: AppTheme.spacingL),
                  if (hasNoData && hasFilters)
                    _buildNoDataWithFilters(context)
                  else ...[
                    _buildOverallSummary(context, stats),
                    const SizedBox(height: AppTheme.spacingL),
                    _buildTimeByStatus(context, stats),
                    const SizedBox(height: AppTheme.spacingL),
                    _buildTimeByTask(context, stats),
                    const SizedBox(height: AppTheme.spacingL),
                    _buildTimeOverTime(context, stats),
                  ],
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'No tracked time yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Start tracking time on tasks to see statistics',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataWithFilters(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          children: [
            Icon(
              Icons.filter_alt_off,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'No data matches your filters',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Try adjusting your filters to see statistics',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, List<TaskEntity> tasks) {
    // final l10n = AppLocalizations.of(context)!;
    return Card(
      child: ExpansionTile(
        title: const Text('Filters'),
        leading: const Icon(Icons.filter_list),
        children: [
          ListTile(
            title: const Text('Date Range'),
            subtitle: Text(
              _startDate != null && _endDate != null
                  ? '${DateFormatter.formatDate(_startDate!)} - ${DateFormatter.formatDate(_endDate!)}'
                  : 'All dates',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _startDate = null;
                  _endDate = null;
                });
              },
            ),
            onTap: () async {
              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _startDate != null && _endDate != null
                    ? DateTimeRange(start: _startDate!, end: _endDate!)
                    : null,
              );
              if (picked != null) {
                setState(() {
                  _startDate = picked.start;
                  _endDate = picked.end;
                });
              }
            },
          ),
          ListTile(
            title: const Text('Task'),
            subtitle: Text(
              _selectedTaskId != null
                  ? tasks.firstWhere((t) => t.task.id == _selectedTaskId).task.content
                  : 'All tasks',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _selectedTaskId = null;
                });
              },
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Task'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return ListTile(
                          title: Text(task.task.content),
                          onTap: () {
                            setState(() {
                              _selectedTaskId = task.task.id;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Status'),
            subtitle: Text(_selectedStatus ?? 'All statuses'),
            trailing: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _selectedStatus = null;
                });
              },
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Status'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('All statuses'),
                        onTap: () {
                          setState(() {
                            _selectedStatus = null;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('To Do'),
                        onTap: () {
                          setState(() {
                            _selectedStatus = AppConstants.columnTodo;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('In Progress'),
                        onTap: () {
                          setState(() {
                            _selectedStatus = AppConstants.columnInProgress;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('Done'),
                        onTap: () {
                          setState(() {
                            _selectedStatus = AppConstants.columnDone;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverallSummary(BuildContext context, StatisticsData stats) {
    // final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Summary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.access_time,
                    label: 'Total Time',
                    value: DateFormatter.formatDuration(stats.totalTrackedTime),
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.check_circle,
                    label: 'Completed',
                    value: '${stats.completedTasksCount}',
                    color: AppTheme.doneColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.timer,
                    label: 'Avg per Task',
                    value: stats.completedTasksCount > 0
                        ? DateFormatter.formatDuration(
                            Duration(
                              milliseconds: (stats.totalTrackedTime.inMilliseconds /
                                      stats.completedTasksCount)
                                  .round(),
                            ),
                          )
                        : '0s',
                    color: AppTheme.inProgressColor,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.history,
                    label: 'Sessions',
                    value: '${stats.totalSessions}',
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeByStatus(BuildContext context, StatisticsData stats) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time by Status',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            if (stats.totalTrackedTime > Duration.zero) ...[
              _StatusBar(
                label: AppConstants.columnInProgress,
                duration: stats.inProgressTime,
                total: stats.totalTrackedTime,
                color: AppTheme.inProgressColor,
              ),
              const SizedBox(height: AppTheme.spacingS),
              _StatusBar(
                label: AppConstants.columnDone,
                duration: stats.doneTime,
                total: stats.totalTrackedTime,
                color: AppTheme.doneColor,
              ),
            ] else
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Text(
                  'No time tracked yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeByTask(BuildContext context, StatisticsData stats) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time by Task',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            if (stats.topTasks.isNotEmpty) ...[
              ...stats.topTasks.take(10).map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
                    child: _TaskBar(
                      taskName: entry.taskName,
                      duration: entry.duration,
                      maxDuration: stats.topTasks.first.duration,
                    ),
                  )),
            ] else
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Text(
                  'No tasks with tracked time',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeOverTime(BuildContext context, StatisticsData stats) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Over Time',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            if (stats.dailyTime.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: _TimeLineChart(dailyTime: stats.dailyTime),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Text(
                  'No time data available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  StatisticsData _calculateStatistics(List<TaskEntity> tasks) {
    // Apply filters
    var filteredTasks = tasks;
    
    if (_selectedTaskId != null) {
      filteredTasks = filteredTasks.where((t) => t.task.id == _selectedTaskId).toList();
    }
    
    if (_selectedStatus != null) {
      filteredTasks = filteredTasks.where((t) => t.kanbanColumn == _selectedStatus).toList();
    }

    // Calculate from history sessions only
    Duration totalTrackedTime = Duration.zero;
    int totalSessions = 0;
    Duration inProgressTime = Duration.zero;
    Duration doneTime = Duration.zero;
    int completedTasksCount = 0;
    
    final taskTimeMap = <String, Duration>{};
    final dailyTimeMap = <DateTime, Duration>{};

    for (final task in filteredTasks) {
      final timeTracking = task.timeTracking;
      if (timeTracking == null) continue;

      // Get all closed history sessions
      final historySessions = timeTracking.getHistorySessions();
      
      // Filter by date range if set
      final filteredSessions = historySessions.where((session) {
        if (_startDate != null && session.startTime.isBefore(_startDate!)) {
          return false;
        }
        if (_endDate != null && session.startTime.isAfter(_endDate!)) {
          return false;
        }
        return true;
      }).toList();

      // Calculate time from filtered sessions
      Duration taskTotalTime = Duration.zero;
      for (final session in filteredSessions) {
        if (session.isClosed) {
          final duration = session.duration;
          taskTotalTime += duration;
          totalSessions++;
          
          // Group by day for timeline
          final day = DateTime(
            session.startTime.year,
            session.startTime.month,
            session.startTime.day,
          );
          dailyTimeMap[day] = (dailyTimeMap[day] ?? Duration.zero) + duration;
        }
      }

      if (taskTotalTime > Duration.zero) {
        totalTrackedTime += taskTotalTime;
        taskTimeMap[task.task.id] = taskTotalTime;
        
        // All time in history sessions was tracked while In Progress
        // Done time = time from tasks that are currently Done
        // In Progress time = time from tasks currently In Progress
        if (task.isDone) {
          doneTime += taskTotalTime;
        } else if (task.isInProgress) {
          inProgressTime += taskTotalTime;
        } else {
          // Task is Todo but has history - count as In Progress time
          // (time was tracked when it was In Progress before)
          inProgressTime += taskTotalTime;
        }
      }

      if (task.isCompleted) {
        completedTasksCount++;
      }
    }

    // Sort tasks by time
    final topTasks = taskTimeMap.entries.map((entry) {
      final task = filteredTasks.firstWhere((t) => t.task.id == entry.key);
      return TaskTimeEntry(
        taskName: task.task.content,
        duration: entry.value,
      );
    }).toList()
      ..sort((a, b) => b.duration.compareTo(a.duration));

    // Sort daily time by date
    final dailyTime = dailyTimeMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return StatisticsData(
      totalTrackedTime: totalTrackedTime,
      totalSessions: totalSessions,
      inProgressTime: inProgressTime,
      doneTime: doneTime,
      completedTasksCount: completedTasksCount,
      topTasks: topTasks,
      dailyTime: dailyTime,
    );
  }
}

class StatisticsData {
  final Duration totalTrackedTime;
  final int totalSessions;
  final Duration inProgressTime;
  final Duration doneTime;
  final int completedTasksCount;
  final List<TaskTimeEntry> topTasks;
  final List<MapEntry<DateTime, Duration>> dailyTime;

  StatisticsData({
    required this.totalTrackedTime,
    required this.totalSessions,
    required this.inProgressTime,
    required this.doneTime,
    required this.completedTasksCount,
    required this.topTasks,
    required this.dailyTime,
  });
}

class TaskTimeEntry {
  final String taskName;
  final Duration duration;

  TaskTimeEntry({
    required this.taskName,
    required this.duration,
  });
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final String label;
  final Duration duration;
  final Duration total;
  final Color color;

  const _StatusBar({
    required this.label,
    required this.duration,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = total.inMilliseconds > 0
        ? (duration.inMilliseconds / total.inMilliseconds * 100)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingS),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 24,
            backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormatter.formatDuration(duration),
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TaskBar extends StatelessWidget {
  final String taskName;
  final Duration duration;
  final Duration maxDuration;

  const _TaskBar({
    required this.taskName,
    required this.duration,
    required this.maxDuration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = maxDuration.inMilliseconds > 0
        ? (duration.inMilliseconds / maxDuration.inMilliseconds)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                taskName,
                style: theme.textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              DateFormatter.formatDuration(duration),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingS),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }
}

class _TimeLineChart extends StatelessWidget {
  final List<MapEntry<DateTime, Duration>> dailyTime;

  const _TimeLineChart({required this.dailyTime});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (dailyTime.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxDuration = dailyTime
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);

    return CustomPaint(
      painter: _TimeLinePainter(
        dailyTime: dailyTime,
        maxDuration: maxDuration,
        color: theme.colorScheme.primary,
      ),
      child: Container(),
    );
  }
}

class _TimeLinePainter extends CustomPainter {
  final List<MapEntry<DateTime, Duration>> dailyTime;
  final Duration maxDuration;
  final Color color;

  _TimeLinePainter({
    required this.dailyTime,
    required this.maxDuration,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dailyTime.isEmpty || maxDuration == Duration.zero) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final maxValue = maxDuration.inMilliseconds.toDouble();
    final stepX = size.width / (dailyTime.length - 1).clamp(1, double.infinity);

    for (int i = 0; i < dailyTime.length; i++) {
      final entry = dailyTime[i];
      final value = entry.value.inMilliseconds.toDouble();
      final normalizedValue = maxValue > 0 ? value / maxValue : 0.0;
      final x = i * stepX;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Close the fill path
    if (dailyTime.isNotEmpty) {
      final lastX = (dailyTime.length - 1) * stepX;
      fillPath.lineTo(lastX, size.height);
      fillPath.close();
    }

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < dailyTime.length; i++) {
      final entry = dailyTime[i];
      final value = entry.value.inMilliseconds.toDouble();
      final normalizedValue = maxValue > 0 ? value / maxValue : 0.0;
      final x = i * stepX;
      final y = size.height - (normalizedValue * size.height);

      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(_TimeLinePainter oldDelegate) {
    return oldDelegate.dailyTime != dailyTime ||
        oldDelegate.maxDuration != maxDuration;
  }
}
