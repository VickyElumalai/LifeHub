import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

// ⚠️ CRITICAL: This callback MUST be a top-level function (not inside a class)
// WorkManager will call this function in the background
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Initialize notifications in background
      final FlutterLocalNotificationsPlugin notifications = 
          FlutterLocalNotificationsPlugin();
      
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      await notifications.initialize(initSettings);

      // Get notification details from inputData
      final title = inputData?['title'] ?? 'Task Due Soon';
      final content = inputData?['content'] ?? 'Your task is due';
      final id = inputData?['id'] ?? 0;

      // Show the notification
      await notifications.show(
        id,
        '⏰ $title',
        content,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Task Reminders',
            channelDescription: 'Notifications for upcoming tasks',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            enableLights: true,
            ledColor: Color(0xFF667eea),
            ledOnMs: 1000,
            ledOffMs: 500,
            visibility: NotificationVisibility.public,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
          ),
        ),
      );

      return Future.value(true);
    } catch (e) {
      // Return false if something went wrong
      return Future.value(false);
    }
  });
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize the notification service and WorkManager
  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize WorkManager with the callback dispatcher
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // Set to false for production
    );

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    
    _initialized = true;
  }

  /// Schedule a notification for a task
  /// This will work even when the app is closed or phone is sleeping
  static Future<void> scheduleTaskNotification({
    required String id,
    required String title,
    required String content,
    required DateTime scheduledTime,
  }) async {
    await initialize();

    // Calculate notification time (1 minute before due time)
    final notificationTime = scheduledTime.subtract(const Duration(minutes: 1));
    
    // Check if time is in the future
    if (notificationTime.isBefore(DateTime.now())) {
      return;
    }

    // Calculate the delay from now
    final delay = notificationTime.difference(DateTime.now());
    
    // Create a unique task name using the task ID
    final taskName = 'notification_$id';

    // Schedule the one-time background task
    await Workmanager().registerOneOffTask(
      taskName,
      taskName,
      initialDelay: delay,
      inputData: {
        'title': title,
        'content': content,
        'id': id.hashCode.abs() % 2147483647, // Ensure it's a valid int
      },
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }

  /// Cancel a scheduled notification
  static Future<void> cancelNotification(String id) async {
    final taskName = 'notification_$id';
    await Workmanager().cancelByUniqueName(taskName);
  }

  /// Cancel all scheduled notifications
  static Future<void> cancelAllNotifications() async {
    await Workmanager().cancelAll();
    await _notifications.cancelAll();
  }

  /// Show an immediate test notification (for testing purposes)
  static Future<void> showTestNotification() async {
    await initialize();
    
    await _notifications.show(
      999999,
      '🔔 Test Notification',
      'If you see this, notifications are working!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Notifications for upcoming tasks',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
    );
  }
}