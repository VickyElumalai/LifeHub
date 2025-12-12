import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:life_hub/data/service/hive_service.dart';

// FIXED: WorkManager callback with sound/vibration settings support
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Load settings from Hive in background
      final soundEnabled = await HiveService.getData('settingsBox', 'sound') ?? true;
      final vibrationEnabled = await HiveService.getData('settingsBox', 'vibration') ?? true;
      
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

      // FIXED: Show notification with settings-based sound and vibration
      await notifications.show(
        id,
        '⏰ $title',
        content,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Task Reminders',
            channelDescription: 'Notifications for upcoming tasks',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: soundEnabled, // Use setting
            enableVibration: vibrationEnabled, // Use setting
            enableLights: true,
            ledColor: const Color(0xFF667eea),
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
      print('Error in notification callback: $e');
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
      isInDebugMode: false,
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

  /// FIXED: Check if notifications are enabled before scheduling
  static Future<bool> _areNotificationsEnabled() async {
    try {
      final notificationsEnabled = await HiveService.getData('settingsBox', 'notifications') ?? true;
      return notificationsEnabled;
    } catch (e) {
      print('Error checking notification settings: $e');
      return true; // Default to enabled if error
    }
  }

  /// Schedule task notification
  static Future<void> scheduleTaskNotification({
    required String id,
    required String title,
    required String content,
    required DateTime scheduledTime,
  }) async {
    // Check if notifications are enabled
    if (!await _areNotificationsEnabled()) {
      print('⏭️ Notifications disabled, skipping task notification');
      return;
    }

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

  // FIXED: Loan/Maintenance notification with settings check
  static Future<void> scheduleLoanMaintenanceNotification({
    required String id,
    required String title,
    required String content,
    required DateTime scheduledTime,
    required int reminderDays,
  }) async {
    // Check if notifications are enabled
    if (!await _areNotificationsEnabled()) {
      print('⏭️ Notifications disabled, skipping loan/maintenance notification');
      return;
    }

    await initialize();

    // Calculate notification time: reminderDays before at 9 AM
    final notificationDate = scheduledTime.subtract(Duration(days: reminderDays));
    final notificationTime = DateTime(
      notificationDate.year,
      notificationDate.month,
      notificationDate.day,
      9,  // 9 AM
      0,
    );
    
    // Only schedule if notification time is in the future
    if (notificationTime.isBefore(DateTime.now())) {
      print('❌ Loan/Maintenance notification time ($notificationTime) is in the past, not scheduling');
      return;
    }

    print('✅ Scheduling loan/maintenance notification:');
    print('   ID: $id');
    print('   Due date: $scheduledTime');
    print('   Notification time: $notificationTime (${reminderDays} days before at 9 AM)');

    final delay = notificationTime.difference(DateTime.now());
    final taskName = 'loan_maintenance_$id';

    await Workmanager().registerOneOffTask(
      taskName,
      taskName,
      initialDelay: delay,
      inputData: {
        'title': title,
        'content': '$content - Due in $reminderDays day${reminderDays > 1 ? 's' : ''}',
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
    
    print('✅ Successfully scheduled notification');
  }

  static Future<void> scheduleReminder({
    required String reminderId,      
    required String title,
    required String body,
    required DateTime fireAt,        
  }) async {
    // Check if notifications are enabled
    if (!await _areNotificationsEnabled()) {
      print('⏭️ Notifications disabled, skipping reminder');
      return;
    }

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
      // Ignore if task doesn't exist
    }
    
    try {
      await Workmanager().cancelByUniqueName(taskName2);
    } catch (e) {
      // Ignore if task doesn't exist
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
      // Check if notifications are enabled
      if (!await _areNotificationsEnabled()) {
        print('⏭️ Notifications disabled, skipping maintenance notification');
        return;
      }

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

      print('📅 Scheduling maintenance notifications:');
      print('   ID: $id');
      print('   Due date: $scheduledTime');

      // Schedule 1-day before notification
      if (oneDayBefore.isAfter(now)) {
        final delay1Day = oneDayBefore.difference(now);
        print('   ✅ 1-day reminder: $oneDayBefore (${delay1Day.inHours}h from now)');

        await Workmanager().registerOneOffTask(
          'maintenance_${id}_1day',
          'maintenanceNotification',
          initialDelay: delay1Day,
          inputData: {
            'id': '${id}_1day'.hashCode,
            'title': '🔧 Maintenance Due Tomorrow',
            'body': content,
            'type': 'maintenance',
          },
        );
      } else {
        print('   ⏭️ 1-day reminder in past, skipping');
      }

      // Schedule due date notification
      if (onDueDate.isAfter(now)) {
        final delayDueDate = onDueDate.difference(now);
        print('   ✅ Due date reminder: $onDueDate (${delayDueDate.inHours}h from now)');

        await Workmanager().registerOneOffTask(
          'maintenance_$id',
          'maintenanceNotification',
          initialDelay: delayDueDate,
          inputData: {
            'id': id.hashCode,
            'title': '🔧 Maintenance Due Today!',
            'body': content,
            'type': 'maintenance',
          },
        );
      } else {
        print('   ⏭️ Due date reminder in past, skipping');
      }

      print('✅ Maintenance notifications scheduled');
    }
}