import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database
    tzdata.initializeTimeZones();

    // Android initialization settings
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);

    // Explicitly create a notification channel on Android 8+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'habit_reminders',
      'Habit Reminders',
      description: 'Notifications for habit reminders',
      importance: Importance.high,
    );

    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(channel);

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    // Ensure plugin is initialized before requesting permissions
    await initialize();

    // Request notification permission
    final notificationStatus = await Permission.notification.request();
    
    // For Android 13+ (API 33+), also request POST_NOTIFICATIONS permission
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    return notificationStatus.isGranted;
  }

  Future<void> scheduleHabitReminder({
    required int id,
    required String habitTitle,
    required TimeOfDay reminderTime,
    required List<int> weekdays, // 1=Monday, 7=Sunday
  }) async {
    // Ensure plugin is initialized
    await initialize();

    // Cancel existing notification with this ID
    await _notifications.cancel(id);

    // Check permissions first
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('Notification permissions not granted');
    }

    // Schedule for each selected weekday
    for (int weekday in weekdays) {
      final scheduledDate = _nextInstanceOfWeekday(weekday, reminderTime);
      
      await _notifications.zonedSchedule(
        id + weekday, // Unique ID for each weekday
        'Habit Reminder',
        'Time to work on: $habitTitle',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_reminders',
            'Habit Reminders',
            channelDescription: 'Notifications for habit reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        androidAllowWhileIdle: true,
      );
    }
  }

  Future<void> cancelHabitReminder(int id) async {
    // Cancel all weekday variations of this habit
    for (int i = 1; i <= 7; i++) {
      await _notifications.cancel(id + i);
    }
  }

  tz.TZDateTime _nextInstanceOfWeekday(int weekday, TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Adjust to the correct weekday
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // If the time has already passed today, schedule for next week
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }

  List<int> getWeekdaysFromFrequency(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return [1, 2, 3, 4, 5, 6, 7]; // All days
      case 'weekdays':
        return [1, 2, 3, 4, 5]; // Monday to Friday
      case 'weekends':
        return [6, 7]; // Saturday and Sunday
      case 'weekly':
        return [1]; // Default to Monday for weekly
      default:
        return [1, 2, 3, 4, 5, 6, 7]; // Default to daily
    }
  }

  // Helper to show a test notification immediately
  Future<void> showTestNotification({String title = 'Test Notification', String body = 'Notifications are working'}) async {
    await initialize();
    await _notifications.show(
      999999, // arbitrary test ID
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Habit Reminders',
          channelDescription: 'Notifications for habit reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
