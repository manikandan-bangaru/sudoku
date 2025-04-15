import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Initialize time zones and local notifications
  static Future<void> initialize() async {
    tz.initializeTimeZones();

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

    await _notificationsPlugin.initialize(initSettings);
  }

  /// Schedule a daily reminder at 7:00 PM
  static Future<void> scheduleDailyChallengeReminder() async {
    final isEnabled = await isNotificationsEnabled();  // Access the public method here
    if (isEnabled) {
      final scheduledDate = _nextInstanceOfTime(19, 0); // 7 PM

      await _notificationsPlugin.zonedSchedule(
        0,
        'Daily Challenge Reminder',
        'Time to complete today\'s challenge!',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_challenge_channel',
            'Daily Challenge',
            channelDescription: 'Reminds user to complete daily game challenge',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // Daily at 7 PM
      );
    }
  }


  Future<void> requestPermissionAndScheduleNotification() async {
    bool permissionGranted = false;

    // iOS: Request permission
    if (Platform.isIOS) {
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      permissionGranted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      ) ??
          false;
    }
    if (Platform.isAndroid) {
      final permissionStatus = await Permission.notification.request();
      permissionGranted = permissionStatus.isGranted;

      // Request SCHEDULE_EXACT_ALARM for Android 12+
      if (permissionGranted && await Permission.scheduleExactAlarm.isDenied) {
        final alarmStatus = await Permission.scheduleExactAlarm.request();
        permissionGranted = alarmStatus.isGranted;
        print("Schedule exact alarm permission: $alarmStatus");
      }
    }
    // Android: Request permission for API 33+ (Android 13)
    if (Platform.isAndroid && await Permission.scheduleExactAlarm.isDenied) {
      final permissionStatus = await Permission.notification.request();
      permissionGranted = permissionStatus.isGranted;
      print("Android notification permission: $permissionStatus");
    }

    if (await Permission.notification.status == true) {
      await scheduleDailyChallengeReminder();
      print("Notifications scheduled after permission granted");
    } else {
      print("Notification permission denied");
    }
  }

  /// Cancels the daily reminder
  static Future<void> cancelDailyReminder() async {
    await _notificationsPlugin.cancel(0);
  }

  /// Enable or Disable notifications based on the user setting
  static Future<void> setNotificationsEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', isEnabled);

    if (isEnabled) {
      scheduleDailyChallengeReminder(); // Reschedule if enabled
    } else {
      cancelDailyReminder(); // Cancel if disabled
    }
  }

  /// Returns true if notifications are enabled, false otherwise
  static Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true; // Default to true if not set
  }

  /// Returns the next occurrence of the specified time (e.g., 7:00 PM)
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> scheduleNotificationEverySecond() async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'test_channel_id',
        'Test Channel',
        channelDescription: 'Channel for test notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Schedule 5 notifications, 1 second apart
    for (int i = 0; i < 5; i++) {
      final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(seconds: i ));

      await _notificationsPlugin.zonedSchedule(
        i, // ID (can be unique or static)
        'Test Reminder ${i + 1}', // Title
        'This is test notification ${i + 1}!', // Body
        scheduledTime, // The scheduled time
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'test_$i',
      );
      print("Scheduled notification $i at $scheduledTime");
    }
  }
}