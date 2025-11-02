import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fuel_tracker_app/services/application.dart';
import 'package:fuel_tracker_app/services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  static const int reminderNotificationId = 100;

  TimeOfDay _selectedReminderTime = const TimeOfDay(hour: 18, minute: 0);
  ReminderFrequency _selectedFrequency = ReminderFrequency.onFirstEntry;
  bool _isReminderEnabled = true;

  TimeOfDay get selectedReminderTime => _selectedReminderTime;
  ReminderFrequency get selectedFrequency => _selectedFrequency;
  bool get isReminderEnabled => _isReminderEnabled;

  void _scheduleReminder(ReminderFrequency frequency) {
    notificationService.cancelNotification(reminderNotificationId);
    if (frequency == ReminderFrequency.disabled) {
      return;
    }

    final int hour = _selectedReminderTime.hour;
    final int minute = _selectedReminderTime.minute;

    const title = 'Hora de Abastecer!';
    const body =
        'Não se esquece de registrar seu consumo para manter os cálculos precisos.';

    switch (frequency) {
      case ReminderFrequency.daily:
        notificationService.scheduleDailyReminder(
          id: reminderNotificationId,
          hour: hour,
          minute: minute,
          title: title,
          body: body,
        );
        debugPrint('Lembrete diário agendado para: $hour:$minute');
        break;
      case ReminderFrequency.weekly:
        const day = Day.friday;
        notificationService.scheduleWeeklyReminder(
          id: reminderNotificationId,
          day: day,
          hour: hour,
          minute: minute,
          title: title,
          body: body,
        );
        debugPrint('Lembrete semanal agendado para sexta às: $hour:$minute');
        break;
      case ReminderFrequency.monthly:
        notificationService.scheduleDailyReminder(
          id: reminderNotificationId,
          hour: hour,
          minute: minute,
          title: 'Lembrete Mensal',
          body: body,
        );
        debugPrint('Lembrete mensal agendado para: $hour:$minute');
        break;
      case ReminderFrequency.onFirstEntry:
        final DateTime? lastEntryDate = DateTime.now().subtract(const Duration(days: 1));
        if(lastEntryDate == null){
          debugPrint('Não há registros de abastecimento para agendar onFirstEntry.');
        }

        const title = 'Hora de Registrar!';
        const body = 'Se passaram 7 dias desde seu último tanque cheio. É hora de registrar seu consumo!';

        final DateTime scheduledDate = lastEntryDate!.add(const Duration(days: 7));
        final DateTime scheduledDateTime = DateTime(
          scheduledDate.year,
          scheduledDate.month,
          scheduledDate.day,
          hour,
          minute,
        );

        notificationService.scheduleSingleReminder(
          id: reminderNotificationId,
          dateTime: scheduledDateTime,
          title: title,
          body: body,
        );

        debugPrint('Lembrete "OnFirstEntry" agendado para: $scheduledDateTime');

        break;
      case ReminderFrequency.disabled:
        //
      break;
    }
  }

  void setReminderTime(TimeOfDay newTime){
    _selectedReminderTime = newTime;
    if(_isReminderEnabled){
      _scheduleReminder(_selectedFrequency);
    }
    notifyListeners();
  }

  void toggleReminder(bool isEnabled) {
    _isReminderEnabled = isEnabled;
    if (!isEnabled) {
      _selectedFrequency = ReminderFrequency.disabled;
      _scheduleReminder(ReminderFrequency.disabled);
    } else if (_selectedFrequency == ReminderFrequency.disabled) {
      _selectedFrequency = ReminderFrequency.onFirstEntry;
      _scheduleReminder(_selectedFrequency);
    }
    notifyListeners();
  }

  void setFrequency(ReminderFrequency newFrequency) {
    _selectedFrequency = newFrequency;
    if (newFrequency != ReminderFrequency.disabled) {
      _isReminderEnabled = true;
      _scheduleReminder(newFrequency);
    } else {
      _isReminderEnabled = false;
      _scheduleReminder(ReminderFrequency.disabled);
    }
    notifyListeners();
  }
}
