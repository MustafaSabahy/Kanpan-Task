import 'package:json_annotation/json_annotation.dart';

part 'offline_task.g.dart';

/// Model for tasks saved offline (pending sync)
@JsonSerializable()
class OfflineTask {
  final String id; // Local UUID for offline tasks
  final String content;
  final String? description;
  final int? priority;
  final String? projectId;
  final String? dueString;
  final DateTime createdAt;
  final String action; // 'create', 'update', 'delete'
  final String? originalTaskId; // For update/delete operations
  final Map<String, dynamic>? updateData; // For update operations

  OfflineTask({
    required this.id,
    required this.content,
    this.description,
    this.priority,
    this.projectId,
    this.dueString,
    required this.createdAt,
    required this.action,
    this.originalTaskId,
    this.updateData,
  });

  factory OfflineTask.fromJson(Map<String, dynamic> json) =>
      _$OfflineTaskFromJson(json);

  Map<String, dynamic> toJson() => _$OfflineTaskToJson(this);

  OfflineTask copyWith({
    String? id,
    String? content,
    String? description,
    int? priority,
    String? projectId,
    String? dueString,
    DateTime? createdAt,
    String? action,
    String? originalTaskId,
    Map<String, dynamic>? updateData,
  }) {
    return OfflineTask(
      id: id ?? this.id,
      content: content ?? this.content,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      projectId: projectId ?? this.projectId,
      dueString: dueString ?? this.dueString,
      createdAt: createdAt ?? this.createdAt,
      action: action ?? this.action,
      originalTaskId: originalTaskId ?? this.originalTaskId,
      updateData: updateData ?? this.updateData,
    );
  }
}
