import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/global/unit_nums.dart';
import 'package:fuel_tracker_app/data/services/notification_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderController extends GetxController {
  var isReminderEnabled = false.obs;
  var selectedFrequency = ReminderFrequency.daily.obs;
  var selectedReminderTime = const TimeOfDay(hour: 18, minute: 0).obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  // No NotificationService

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isReminderEnabled.value = prefs.getBool('reminder_enabled') ?? false;

    final freqIndex = prefs.getInt('reminder_freq') ?? 0;
    selectedFrequency.value = ReminderFrequency.values[freqIndex];

    final hour = prefs.getInt('reminder_hour') ?? 18;
    final minute = prefs.getInt('reminder_minute') ?? 0;
    selectedReminderTime.value = TimeOfDay(hour: hour, minute: minute);

    if (isReminderEnabled.value) {
      NotificationService.scheduleNotification(selectedReminderTime.value);
    }
  }

  void toggleReminder(bool value) async {
    isReminderEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_enabled', value);

    if (value) {
      NotificationService.scheduleNotification(selectedReminderTime.value);
    } else {
      NotificationService.cancelAll();
    }
  }

  void setFrequency(ReminderFrequency freq) async {
    selectedFrequency.value = freq;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_freq', freq.index);

    if (isReminderEnabled.value) {
      NotificationService.scheduleNotification(selectedReminderTime.value);
    }
  }

  void setReminderTime(TimeOfDay time) async {
    selectedReminderTime.value = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', time.hour);
    await prefs.setInt('reminder_minute', time.minute);

    if (isReminderEnabled.value) {
      NotificationService.scheduleNotification(time);
    }
  }
}
