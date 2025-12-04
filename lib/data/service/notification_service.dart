import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

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

    tz.initializeTimeZones();

    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // Set to false for production
    );

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

  /// This will work even when the app is closed or phone is sleeping
  static Future<void> scheduleTaskNotification({
    required String id,
    required String title,
    required String content,
    required DateTime scheduledTime,
  }) async {
    await initialize();

    final notificationTime = scheduledTime.subtract(const Duration(minutes: 1));    
    if (notificationTime.isBefore(DateTime.now())) {
      return;
    }

    final delay = notificationTime.difference(DateTime.now());
    
    final taskName = 'notification_$id';
    await Workmanager().registerOneOffTask(
      taskName,
      taskName,
      initialDelay: delay,
      inputData: {
        'title': title,
        'content': content,
        'id': id.hashCode.abs() % 2147483647, 
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

  static Future<void> scheduleLoanMaintenanceNotification({
    required String id,
    required String title,
    required String content,
    required DateTime scheduledTime,
    required int reminderDays,
  }) async {
    await initialize();

    // Schedule notification X days before at 9 AM
    final notificationTime = DateTime(
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day - reminderDays,8,  0,
    );
    
    // Only schedule if notification time is in the future
    if (notificationTime.isBefore(DateTime.now())) {
      print('Loan/Maintenance notification time is in the past, not scheduling');
      return;
    }

    print('Scheduling loan/maintenance notification for: $notificationTime');
    print('Reminder: $reminderDays days before due date');

    // 🔧 FIX: Use WorkManager instead of zonedSchedule for reliability
    final delay = notificationTime.difference(DateTime.now());
    final taskName = 'loan_maintenance_$id';

    await Workmanager().registerOneOffTask(
      taskName,
      taskName,
      initialDelay: delay,
      inputData: {
        'title': title,
        'content': '$content - Due in $reminderDays days',
        'id': id.hashCode.abs() % 2147483647,
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


  static Future<void> scheduleReminder({
    required String reminderId,      
    required String title,
    required String body,
    required DateTime fireAt,        
  }) async {
    await initialize();

    if (fireAt.isBefore(DateTime.now())) return;

    final delay = fireAt.difference(DateTime.now());

    await Workmanager().registerOneOffTask(
      reminderId,                 
      'event_reminder_task',     
      initialDelay: delay,
      inputData: {
        'title': title,
        'body': body,
        'id': reminderId.hashCode.abs() % 2147483647,
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

  static Future<void> cancelNotification(String id) async {
    final taskName1 = 'notification_$id';
    final taskName2 = 'loan_maintenance_$id';    
    try {
      await Workmanager().cancelByUniqueName(taskName1);
    } catch (e) {
    }
    
    try {
      await Workmanager().cancelByUniqueName(taskName2);
    } catch (e) {
    }
  }

  static Future<void> cancelAllNotifications() async {
    await Workmanager().cancelAll();
    await _notifications.cancelAll();
  }

  
  static Future<void> scheduleMaintenanceNotification({
      required String id,
      required String title,
      required String content,
      required DateTime scheduledTime,
    }) async {
      final now = DateTime.now();

      // Schedule notification 1 day before at 9 AM
      final oneDayBefore = DateTime(
        scheduledTime.year,
        scheduledTime.month,
        scheduledTime.day - 1,
        9,
        0,
      );

      // Schedule notification on due date at 9 AM
      final onDueDate = DateTime(
        scheduledTime.year,
        scheduledTime.month,
        scheduledTime.day,
        9,
        0,
      );

      print(' Scheduling maintenance notifications:');
      print('   ID: $id');
      print('   Due date: $scheduledTime');

      // Schedule 1-day before notification
      if (oneDayBefore.isAfter(now)) {
        final delay1Day = oneDayBefore.difference(now);
        print('   1-day reminder: $oneDayBefore (${delay1Day.inHours}h)');

        await Workmanager().registerOneOffTask(
          'maintenance_${id}_1day',
          'maintenanceNotification',
          initialDelay: delay1Day,
          inputData: {
            'id': '${id}_1day'.hashCode,
            'title': ' Maintenance Due Tomorrow',
            'body': content,
            'type': 'maintenance',
          },
        );
      }

      // Schedule due date notification
      if (onDueDate.isAfter(now)) {
        final delayDueDate = onDueDate.difference(now);
        print('   Due date reminder: $onDueDate (${delayDueDate.inHours}h)');

        await Workmanager().registerOneOffTask(
          'maintenance_$id',
          'maintenanceNotification',
          initialDelay: delayDueDate,
          inputData: {
            'id': id.hashCode,
            'title': ' Maintenance Due Today!',
            'body': content,
            'type': 'maintenance',
          },
        );
      }

      print(' Maintenance notifications scheduled');
    }
}