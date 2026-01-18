import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../data/repositories/comment_repository.dart';
import '../../../data/repositories/offline_queue_repository.dart';
import '../../../data/models/offline_comment.dart';
import '../../../core/services/connectivity_service.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentRepository _repository;
  final OfflineQueueRepository _offlineQueue;
  final String taskId;
  final _uuid = const Uuid();

  CommentBloc({
    required CommentRepository repository,
    required OfflineQueueRepository offlineQueue,
    required this.taskId,
  })  : _repository = repository,
        _offlineQueue = offlineQueue,
        super(const CommentInitial()) {
    on<LoadCommentsEvent>(_onLoadComments);
    on<AddCommentEvent>(_onAddComment);
    on<DeleteCommentEvent>(_onDeleteComment);
    add(LoadCommentsEvent(taskId));
  }

  Future<void> _onLoadComments(
    LoadCommentsEvent event,
    Emitter<CommentState> emit,
  ) async {
    if (event.taskId != taskId) return;
    
    emit(const CommentLoading());
    try {
      final comments = await _repository.getComments(taskId: event.taskId);
      emit(CommentLoaded(comments));
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<void> _onAddComment(
    AddCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    if (event.taskId != taskId) return;
    
    final hasConnection = await ConnectivityService.hasConnectionWithTimeout();
    
    if (hasConnection) {
      try {
        await _repository.createComment(taskId: event.taskId, content: event.content);
        add(LoadCommentsEvent(taskId));
      } catch (e) {
        // If online creation fails, save to offline queue
        await _saveCommentToOfflineQueue(event);
        add(LoadCommentsEvent(taskId));
      }
    } else {
      // No connection - save to offline queue
      await _saveCommentToOfflineQueue(event);
      add(LoadCommentsEvent(taskId));
    }
  }

  Future<void> _saveCommentToOfflineQueue(AddCommentEvent event) async {
    final offlineComment = OfflineComment(
      id: _uuid.v4(),
      taskId: event.taskId,
      content: event.content,
      createdAt: DateTime.now(),
      action: 'create',
    );
    await _offlineQueue.addOfflineComment(offlineComment);
  }

  Future<void> _onDeleteComment(
    DeleteCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    if (event.taskId != taskId) return;
    
    final hasConnection = await ConnectivityService.hasConnectionWithTimeout();
    
    if (hasConnection) {
      try {
        await _repository.deleteComment(event.commentId);
        add(LoadCommentsEvent(taskId));
      } catch (e) {
        // If online delete fails, save to offline queue
        await _saveDeleteCommentToOfflineQueue(event);
        add(LoadCommentsEvent(taskId));
      }
    } else {
      // No connection - save to offline queue
      await _saveDeleteCommentToOfflineQueue(event);
      add(LoadCommentsEvent(taskId));
    }
  }

  Future<void> _saveDeleteCommentToOfflineQueue(DeleteCommentEvent event) async {
    final offlineComment = OfflineComment(
      id: _uuid.v4(),
      taskId: event.taskId,
      content: '', // Not needed for delete
      createdAt: DateTime.now(),
      action: 'delete',
      originalCommentId: event.commentId,
    );
    await _offlineQueue.addOfflineComment(offlineComment);
  }
}
