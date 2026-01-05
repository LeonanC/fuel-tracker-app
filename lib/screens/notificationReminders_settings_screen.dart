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

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(title: const Text('Noficações e Lembretes'), elevation: 0, centerTitle: true),
      body: Obx(() {
        final isEnabled = controller.isReminderEnabled.value;

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            SwitchListTile(
              title: Text('Lembretes de Registro', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Receba notificações para registrar seu abastecimento.'),
              value: isEnabled,
              onChanged: controller.toggleReminder,
              secondary: Icon(
                RemixIcons.notification_line,
                color: isEnabled ? theme.colorScheme.primary : Colors.grey,
              ),
            ),
            const Divider(),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Frequência do Lembrete',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isEnabled ? theme.colorScheme.primary : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...availableFrequencies.map((option) {
              return RadioListTile<ReminderFrequency>(
                value: option.frequency,
                groupValue: controller.selectedFrequency.value,
                title: Text(option.title),
                subtitle: Text(option.subtitle),
                onChanged: isEnabled ? (val) => controller.setFrequency(val!) : null,
                activeColor: theme.colorScheme.primary,
              );
            }).toList(),

            const Divider(),
            ListTile(
              enabled: isEnabled,
              leading: Icon(RemixIcons.time_line),
              title: const Text('Hora de Lembrete'),
              subtitle: Text(
                'Notificar às ${controller.selectedReminderTime.value.format(context)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: isEnabled ? () => _selectTime(context) : null,
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isEnabled
                      ? theme.colorScheme.primary.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'A entrega das notificações depende das configurações de economa de bateria do seu sistema.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: controller.selectedReminderTime.value,
    );
  }
}
