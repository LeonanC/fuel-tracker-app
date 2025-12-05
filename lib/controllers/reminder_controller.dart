import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/utils/unit_nums.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderController extends GetxController {
  static const String _enabledKey = 'remider_enabled';
  static const String _frequencyKey = 'remider_frequency';
  static const String _timeHourKey = 'remider_time_hour';
  static const String _timeMinuteKey = 'remider_time_minute';

  var isReminderEnabled = false.obs;
  var selectedFrequency = ReminderFrequency.daily.obs;
  var selectedReminderTime = TimeOfDay.now().obs;

  @override
  void onInit() {
    _loadReminders();
    super.onInit();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    isReminderEnabled.value = prefs.getBool(_enabledKey) ?? false;

    final freqIndex = prefs.getInt(_frequencyKey) ?? ReminderFrequency.daily.index;
    if (freqIndex >= 0 && freqIndex < ReminderFrequency.values.length) {
      selectedFrequency.value = ReminderFrequency.values[freqIndex];
    } else {
      selectedFrequency.value = ReminderFrequency.daily;
    }

    final hour = prefs.getInt(_timeHourKey) ?? 10;
    final minute = prefs.getInt(_timeMinuteKey) ?? 0;
    selectedReminderTime.value = TimeOfDay(hour: hour, minute: minute);
  }

  void _saveReminderPreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }

  void toggleReminder(bool value) {
    isReminderEnabled.value = value;
    _saveReminderPreference(_enabledKey, value);

    if (!value) {
      selectedFrequency.value = ReminderFrequency.disabled;
    } else {
      if (selectedFrequency.value == ReminderFrequency.disabled) {
        setFrequency(ReminderFrequency.daily);
      }
    }
    _showSnackbar(
      value ? 'Lembretes ativados' : 'Lembretes desativados',
      'Ajuste de ativação salvo.',
    );
  }

  void setFrequency(ReminderFrequency frequency) {
    if (!isReminderEnabled.value) {
      return;
    }

    if (frequency == ReminderFrequency.disabled) {
      toggleReminder(false);
      return;
    }

    selectedFrequency.value = frequency;
    _saveReminderPreference(_frequencyKey, frequency.index);
    _showSnackbar(
      'Frequência Atualizado',
      'Frequência de lembrete alterada para ${frequency.name}.',
    );
  }

  void setReminderTime(TimeOfDay newTime) {
    selectedReminderTime.value = newTime;
    _saveReminderPreference(_timeHourKey, newTime.hour);
    _saveReminderPreference(_timeMinuteKey, newTime.minute);
    _showSnackbar(
      'Hora Atualizado',
      'A hora do lembrete foi definida para ${newTime.format(Get.context!)}.',
    );
  }

  void _showSnackbar(String title, String message){
    Get.snackbar(
      title.tr,
      message.tr,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Get.theme.snackBarTheme.backgroundColor?.withOpacity(0.9) ?? const Color(0xFF673AB7).withOpacity(0.9),
      colorText: Get.theme.snackBarTheme.actionTextColor ?? Get.theme.colorScheme.onSecondary,
    );
  }
}
