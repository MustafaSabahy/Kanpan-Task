import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends TaskEvent {
  const LoadTasksEvent();
}

class CreateTaskEvent extends TaskEvent {
  final String content;
  final String? description;
  final int? priority;

  const CreateTaskEvent({
    required this.content,
    this.description,
    this.priority,
  });

  @override
  List<Object?> get props => [content, description, priority];
}

class UpdateTaskEvent extends TaskEvent {
  final String id;
  final String? content;
  final String? description;
  final int? priority;

  const UpdateTaskEvent({
    required this.id,
    this.content,
    this.description,
    this.priority,
  });

  @override
  List<Object?> get props => [id, content, description, priority];
}

class DeleteTaskEvent extends TaskEvent {
  final String id;

  const DeleteTaskEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class MoveTaskEvent extends TaskEvent {
  final String taskId;
  final String newColumn;

  const MoveTaskEvent({
    required this.taskId,
    required this.newColumn,
  });

  @override
  List<Object?> get props => [taskId, newColumn];
}

class ClearAllTasksEvent extends TaskEvent {
  const ClearAllTasksEvent();
}

class ClearTasksFromColumnEvent extends TaskEvent {
  final String column;

  const ClearTasksFromColumnEvent(this.column);

  @override
  List<Object?> get props => [column];
}
