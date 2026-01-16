import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions (iOS)
    await _requestPermissions();

    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    // Request iOS permissions (handled automatically by the plugin)
    // The plugin will request permissions when needed
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap if needed
    // You can navigate to task details or open the app
  }

  /// Convert task ID string to a unique integer for notification ID
  /// Always use hashCode to ensure 32-bit integer compatibility
  int _taskIdToNotificationId(String taskId) {
    // Always use hashCode to ensure the value fits in 32-bit integer range
    // This handles both string IDs and large integer IDs that exceed 32-bit limits
    final hash = taskId.hashCode;
    // Ensure positive value within 32-bit range
    return (hash & 0x7FFFFFFF); // Mask to ensure positive 31-bit value
  }

  Future<void> scheduleTaskNotification({
    required String taskId,
    required String title,
    String? description,
    required DateTime scheduledTime,
  }) async {
    if (!_initialized) await initialize();

    final notificationId = _taskIdToNotificationId(taskId);
    
    // Cancel any existing notification for this task
    await cancelTaskNotification(notificationId);

    // Don't schedule if time is in the past
    if (scheduledTime.isBefore(DateTime.now())) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for scheduled tasks',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      notificationId,
      title,
      description ?? title,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelTaskNotification(int notificationId) async {
    if (!_initialized) await initialize();
    await _notifications.cancel(notificationId);
  }

  Future<void> cancelTaskNotificationByTaskId(String taskId) async {
    final notificationId = _taskIdToNotificationId(taskId);
    await cancelTaskNotification(notificationId);
  }

  Future<void> updateTaskNotification({
    required String taskId,
    required String title,
    String? description,
    required DateTime scheduledTime,
  }) async {
    // Cancel old and schedule new
    await scheduleTaskNotification(
      taskId: taskId,
      title: title,
      description: description,
      scheduledTime: scheduledTime,
    );
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized) await initialize();
    return await _notifications.pendingNotificationRequests();
  }
}
