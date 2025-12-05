import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/models/reminder_model.dart';
import 'package:fuel_tracker_app/controllers/reminder_controller.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/unit_nums.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class NotificationRemindersSettingsScreen extends GetView<ReminderController> {
  const NotificationRemindersSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ReminderController>()) {
      Get.put(ReminderController());
    }

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final bgColor = isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight;
    final primaryColor = theme.colorScheme.primary;

    final ReminderController reminderController = controller;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text('Noficações e Lembretes'),
        elevation: theme.appBarTheme.elevation,
        centerTitle: theme.appBarTheme.centerTitle,
      ),
      body: Obx(() {
        final isEnabled = reminderController.isReminderEnabled.value;
        final selectedFreq = reminderController.selectedFrequency.value;
        return ListView(
          children: [
            SwitchListTile(
              title: Text('Lembretes de Registro'),
              subtitle: const Text('Receba notificações para registrar seu abastecimento.'),
              value: isEnabled,
              onChanged: reminderController.toggleReminder,
              secondary: const Icon(RemixIcons.notification_line),
              activeColor: primaryColor,
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16,16,16,8),
              child: Text(
                'Frequência do Lembrete:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...availableFrequencies.map((option){
              final bool isDisabled = !isEnabled;
              
              return RadioListTile<ReminderFrequency>(
                value: option.frequency,
                groupValue: selectedFreq,
                title: Text(option.title),
                subtitle: Text(option.subtitle),
                onChanged: isDisabled ? null : (ReminderFrequency? value){
                  if(value != null){
                    reminderController.setFrequency(value);
                  }
                },
                selected: option.frequency == selectedFreq,
                activeColor: Theme.of(context).colorScheme.primary,
              );
            }).toList(),
            const Divider(height: 1, thickness: 1),
            ListTile(
              enabled: isEnabled,
              leading: Icon(RemixIcons.time_line),
              title: const Text('Hora de Lembrete'),
              subtitle: Text(
                '{context.tr(TranslationKeys.reminderTimeSubtitlePrefix)} ${reminderController.selectedReminderTime.value.format(context)}.'),
              onTap: isEnabled ? () async {
                final TimeOfDay initialTime = reminderController.selectedReminderTime.value;

                final TimeOfDay? newTime = await showTimePicker(
                  context: context,
                  initialTime: initialTime,
                  builder: (context, child){
                    return Theme(
                      data: Theme.of(context).copyWith(),
                      child: child!,
                    );
                  }
                );

                if(newTime != null && newTime != initialTime){
                  reminderController.setReminderTime(newTime);
                }

              } : null,
            ),
            const Divider(height: 1, thickness: 1),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: const Text('Nota importante'),
              subtitle: const Text(
                'A entrega das notificações depende das configurações do sistema operacional do seu dispositivo.',
              ),
            ),
          ],
        );
      }),
    );
  }
}
