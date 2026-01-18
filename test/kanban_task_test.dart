import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task/data/models/task_time_tracking.dart';
import 'package:task/data/models/comment_model.dart';
import 'package:task/data/repositories/time_tracking_repository.dart';
import 'package:task/data/repositories/comment_repository.dart';
import 'package:task/presentation/bloc/timer/timer_bloc.dart';
import 'package:task/presentation/bloc/timer/timer_event.dart';
import 'package:task/presentation/bloc/timer/timer_state.dart';
import 'package:task/presentation/bloc/comment/comment_bloc.dart';
import 'package:task/presentation/bloc/comment/comment_event.dart';
import 'package:task/presentation/bloc/comment/comment_state.dart';
import 'package:mocktail/mocktail.dart';

// Mock repositories for testing
class MockTimeTrackingRepository extends Mock implements TimeTrackingRepository {}
class MockCommentRepository extends Mock implements CommentRepository {}

void main() {
  group('TimerBloc Tests', () {
    late MockTimeTrackingRepository mockRepository;
    late TimerBloc timerBloc;

    setUp(() {
      mockRepository = MockTimeTrackingRepository();
      timerBloc = TimerBloc(repository: mockRepository);
    });

    tearDown(() {
      timerBloc.close();
    });

    group('Timer Start - Moving task to In Progress', () {
      test('starts timer when task moves to In Progress', () async {
        // Arrange: No existing tracking for this task
        when(() => mockRepository.getTimeTracking('task-1'))
            .thenAnswer((_) async => null);
        when(() => mockRepository.saveTimeTracking(any()))
            .thenAnswer((_) async => {});

        // Act: Start timer
        timerBloc.add(const StartTimerEvent('task-1'));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert: Timer should be active
        expect(timerBloc.state.isActive, isTrue);
        expect(timerBloc.state.taskId, equals('task-1'));
        expect(timerBloc.state.startTime, isNotNull);
        expect(timerBloc.state.totalTrackedTime, equals(Duration.zero));

        // Verify repository was called to save tracking
        verify(() => mockRepository.saveTimeTracking(any())).called(1);
      });

      test('creates new session with "start" reason when starting timer', () async {
        // Arrange: Task with no previous tracking
        when(() => mockRepository.getTimeTracking('task-1'))
            .thenAnswer((_) async => null);
        when(() => mockRepository.saveTimeTracking(any()))
            .thenAnswer((_) async => {});

        // Act
        timerBloc.add(const StartTimerEvent('task-1'));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert: Verify session was created with correct reason
        final captured = verify(() => mockRepository.saveTimeTracking(captureAny())).captured;
        final savedTracking = captured.first as TaskTimeTracking;
        expect(savedTracking.sessions.length, equals(1));
        expect(savedTracking.sessions.first.statusChangeReason, equals('start'));
        expect(savedTracking.sessions.first.isActive, isTrue);
      });
    });

    group('Timer Stop - Time calculation and storage', () {
      test('stops timer and saves time correctly', () async {
        // Arrange: Timer is running
        final startTime = DateTime.now().subtract(const Duration(seconds: 30));
        final initialTracking = TaskTimeTracking(
          taskId: 'task-1',
          totalTrackedTime: Duration.zero,
          startTime: startTime,
          isRunning: true,
          sessions: [
            TimeSession(
              startTime: startTime,
              statusChangeReason: 'start',
            ),
          ],
        );

        when(() => mockRepository.getTimeTracking('task-1'))
            .thenAnswer((_) async => initialTracking);
        when(() => mockRepository.saveTimeTracking(any()))
            .thenAnswer((_) async => {});

        // Start timer first
        timerBloc.add(const StartTimerEvent('task-1'));
        await Future.delayed(const Duration(milliseconds: 100));

        // Wait a bit to simulate time passing
        await Future.delayed(const Duration(milliseconds: 100));

        // Act: Stop timer
        timerBloc.add(const StopTimerEvent());
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert: Timer should be inactive
        expect(timerBloc.state.isActive, isFalse);
        expect(timerBloc.state.taskId, isNull);

        // Verify time was saved
        final captured = verify(() => mockRepository.saveTimeTracking(captureAny())).captured;
        final savedTracking = captured.last as TaskTimeTracking;
        expect(savedTracking.isRunning, isFalse);
        expect(savedTracking.startTime, isNull);
        expect(savedTracking.sessions.first.isClosed, isTrue);
        expect(savedTracking.sessions.first.statusChangeReason, equals('pause'));
      });

      test('calculates total time from all closed sessions', () async {
        // Arrange: Task with previous sessions
        final session1 = TimeSession(
          startTime: DateTime.now().subtract(const Duration(hours: 2)),
          endTime: DateTime.now().subtract(const Duration(hours: 1)),
          statusChangeReason: 'start',
        );
        final session2 = TimeSession(
          startTime: DateTime.now().subtract(const Duration(minutes: 30)),
          statusChangeReason: 'resumed',
        );

        final initialTracking = TaskTimeTracking(
          taskId: 'task-1',
          totalTrackedTime: const Duration(hours: 1), // From session1
          startTime: DateTime.now().subtract(const Duration(minutes: 30)),
          isRunning: true,
          sessions: [session1, session2],
        );

        when(() => mockRepository.getTimeTracking('task-1'))
            .thenAnswer((_) async => initialTracking);
        when(() => mockRepository.saveTimeTracking(any()))
            .thenAnswer((_) async => {});

        // Act: Stop timer
        timerBloc.add(const StartTimerEvent('task-1'));
        await Future.delayed(const Duration(milliseconds: 100));
        timerBloc.add(const StopTimerEvent());
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert: Total time should include both sessions
        final captured = verify(() => mockRepository.saveTimeTracking(captureAny())).captured;
        final savedTracking = captured.last as TaskTimeTracking;
        final totalFromSessions = savedTracking.calculateTotalFromSessions();
        expect(totalFromSessions.inHours, greaterThanOrEqualTo(1));
      });
    });

    group('Single Timer Rule - Only one timer at a time', () {
      test('stops previous timer when starting a new one', () async {
        // Arrange: First task is running
        when(() => mockRepository.getTimeTracking('task-1'))
            .thenAnswer((_) async => null);
        when(() => mockRepository.getTimeTracking('task-2'))
            .thenAnswer((_) async => null);
        when(() => mockRepository.saveTimeTracking(any()))
            .thenAnswer((_) async => {});

        // Act: Start timer for task-1
        timerBloc.add(const StartTimerEvent('task-1'));
        await Future.delayed(const Duration(milliseconds: 100));
        expect(timerBloc.state.taskId, equals('task-1'));

        // Start timer for task-2 (should stop task-1)
        timerBloc.add(const StartTimerEvent('task-2'));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert: Only task-2 should be running
        expect(timerBloc.state.taskId, equals('task-2'));
        expect(timerBloc.state.isActive, isTrue);

        // Verify task-1's timer was saved before starting task-2
        verify(() => mockRepository.saveTimeTracking(any())).called(greaterThan(1));
      });

      test('prevents multiple timers from running simultaneously', () async {
        // Arrange
        when(() => mockRepository.getTimeTracking(any()))
            .thenAnswer((_) async => null);
        when(() => mockRepository.saveTimeTracking(any()))
            .thenAnswer((_) async => {});

        // Act: Try to start multiple timers
        timerBloc.add(const StartTimerEvent('task-1'));
        await Future.delayed(const Duration(milliseconds: 50));
        timerBloc.add(const StartTimerEvent('task-2'));
        await Future.delayed(const Duration(milliseconds: 50));
        timerBloc.add(const StartTimerEvent('task-3'));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert: Only the last timer should be active
        expect(timerBloc.state.isActive, isTrue);
        expect(timerBloc.state.taskId, equals('task-3'));
      });
    });

    group('App Lifecycle - Timer resume after restart', () {
      test('resumes timer correctly after app restart', () async {
        // Arrange: Simulate a timer that was running when app was killed
        final startTime = DateTime.now().subtract(const Duration(hours: 1));
        final tracking = TaskTimeTracking(
          taskId: 'task-1',
          totalTrackedTime: const Duration(minutes: 30),
          startTime: startTime,
          isRunning: true,
          sessions: [
            TimeSession(
              startTime: startTime,
              statusChangeReason: 'start',
            ),
          ],
        );

        when(() => mockRepository.getAllTimeTrackings())
            .thenAnswer((_) async => [tracking]);
        when(() => mockRepository.saveTimeTracking(any()))
            .thenAnswer((_) async => {});

        // Act: Resume timers (simulating app restart)
        timerBloc.add(const ResumeTimersEvent());
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert: Timer should be resumed
        expect(timerBloc.state.isActive, isTrue);
        expect(timerBloc.state.taskId, equals('task-1'));

        // Verify old session was closed and new one created
        final captured = verify(() => mockRepository.saveTimeTracking(captureAny())).captured;
        final savedTracking = captured.first as TaskTimeTracking;
        expect(savedTracking.sessions.length, greaterThan(1));
        expect(savedTracking.sessions.any((s) => s.statusChangeReason == 'app_killed'), isTrue);
        expect(savedTracking.sessions.any((s) => s.statusChangeReason == 'resumed'), isTrue);
      });

      test('handles multiple running timers on restart (only resumes one)', () async {
        // Arrange: Multiple timers were running (edge case)
        final tracking1 = TaskTimeTracking(
          taskId: 'task-1',
          totalTrackedTime: Duration.zero,
          startTime: DateTime.now().subtract(const Duration(minutes: 10)),
          isRunning: true,
          sessions: [TimeSession(startTime: DateTime.now().subtract(const Duration(minutes: 10)))],
        );
        final tracking2 = TaskTimeTracking(
          taskId: 'task-2',
          totalTrackedTime: Duration.zero,
          startTime: DateTime.now().subtract(const Duration(minutes: 5)),
          isRunning: true,
          sessions: [TimeSession(startTime: DateTime.now().subtract(const Duration(minutes: 5)))],
        );

        when(() => mockRepository.getAllTimeTrackings())
            .thenAnswer((_) async => [tracking1, tracking2]);
        when(() => mockRepository.saveTimeTracking(any()))
            .thenAnswer((_) async => {});

        // Act
        timerBloc.add(const ResumeTimersEvent());
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert: Only one timer should be resumed (first one found)
        expect(timerBloc.state.isActive, isTrue);
        expect(timerBloc.state.taskId, isNotNull);
      });
    });

    group('Edge Case - Prevent duplicate timers', () {
      test('ignores duplicate start events for same task', () async {
        // Arrange
        when(() => mockRepository.getTimeTracking('task-1'))
            .thenAnswer((_) async => null);
        when(() => mockRepository.saveTimeTracking(any()))
            .thenAnswer((_) async => {});

        // Act: Start timer multiple times
        timerBloc.add(const StartTimerEvent('task-1'));
        await Future.delayed(const Duration(milliseconds: 50));
        timerBloc.add(const StartTimerEvent('task-1'));
        await Future.delayed(const Duration(milliseconds: 50));
        timerBloc.add(const StartTimerEvent('task-1'));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert: Timer should only be started once
        expect(timerBloc.state.isActive, isTrue);
        expect(timerBloc.state.taskId, equals('task-1'));

        // Verify save was called only once (for initial start)
        verify(() => mockRepository.saveTimeTracking(any())).called(1);
      });

      test('does not start timer for completed tasks', () async {
        // Arrange: Task is already completed
        final completedTracking = TaskTimeTracking(
          taskId: 'task-1',
          totalTrackedTime: const Duration(hours: 2),
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
          sessions: [],
        );

        when(() => mockRepository.getTimeTracking('task-1'))
            .thenAnswer((_) async => completedTracking);

        // Act: Try to start timer
        timerBloc.add(const StartTimerEvent('task-1'));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert: Timer should not start
        expect(timerBloc.state.isActive, isFalse);
        verifyNever(() => mockRepository.saveTimeTracking(any()));
      });
    });
  });

  group('CommentBloc Tests', () {
    late MockCommentRepository mockRepository;
    late CommentBloc commentBloc;
    const testTaskId = 'task-123';

    setUp(() {
      mockRepository = MockCommentRepository();
      commentBloc = CommentBloc(
        repository: mockRepository,
        taskId: testTaskId,
      );
    });

    tearDown(() {
      commentBloc.close();
    });

    group('Create Comment', () {
      test('creates comment and updates state', () async {
        // Arrange
        final newComment = CommentModel(
          id: 'comment-1',
          taskId: testTaskId,
          content: 'Test comment',
          postedAt: DateTime.now().toIso8601String(),
        );

        when(() => mockRepository.getComments(taskId: testTaskId))
            .thenAnswer((_) async => [newComment]);
        when(() => mockRepository.createComment(
          taskId: testTaskId,
          content: 'Test comment',
        )).thenAnswer((_) async => newComment);

        // Act: Add comment
        commentBloc.add(const AddCommentEvent(
          taskId: testTaskId,
          content: 'Test comment',
        ));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert: State should be updated with new comment
        expect(commentBloc.state, isA<CommentLoaded>());
        if (commentBloc.state is CommentLoaded) {
          final loadedState = commentBloc.state as CommentLoaded;
          expect(loadedState.comments.length, equals(1));
          expect(loadedState.comments.first.content, equals('Test comment'));
        }

        verify(() => mockRepository.createComment(
          taskId: testTaskId,
          content: 'Test comment',
        )).called(1);
        verify(() => mockRepository.getComments(taskId: testTaskId)).called(greaterThan(0));
      });

      test('handles error when creating comment fails', () async {
        // Arrange
        when(() => mockRepository.createComment(
          taskId: testTaskId,
          content: 'Test comment',
        )).thenThrow(Exception('Failed to create comment'));

        // Act
        commentBloc.add(const AddCommentEvent(
          taskId: testTaskId,
          content: 'Test comment',
        ));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert: Should emit error state
        expect(commentBloc.state, isA<CommentError>());
        if (commentBloc.state is CommentError) {
          final errorState = commentBloc.state as CommentError;
          expect(errorState.message, contains('Failed to create comment'));
        }
      });
    });

    group('Read Comments', () {
      test('loads comments on initialization', () async {
        // Arrange
        final comments = [
          CommentModel(
            id: 'comment-1',
            taskId: testTaskId,
            content: 'First comment',
            postedAt: DateTime.now().toIso8601String(),
          ),
          CommentModel(
            id: 'comment-2',
            taskId: testTaskId,
            content: 'Second comment',
            postedAt: DateTime.now().toIso8601String(),
          ),
        ];

        when(() => mockRepository.getComments(taskId: testTaskId))
            .thenAnswer((_) async => comments);

        // Act: Bloc automatically loads on init, wait a bit
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert: Comments should be loaded
        expect(commentBloc.state, isA<CommentLoaded>());
        if (commentBloc.state is CommentLoaded) {
          final loadedState = commentBloc.state as CommentLoaded;
          expect(loadedState.comments.length, equals(2));
        }

        verify(() => mockRepository.getComments(taskId: testTaskId)).called(1);
      });

      test('shows loading state while fetching comments', () async {
        // Arrange: Delay the response
        when(() => mockRepository.getComments(taskId: testTaskId))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return [];
        });

        // Act: Load comments
        commentBloc.add(LoadCommentsEvent(testTaskId));

        // Assert: Should emit loading state first
        // Note: This is a timing-dependent test, may need adjustment
        expect(commentBloc.state, isA<CommentLoading>());
      });
    });

    group('Delete Comment', () {
      test('deletes comment and updates state', () async {
        // Arrange
        final comment1 = CommentModel(
          id: 'comment-1',
          taskId: testTaskId,
          content: 'First comment',
          postedAt: DateTime.now().toIso8601String(),
        );
        final comment2 = CommentModel(
          id: 'comment-2',
          taskId: testTaskId,
          content: 'Second comment',
          postedAt: DateTime.now().toIso8601String(),
        );

        // After deletion, only comment2 remains
        when(() => mockRepository.getComments(taskId: testTaskId))
            .thenAnswer((_) async => [comment2]);
        when(() => mockRepository.deleteComment('comment-1'))
            .thenAnswer((_) async => {});

        // Act: Delete comment
        commentBloc.add(const DeleteCommentEvent(
          taskId: testTaskId,
          commentId: 'comment-1',
        ));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert: Comment should be removed from state
        expect(commentBloc.state, isA<CommentLoaded>());
        if (commentBloc.state is CommentLoaded) {
          final loadedState = commentBloc.state as CommentLoaded;
          expect(loadedState.comments.length, equals(1));
          expect(loadedState.comments.first.id, equals('comment-2'));
        }

        verify(() => mockRepository.deleteComment('comment-1')).called(1);
        verify(() => mockRepository.getComments(taskId: testTaskId)).called(greaterThan(0));
      });

      test('handles error when deleting comment fails', () async {
        // Arrange
        when(() => mockRepository.deleteComment('comment-1'))
            .thenThrow(Exception('Failed to delete comment'));

        // Act
        commentBloc.add(const DeleteCommentEvent(
          taskId: testTaskId,
          commentId: 'comment-1',
        ));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert: Should emit error state
        expect(commentBloc.state, isA<CommentError>());
        if (commentBloc.state is CommentError) {
          final errorState = commentBloc.state as CommentError;
          expect(errorState.message, contains('Failed to delete comment'));
        }
      });
    });

    group('State Updates', () {
      test('updates UI correctly after comment operations', () async {
        // Arrange
        final comments = [
          CommentModel(
            id: 'comment-1',
            taskId: testTaskId,
            content: 'Initial comment',
            postedAt: DateTime.now().toIso8601String(),
          ),
        ];

        when(() => mockRepository.getComments(taskId: testTaskId))
            .thenAnswer((_) async => comments);
        when(() => mockRepository.createComment(
          taskId: testTaskId,
          content: 'New comment',
        )).thenAnswer((_) async => CommentModel(
          id: 'comment-2',
          taskId: testTaskId,
          content: 'New comment',
          postedAt: DateTime.now().toIso8601String(),
        ));

        // Wait for initial load
        await Future.delayed(const Duration(milliseconds: 100));

        // Update mock to return both comments after creation
        when(() => mockRepository.getComments(taskId: testTaskId))
            .thenAnswer((_) async => [
          comments.first,
          CommentModel(
            id: 'comment-2',
            taskId: testTaskId,
            content: 'New comment',
            postedAt: DateTime.now().toIso8601String(),
          ),
        ]);

        // Act: Add new comment
        commentBloc.add(const AddCommentEvent(
          taskId: testTaskId,
          content: 'New comment',
        ));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert: State should reflect both comments
        expect(commentBloc.state, isA<CommentLoaded>());
        if (commentBloc.state is CommentLoaded) {
          final loadedState = commentBloc.state as CommentLoaded;
          expect(loadedState.comments.length, equals(2));
        }
      });
    });
  });
}
