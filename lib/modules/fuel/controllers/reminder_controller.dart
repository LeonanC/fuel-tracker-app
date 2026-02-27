import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/core/unit_nums.dart';
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

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isReminderEnabled.value = prefs.getBool('reminder_enabled') ?? false;

    final freqIndex = prefs.getInt('reminder_freq') ?? 0;
    selectedFrequency.value = ReminderFrequency.values[freqIndex];

    final hour = prefs.getInt('reminder_hour') ?? 18;
    final minute = prefs.getInt('reminder_minute') ?? 0;
    selectedReminderTime.value = TimeOfDay(hour: hour, minute: minute);
  }

  void toggleReminder(bool value) async {
    isReminderEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_enabled', value);

    if (value) {}
  }

  void setFrequency(ReminderFrequency freq) async {
    selectedFrequency.value = freq;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_freq', freq.index);
  }

  void setReminderTime(TimeOfDay time) async {
    selectedReminderTime.value = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', time.hour);
    await prefs.setInt('reminder_minute', time.minute);
  }
}
