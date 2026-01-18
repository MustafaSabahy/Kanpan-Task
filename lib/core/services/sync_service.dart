import '../../data/repositories/offline_queue_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/comment_repository.dart';
import '../../data/models/offline_task.dart';
import '../../data/models/offline_comment.dart';
import '../../data/models/task_model.dart';
import '../../data/models/comment_model.dart';
import 'connectivity_service.dart';

/// Service to sync offline data when connection is restored
class SyncService {
  final OfflineQueueRepository _offlineQueue;
  final TaskRepository _taskRepository;
  final CommentRepository _commentRepository;

  SyncService({
    required OfflineQueueRepository offlineQueue,
    required TaskRepository taskRepository,
    required CommentRepository commentRepository,
  })  : _offlineQueue = offlineQueue,
        _taskRepository = taskRepository,
        _commentRepository = commentRepository;

  /// Sync all pending offline data
  Future<SyncResult> syncAll() async {
    if (!await ConnectivityService.hasConnectionWithTimeout()) {
      return SyncResult(
        success: false,
        message: 'No internet connection',
        syncedTasks: 0,
        syncedComments: 0,
        failedTasks: 0,
        failedComments: 0,
      );
    }

    final tasksResult = await syncOfflineTasks();
    final commentsResult = await syncOfflineComments();

    return SyncResult(
      success: tasksResult.success && commentsResult.success,
      message: 'Synced ${tasksResult.synced} tasks and ${commentsResult.synced} comments',
      syncedTasks: tasksResult.synced,
      syncedComments: commentsResult.synced,
      failedTasks: tasksResult.failed,
      failedComments: commentsResult.failed,
    );
  }

  /// Sync offline tasks
  Future<SyncOperationResult> syncOfflineTasks() async {
    final offlineTasks = await _offlineQueue.getOfflineTasks();
    int synced = 0;
    int failed = 0;

    for (final offlineTask in offlineTasks) {
      try {
        if (offlineTask.action == 'create') {
          await _taskRepository.createTask(
            content: offlineTask.content,
            description: offlineTask.description,
            priority: offlineTask.priority,
            projectId: offlineTask.projectId,
            dueString: offlineTask.dueString,
          );
          await _offlineQueue.removeOfflineTask(offlineTask.id);
          synced++;
        } else if (offlineTask.action == 'update' && offlineTask.originalTaskId != null) {
          await _taskRepository.updateTask(
            offlineTask.originalTaskId!,
            content: offlineTask.content,
            description: offlineTask.description,
            priority: offlineTask.priority,
            dueString: offlineTask.dueString,
          );
          await _offlineQueue.removeOfflineTask(offlineTask.id);
          synced++;
        } else if (offlineTask.action == 'delete' && offlineTask.originalTaskId != null) {
          await _taskRepository.deleteTask(offlineTask.originalTaskId!);
          await _offlineQueue.removeOfflineTask(offlineTask.id);
          synced++;
        }
      } catch (e) {
        failed++;
        // Keep task in queue for retry later
      }
    }

    return SyncOperationResult(
      success: failed == 0,
      synced: synced,
      failed: failed,
    );
  }

  /// Sync offline comments
  Future<SyncOperationResult> syncOfflineComments() async {
    final offlineComments = await _offlineQueue.getOfflineComments();
    int synced = 0;
    int failed = 0;

    for (final offlineComment in offlineComments) {
      try {
        if (offlineComment.action == 'create') {
          await _commentRepository.createComment(
            taskId: offlineComment.taskId,
            content: offlineComment.content,
          );
          await _offlineQueue.removeOfflineComment(offlineComment.id);
          synced++;
        } else if (offlineComment.action == 'delete' && offlineComment.originalCommentId != null) {
          await _commentRepository.deleteComment(offlineComment.originalCommentId!);
          await _offlineQueue.removeOfflineComment(offlineComment.id);
          synced++;
        }
      } catch (e) {
        failed++;
        // Keep comment in queue for retry later
      }
    }

    return SyncOperationResult(
      success: failed == 0,
      synced: synced,
      failed: failed,
    );
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int syncedTasks;
  final int syncedComments;
  final int failedTasks;
  final int failedComments;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedTasks,
    required this.syncedComments,
    required this.failedTasks,
    required this.failedComments,
  });
}

class SyncOperationResult {
  final bool success;
  final int synced;
  final int failed;

  SyncOperationResult({
    required this.success,
    required this.synced,
    required this.failed,
  });
}
