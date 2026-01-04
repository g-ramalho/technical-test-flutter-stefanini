import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technical_test_flutter_stefanini/models/clock_in_type.dart';
import 'package:technical_test_flutter_stefanini/models/shift_reminder.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
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

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> scheduleReminders() async {
    await _notifications.cancelAll();

    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('reminders_enabled') ?? false;

    if (!enabled) return;

    final remindersJson = prefs.getString('shift_reminders');
    if (remindersJson == null) return;

    final List<dynamic> decoded = jsonDecode(remindersJson);
    final reminders = decoded
        .map((e) => ShiftReminder.fromJson(e as Map<String, dynamic>))
        .toList();

    for (int i = 0; i < reminders.length; i++) {
      await _scheduleReminder(i, reminders[i]);
    }
  }

  Future<void> _scheduleReminder(int id, ShiftReminder reminder) async {
    final now = tz.TZDateTime.now(tz.local);
    
    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminder.scheduledTime.hour,
      reminder.scheduledTime.minute,
    ).subtract(Duration(minutes: reminder.minutesBefore));

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final timeFormat = '${reminder.scheduledTime.hour.toString().padLeft(2, '0')}:${reminder.scheduledTime.minute.toString().padLeft(2, '0')}';

    await _notifications.zonedSchedule(
      id,
      'Clock-In Reminder',
      '${reminder.type.label} in ${reminder.minutesBefore} minutes ($timeFormat)',
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'shift_reminders',
          'Shift Reminders',
          channelDescription: 'Notifications for upcoming clock-ins',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
