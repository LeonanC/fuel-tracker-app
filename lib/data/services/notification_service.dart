import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      // Solicita permissão de notificação e alarmes exatos
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  static Future<void> init() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _notifications.initialize(
      settings: InitializationSettings(android: android, iOS: ios),
    );
  }

  static Future<void> scheduleNotification(TimeOfDay time) async {
    await _notifications.cancelAll();
    final now = DateTime.now();
    var scheduleDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id: 0,
      title: 'Hora de abastecer?',
      body: 'Não esqueça de registrar seu consumo de combustível!',
      scheduledDate: tz.TZDateTime.from(scheduleDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'fuel_reminder_channel',
          'Lembretes de Combustível',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelAll() async => await _notifications.cancelAll();
}
