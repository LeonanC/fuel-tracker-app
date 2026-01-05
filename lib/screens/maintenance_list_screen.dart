import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/controllers/unit_controller.dart';
import 'package:fuel_tracker_app/models/maintenance_entry_model.dart';
import 'package:fuel_tracker_app/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/controllers/maintenance_controller.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';

class MaintenanceListScreen extends GetView<MaintenanceController> {
  const MaintenanceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fuelListController = Get.find<FuelListController>();
    final unitController = Get.find<UnitController>();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
      appBar: AppBar(
        title: Text(context.tr(TranslationKeys.maintenanceScreenTitle)),
        backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(RemixIcons.refresh_line),
            onPressed: () => controller.loadMaintenanceEntries(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final safeOdometer = fuelListController.lastOdometer.value ?? 0.0;
        final entries = controller.loadedEntries;
        final activeReminders = controller.getActiveReminders(safeOdometer);

        return RefreshIndicator(
          onRefresh: () => controller.loadMaintenanceEntries(),
          child: Column(
            children: [
              _buildReminderAlertCard(context, activeReminders),
              Expanded(
                child: entries.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: entries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) => _MaintenanceItem(
                          entry: entries[index],
                          unitLabel: unitController.distanceUnit.value.name,
                          currencySymbol: unitController.currencyUnitString,
                        ),
                      ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_maintenance_list',
        onPressed: () => controller.navigateToAddEntry(context),
        child: const Icon(RemixIcons.tools_fill, color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(RemixIcons.tools_line, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(context.tr(TranslationKeys.emptyStateMaintenanceMessage)),
        ],
      ),
    );
  }

  Widget _buildReminderAlertCard(BuildContext context, List<MaintenanceEntry> reminders) {
    if (reminders.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(RemixIcons.error_warning_fill, color: Colors.redAccent),
              const SizedBox(width: 8),
              Text(
                context.tr(TranslationKeys.maintenanceAlertTitle),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...reminders.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• ${r.tipo}', style: TextStyle(color: Colors.red[700], fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaintenanceItem extends StatelessWidget {
  final MaintenanceEntry entry;
  final String unitLabel;
  final String currencySymbol;
  const _MaintenanceItem({
    required this.entry,
    required this.unitLabel,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MaintenanceController>();

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _confirmDeletion(context),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(RemixIcons.delete_bin_line, color: Colors.white),
      ),
      onDismissed: (_) => controller.deleteMaintenance(entry.id!),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(RemixIcons.tools_line, color: Theme.of(context).colorScheme.primary),
          ),
          title: Text(entry.tipo, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            '${entry.quilometragem.toStringAsFixed(0)} $unitLabel • ${DateFormat('dd/MM/yyyy').format(entry.dataServico)}',
          ),
          trailing: entry.custo != null
              ? Text(
                  '$currencySymbol ${entry.custo!.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                )
              : null,
          onTap: () => controller.navigateToAddEntry(context, data: entry),
        ),
      ),
    );
  }

  Future<bool?> _confirmDeletion(BuildContext context) async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: Text(context.tr(TranslationKeys.commonLabelsDeleteConfirmation)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(context.tr(TranslationKeys.commonLabelsCancel)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Get.back(result: true),
            child: Text(context.tr(TranslationKeys.commonLabelsDelete)),
          ),
        ],
      ),
    );
  }
}
