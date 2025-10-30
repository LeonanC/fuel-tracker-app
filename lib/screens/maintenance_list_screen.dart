import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/models/maintenance_entry_model.dart';
import 'package:fuel_tracker_app/provider/fuel_entry_provider.dart';
import 'package:fuel_tracker_app/provider/maintenance_provider.dart';
import 'package:fuel_tracker_app/screens/maintenance_entry_screen.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

class MaintenanceListScreen extends StatefulWidget {
  const MaintenanceListScreen({super.key});

  @override
  State<MaintenanceListScreen> createState() => _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends State<MaintenanceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaintenanceProvider>().loadMaintenanceEntries();
    });
  }

  void _navigateToAddEntry(BuildContext context) async {
    final MaintenanceProvider provider = context.read<MaintenanceProvider>();
    final currentOdometer = provider.lastOdometer;

    final entry = await Navigator.of(context).push<MaintenanceEntry>(
      MaterialPageRoute(builder: (context) => MaintenanceEntryScreen(
        lastOdometer: currentOdometer)));

    if (entry != null) {
      await provider.insertEntry(entry);
    }
  }

  Future<void> _deleteEntry(BuildContext context, MaintenanceEntry entry) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text(context.tr(TranslationKeys.commonLabelsDeleteConfirmation)),
          content: Text(context.tr(TranslationKeys.commonLabelsDeleteConfirmMessage)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.tr(TranslationKeys.commonLabelsCancel)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.tr(TranslationKeys.commonLabelsDelete)),
            ),
          ],
        );
      }
    );

    if(confirm == true && entry.id != null){
      final provider = context.read<MaintenanceProvider>();
      await provider.deleteEntry(entry.id!);
      
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final MaintenanceProvider maintenanceProvider = context.watch<MaintenanceProvider>();
    final provider = context.read<FuelEntryProvider>();
    final double? currentOdometer = context.watch<FuelEntryProvider>().lastOdometer;
    final double safeOdometer = currentOdometer ?? 0.0;

    final List<MaintenanceEntry> activeReminders = maintenanceProvider.getActiveReminders(safeOdometer);

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
      appBar: AppBar(
        title: Text(context.tr(TranslationKeys.maintenanceScreenTitle)),
        backgroundColor: theme.brightness == Brightness.dark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
        elevation: 0,
        centerTitle: false,
        actions: [IconButton(icon: const Icon(RemixIcons.refresh_line), onPressed: maintenanceProvider.loadMaintenanceEntries)],
      ),
      body: maintenanceProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildReminderAlertCard(context, activeReminders),
                Expanded(
                  child: maintenanceProvider.maintenanceEntries.isEmpty
                      ? Center(child: Text(context.tr(TranslationKeys.emptyStateMaintenanceMessage)))
                      : ListView.builder(
                          itemCount: maintenanceProvider.maintenanceEntries.length,
                          itemBuilder: (context, index) {
                            final entry = maintenanceProvider.maintenanceEntries[index];
                            return _buildMaintenanceListItem(context, entry);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_maintenance_list',
        onPressed: () => _navigateToAddEntry(context),
        child: const Icon(RemixIcons.tools_fill, color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildMaintenanceListItem(BuildContext context, MaintenanceEntry entry) {
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(RemixIcons.delete_bin_line, color: Colors.white),
      ),
      confirmDismiss: (direction) => _deleteConfirmation(context),
      onDismissed: (direction){
        _deleteEntry(context, entry);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: ListTile(
          leading: const Icon(RemixIcons.tools_line),
          title: Text(entry.tipo, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(
            '${context.tr(TranslationKeys.commonLabelsOdometer)}: ${entry.quilometragem.toStringAsFixed(0)} km\n ${context.tr(TranslationKeys.commonLabelsDate)}: ${DateFormat('dd/MM/yyyy').format(entry.dataServico)}',
          ),
          trailing: entry.custo != null ? Text('R\$ ${entry.custo!.toStringAsFixed(2)}') : null,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MaintenanceEntryScreen(entry: entry, lastOdometer: entry.quilometragem),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool?> _deleteConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text(context.tr(TranslationKeys.commonLabelsDeleteConfirmation)),
          content: Text(context.tr(TranslationKeys.commonLabelsDeleteConfirmMessage)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.tr(TranslationKeys.commonLabelsCancel)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.tr(TranslationKeys.commonLabelsDelete)),
            ),
            
          ],
        );
      }
    );
  }

  Widget _buildReminderAlertCard(BuildContext context, List<MaintenanceEntry> reminders) {
    if (reminders.isEmpty) return const SizedBox.shrink();

    return Card(
      color: Colors.red[50],
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr(TranslationKeys.maintenanceAlertTitle),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red[800], fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...reminders.map((remider) {
              String trigger = '';
              if (remider.lembreteKm != null) {
                trigger = context.tr(TranslationKeys.maintenanceAlertByKm, parameters: {'0': remider.lembreteKm!.toStringAsFixed(0)});
              } else if (remider.lembreteData != null) {
                trigger = context.tr(TranslationKeys.maintenanceAlertByDate, parameters: {'0': DateFormat('dd/MM/yyyy').format(remider.lembreteData!)});
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    Icon(RemixIcons.alert_fill, size: 18, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text('${remider.tipo}: $trigger', style: TextStyle(color: Colors.red[700])),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
