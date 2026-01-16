import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/task_time_tracking.dart';

class TimeHistoryWidget extends StatelessWidget {
  final TaskTimeTracking? timeTracking;

  const TimeHistoryWidget({
    super.key,
    this.timeTracking,
  });

  @override
  Widget build(BuildContext context) {
    if (timeTracking == null) {
      return const SizedBox.shrink();
    }

    final historySessions = timeTracking!.getHistorySessions();
    
    if (historySessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Center(
          child: Text(
            'No time history yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Time History',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Text(
                '${historySessions.length} session${historySessions.length != 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: historySessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppTheme.spacingS),
            itemBuilder: (context, index) {
              final session = historySessions[historySessions.length - 1 - index]; // Reverse to show newest first
              return _buildHistoryItem(context, session, index + 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, TimeSession session, int sessionNumber) {
    final theme = Theme.of(context);
    final duration = session.duration;
    final reason = session.statusChangeReason ?? 'unknown';
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$sessionNumber',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.formatDuration(duration),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getReasonText(reason),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                '${DateFormatter.formatDateTime(session.startTime)} - ${session.endTime != null ? DateFormatter.formatDateTime(session.endTime!) : 'Active'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getReasonText(String reason) {
    switch (reason) {
      case 'start':
        return 'Started';
      case 'pause':
        return 'Paused';
      case 'moved':
        return 'Moved to Todo';
      case 'done':
        return 'Completed';
      case 'reopened':
        return 'Reopened';
      case 'resumed':
        return 'Resumed after restart';
      case 'app_killed':
        return 'App closed';
      default:
        return 'Session';
    }
  }
}
