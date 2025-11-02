import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/models/reminder_model.dart';
import 'package:fuel_tracker_app/provider/reminder_provider.dart';
import 'package:fuel_tracker_app/services/application.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

class NotificationRemindersSettingsScreen extends StatelessWidget {
  const NotificationRemindersSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ReminderProvider>();
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
        title: const Text('Noficações e Lembretes'),
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Lembretes de Registro'),
            subtitle: const Text('Receba notificações para registrar seu abastecimento.'),
            value: provider.isReminderEnabled,
            onChanged: (bool value){
              provider.toggleReminder(value);
            },
            secondary: const Icon(RemixIcons.notification_line),
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
            final bool isDisabled = 
              !provider.isReminderEnabled && option.frequency != ReminderFrequency.disabled;
            return RadioListTile<ReminderFrequency>(
              value: option.frequency,
              groupValue: provider.selectedFrequency,
              title: Text(option.title),
              subtitle: Text(option.subtitle),
              onChanged: isDisabled ? null : (ReminderFrequency? value){
                if(value != null){
                  provider.setFrequency(value);
                }
              },
              selected: option.frequency == provider.selectedFrequency,
              activeColor: Theme.of(context).colorScheme.primary,
            );
          }).toList(),
          const Divider(height: 1, thickness: 1),
          ListTile(
            leading: Icon(RemixIcons.time_line),
            title: const Text('Hora de Lembrete'),
            subtitle: Text(
              'Os lembretes são enviados diariamente às ${provider.selectedReminderTime.format(context)}.'),
            onTap: provider.isReminderEnabled ? () async {
              final TimeOfDay initialTime = provider.selectedReminderTime;

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
                provider.setReminderTime(newTime);
              }

            } : null,
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: const Text('Nota importante'),
            subtitle: const Text('A entrega das notificações depende das configurações do sistema operacional do seu dispositivo.'),
          ),
        ],
      ),
    );
  }
}