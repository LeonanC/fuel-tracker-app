import 'package:fuel_tracker_app/services/application.dart';

class ReminderOption {
  final ReminderFrequency frequency;
  final String title;
  final String subtitle;

  const ReminderOption({
    required this.frequency,
    required this.title,
    required this.subtitle,
  });
}

final List<ReminderOption> availableFrequencies = [
  const ReminderOption(
    frequency: ReminderFrequency.disabled,
    title: 'Desativado',
    subtitle: 'Nenhum lembrete será agendado.'
  ),
  const ReminderOption(
    frequency: ReminderFrequency.daily,
    title: 'Diariamente',
    subtitle: 'Lembrar todos os dias para verificar o consumo.'
  ),
  const ReminderOption(
    frequency: ReminderFrequency.weekly,
    title: 'Semanalmente',
    subtitle: 'Lembrar a cada 7 dias para registrar o consumo.'
  ),
  const ReminderOption(
    frequency: ReminderFrequency.monthly,
    title: 'Mensalmente',
    subtitle: 'Lembrar uma vez por mês, no dia 1, para registro e balanço.'
  ),
  const ReminderOption(
    frequency: ReminderFrequency.onFirstEntry,
    title: 'Após primeiro abastecimento',
    subtitle: 'Lembrar 7 dias após o último registro de tanque cheio.'
  ),
];