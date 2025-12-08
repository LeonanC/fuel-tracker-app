import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/controllers/unit_controller.dart';
import 'package:fuel_tracker_app/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/screens/about_screen.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:fuel_tracker_app/utils/fuel_alert_card.dart';
import 'package:fuel_tracker_app/utils/fuel_list_filter_menu.dart';
import 'package:fuel_tracker_app/utils/overallConsumptionCard.dart';
import 'package:fuel_tracker_app/utils/unit_nums.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';

class FuelListScreen extends GetView<FuelListController> {
  const FuelListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FuelListController>()) {
      Get.put(FuelListController());
    }
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
      appBar: AppBar(
        title: Text(context.tr(TranslationKeys.listScreenAppBarTitle)),
        backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
        elevation: theme.appBarTheme.elevation,
        centerTitle: theme.appBarTheme.centerTitle,
        actions: [
          IconButton(
            icon: Icon(RemixIcons.refresh_line),
            tooltip: context.tr(TranslationKeys.listScreenRefresh),
            onPressed: () async {
              controller.loadFuelEntries();
              Get.snackbar(
                context.tr(TranslationKeys.listScreenRefreshing),
                '',
                duration: const Duration(seconds: 2),
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            tooltip: context.tr(TranslationKeys.aboutTitle),
            onPressed: () => Get.to(() => AboutScreen()),
          ),
          FuelListFilterMenu(),
        ],
      ),
      body: Obx(() {
        final fuel = controller.loadedEntries;

        if (fuel.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                context.tr('Nenhum abastecimento registrado.').tr,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final filteredEntries = controller.filteredEntries;

        return Column(
          children: [
            OverallConsumptionCard(),
            FuelAlertCard(),
            Expanded(
              child: filteredEntries.isEmpty
                  ? Center(
                      child: Text(
                        controller.selectedVehicleFilter.value != null ||
                                controller.selectedFuelTypeFilter.value != null ||
                                controller.selectedStationFilter.value != null
                            ? 'Nenhum item encontrado com os filtros aplicados.'
                            : 'Ainda não Abasteceu',
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredEntries.length,
                      itemBuilder: (context, index) {
                        final FuelEntry currentEntry = filteredEntries[index];
                        final FuelEntry? previousEntry = (index + 1 < filteredEntries.length)
                            ? filteredEntries[index + 1]
                            : null;

                        double consumptionForThisPeriod = 0.0;

                        if (previousEntry != null && previousEntry.tanqueCheio != 0) {
                          consumptionForThisPeriod = currentEntry.calculateConsumption(
                            previousEntry,
                          );
                        }

                        return FuelCard(
                          entry: currentEntry,
                          consumptionForThisPeriod: consumptionForThisPeriod,
                        );
                      },
                    ),
            ),
          ],
        );
      }),

      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_fuelentry_list',
        onPressed: () => controller.navigateToAddEntry(context),
        child: Icon(RemixIcons.gas_station_line, color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class FuelCard extends StatelessWidget {
  final FuelEntry entry;
  final double consumptionForThisPeriod;
  FuelCard({super.key, required this.entry, required this.consumptionForThisPeriod});

  final FuelListController controller = Get.find<FuelListController>();
  final UnitController unitController = Get.find<UnitController>();
  final CurrencyController currencyController = Get.find<CurrencyController>();

  Future<bool?> _deleteConfirmation(BuildContext context) async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: Text(context.tr(TranslationKeys.dialogDeleteTitle)),
        content: Text(context.tr(TranslationKeys.dialogDeleteContent)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(context.tr(TranslationKeys.dialogDeleteButtonCancel)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(context.tr(TranslationKeys.dialogDeleteButtonDelete)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final isMiles = unitController.distanceUnit.value == DistanceUnit.miles;

    final String dateOnly = DateFormat('dd/MM/yyyy').format(entry.dataAbastecimento);
    String titleText = dateOnly;

    if (entry.posto != null && entry.posto.isNotEmpty) {
      titleText += ' - ${entry.posto}';
    }

    final String distanceUnitStr = controller.getDistanceUnitString();
    final double odometerDisplay = isMiles
        ? entry.quilometragem * controller.kmToMileFactor
        : entry.quilometragem.toDouble();
    final String consumptionDisplay = controller.formatConsumption(consumptionForThisPeriod);
    final String consumptionUnitStr = controller.getConsumptionUnitString();

    String typeText = entry.tipo;

    String odoAndLiters =
        '${context.tr(TranslationKeys.commonLabelsOdometer)}: ${odometerDisplay.toStringAsFixed(0)} $distanceUnitStr| '
        '${context.tr(TranslationKeys.commonLabelsLiters)}: ${entry.litros.toStringAsFixed(2)} L';

    final consumptionUnit =
        '${context.tr(TranslationKeys.consumptionCardsConsumptionPeriod)}: $consumptionDisplay $consumptionUnitStr';

    String subtitleText = '$typeText\n$odoAndLiters\n$consumptionUnit';

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
      onDismissed: (direction) async {
        if (entry.id != null) {
          await controller.deleteEntry(entry.id!);
          Get.snackbar(
            context.tr(TranslationKeys.commonLabelsDeleteConfirmation),
            '',
            duration: const Duration(seconds: 2),
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.white,
          );
        }
      },
      child: Card(
        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          leading: Icon(
            entry.tanqueCheio == 1 ? RemixIcons.gas_station_fill : RemixIcons.gas_station_line,
            color: Theme.of(context).colorScheme.secondary,
          ),
          title: Text(
            titleText,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitleText),
          trailing: Obx(() {
            final currencySymbol = currencyController.currencySymbol.value;
            return Text(
              '$currencySymbol ${entry.totalPrice!.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }),
          // onTap: () => _showFuelForm(context, entry),
          onTap: () => controller.navigateToAddEntry(context, data: entry),
        ),
      ),
    );
  }
}

