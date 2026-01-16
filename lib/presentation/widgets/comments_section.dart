import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../bloc/comment/comment_bloc.dart';
import '../bloc/comment/comment_state.dart';
import '../bloc/comment/comment_event.dart';

class CommentsSection extends StatefulWidget {
  final String taskId;

  const CommentsSection({super.key, required this.taskId});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommentBloc, CommentState>(
      builder: (context, commentState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.comment_outlined, size: 20),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  'Comments',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_commentController.text.trim().isNotEmpty) {
                      context.read<CommentBloc>().add(
                            AddCommentEvent(
                              taskId: widget.taskId,
                              content: _commentController.text.trim(),
                            ),
                          );
                      _commentController.clear();
                    }
                  },
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppTheme.spacingM),
            if (commentState is CommentLoading)
              const Center(child: CircularProgressIndicator())
            else if (commentState is CommentError)
              Center(
                child: Text(
                  commentState.message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.errorColor,
                      ),
                ),
              )
            else if (commentState is CommentLoaded) ...[
              Builder(
                builder: (context) {
                  final comments = commentState.comments;
                  if (comments.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingL),
                        child: Text(
                          'No comments yet',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppTheme.spacingS),
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return Container(
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment.content,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: AppTheme.spacingS),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormatter.formatDateTime(
                                    DateTime.parse(comment.postedAt),
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  onPressed: () {
                                    context.read<CommentBloc>().add(
                                          DeleteCommentEvent(
                                            taskId: widget.taskId,
                                            commentId: comment.id,
                                          ),
                                        );
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}
