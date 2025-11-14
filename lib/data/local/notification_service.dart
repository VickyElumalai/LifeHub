import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database
    tz.initializeTimeZones();
    
    // Set local timezone (adjust to your timezone)
    // For India (Tiruvannamalai), use 'Asia/Kolkata'
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

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

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification clicked: ${response.payload}');
      },
    );
    
    _initialized = true;
    print('NotificationService initialized successfully');
  }

  static Future<void> scheduleTaskNotification({
    required String id,
    required String title,
    required String content,
    required DateTime scheduledTime,
  }) async {
    await initialize();

    // Schedule 1 MINUTE before
    final notificationTime = scheduledTime.subtract(const Duration(minutes: 1));
    
   

    try {
      // Convert to TZDateTime
      final tzNotificationTime = tz.TZDateTime.from(notificationTime, tz.local);
  
      await _notifications.zonedSchedule(
        id.hashCode,
        'Task Due Soon! ⏰',
        content,
        tzNotificationTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Task Reminders',
            channelDescription: 'Notifications for upcoming tasks',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            showWhen: true,
            enableLights: true,
            ledColor: const Color(0xFF667eea),
            ledOnMs: 1000,
            ledOffMs: 500,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
            ongoing: false,
            autoCancel: true,
            channelShowBadge: true,
            ticker: 'Task reminder',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
      
      
      // Verify pending notifications
      final pending = await _notifications.pendingNotificationRequests();
      for (var notification in pending) {
        print('   - ID: ${notification.id}, Title: ${notification.title}');
      }
    } catch (e) {
      print('   Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  static Future<void> cancelNotification(String id) async {
    await _notifications.cancel(id.hashCode);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Add method to check pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Add immediate test notification
  static Future<void> showTestNotification() async {
    await initialize();
    
    await _notifications.show(
      999999,
      ' Test Notification',
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
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
    
  }

  // Request all necessary permissions
  static Future<bool> requestPermissions() async {
    // Request notification permission
    final notificationStatus = await Permission.notification.request();
    
    // For Android 12+, request exact alarm permission
    if (await Permission.scheduleExactAlarm.isDenied) {
      final alarmStatus = await Permission.scheduleExactAlarm.request();
      print('Exact alarm permission: ${alarmStatus.isGranted}');
    }
    
    print('Notification permission: ${notificationStatus.isGranted}');
    
    return notificationStatus.isGranted;
  }
}