import 'package:json_annotation/json_annotation.dart';

part 'offline_comment.g.dart';

/// Model for comments saved offline (pending sync)
@JsonSerializable()
class OfflineComment {
  final String id; // Local UUID for offline comments
  final String taskId;
  final String content;
  final DateTime createdAt;
  final String action; // 'create', 'delete'
  final String? originalCommentId; // For delete operations

  OfflineComment({
    required this.id,
    required this.taskId,
    required this.content,
    required this.createdAt,
    required this.action,
    this.originalCommentId,
  });

  factory OfflineComment.fromJson(Map<String, dynamic> json) =>
      _$OfflineCommentFromJson(json);

  Map<String, dynamic> toJson() => _$OfflineCommentToJson(this);

  OfflineComment copyWith({
    String? id,
    String? taskId,
    String? content,
    DateTime? createdAt,
    String? action,
    String? originalCommentId,
  }) {
    return OfflineComment(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      action: action ?? this.action,
      originalCommentId: originalCommentId ?? this.originalCommentId,
    );
  }
}
