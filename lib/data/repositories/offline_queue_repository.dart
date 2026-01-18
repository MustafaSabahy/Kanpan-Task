import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/offline_task.dart';
import '../models/offline_comment.dart';

/// Repository for managing offline queue (tasks and comments pending sync)
class OfflineQueueRepository {
  static const String _tasksKey = 'offline_tasks_queue';
  static const String _commentsKey = 'offline_comments_queue';

  // ========== Tasks Queue ==========

  /// Save a task to offline queue
  Future<void> addOfflineTask(OfflineTask task) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getOfflineTasks();
    tasks.add(task);
    await _saveOfflineTasks(tasks);
  }

  /// Get all offline tasks
  Future<List<OfflineTask>> getOfflineTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_tasksKey);
    if (jsonString == null) return [];

    final json = jsonDecode(jsonString) as List;
    return json.map((item) => OfflineTask.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Remove a task from offline queue (after successful sync)
  Future<void> removeOfflineTask(String taskId) async {
    final tasks = await getOfflineTasks();
    tasks.removeWhere((task) => task.id == taskId);
    await _saveOfflineTasks(tasks);
  }

  /// Clear all offline tasks
  Future<void> clearOfflineTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
  }

  Future<void> _saveOfflineTasks(List<OfflineTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final json = tasks.map((task) => task.toJson()).toList();
    await prefs.setString(_tasksKey, jsonEncode(json));
  }

  // ========== Comments Queue ==========

  /// Save a comment to offline queue
  Future<void> addOfflineComment(OfflineComment comment) async {
    final prefs = await SharedPreferences.getInstance();
    final comments = await getOfflineComments();
    comments.add(comment);
    await _saveOfflineComments(comments);
  }

  /// Get all offline comments
  Future<List<OfflineComment>> getOfflineComments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_commentsKey);
    if (jsonString == null) return [];

    final json = jsonDecode(jsonString) as List;
    return json.map((item) => OfflineComment.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Get offline comments for a specific task
  Future<List<OfflineComment>> getOfflineCommentsForTask(String taskId) async {
    final comments = await getOfflineComments();
    return comments.where((comment) => comment.taskId == taskId).toList();
  }

  /// Remove a comment from offline queue (after successful sync)
  Future<void> removeOfflineComment(String commentId) async {
    final comments = await getOfflineComments();
    comments.removeWhere((comment) => comment.id == commentId);
    await _saveOfflineComments(comments);
  }

  /// Clear all offline comments
  Future<void> clearOfflineComments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_commentsKey);
  }

  Future<void> _saveOfflineComments(List<OfflineComment> comments) async {
    final prefs = await SharedPreferences.getInstance();
    final json = comments.map((comment) => comment.toJson()).toList();
    await prefs.setString(_commentsKey, jsonEncode(json));
  }
}
