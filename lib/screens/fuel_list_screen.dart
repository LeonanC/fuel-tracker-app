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
              Get.snackbar(
                'Atualizando',
                context.tr(TranslationKeys.listScreenRefreshing),
                duration: const Duration(seconds: 2),
                snackPosition: SnackPosition.BOTTOM,
              );
              await controller.loadFuel();
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
        final fuel = controller.fuelEntries;

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
        final lastEntry = filteredEntries.isNotEmpty ? filteredEntries.last : null;
        final bool isLastTankFull = lastEntry?.tankFull == 1;
        final double fuelLevel = lastEntry?.vehicleTank ?? 0.0;
        final String vehicleName = lastEntry?.vehicleName ?? "";

        return Column(
          children: [
            OverallConsumptionCard(),
            FuelAlertCard(),
            if (filteredEntries.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Nível: $vehicleName",
                          style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "$fuelLevel",
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isLastTankFull ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: fuelLevel,
                        minHeight: 10,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isLastTankFull ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                        final FuelEntryModel currentEntry = filteredEntries[index];
                        final FuelEntryModel? previousEntry = (index + 1 < filteredEntries.length)
                            ? filteredEntries[index + 1]
                            : null;

                        double consumptionForThisPeriod = 0.0;

                        if (previousEntry != null && previousEntry.tankFull == 1) {
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
  final FuelEntryModel entry;
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
    final String distUnit = controller.getDistanceUnitString();

    final isMiles = unitController.distanceUnit.value == DistanceUnit.miles;
    final double odometerDisplay = isMiles
        ? entry.odometerKm * controller.kmToMileFactor
        : entry.odometerKm.toDouble();

    

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
      onDismissed: (direction) => controller.deleteEntry(entry.id!),
      child: Card(
        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => controller.navigateToAddEntry(context, data: entry),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.vehicleName ?? "Veículo não identificado",
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if(entry.vehiclePlate != true)
                      _buildNewMiniPlate(entry.vehiclePlate!)
                    else
                      _buildMiniPlate(entry.vehiclePlate!, entry.vehicleCity!),
                  ],
                ),
                const Divider(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(RemixIcons.map_pin_line, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        entry.stationName ?? "Posto não identificado",
                        style: theme.textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      _buildBadge(entry.fuelTypeName ?? "Combustível", theme),
                    ],
                  ),
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    _buildInfoItem(
                      RemixIcons.dashboard_3_line,
                      "${odometerDisplay.toStringAsFixed(0)} $distUnit",
                    ),
                    _buildInfoItem(
                      RemixIcons.drop_line,
                      "${entry.volumeLiters.toStringAsFixed(2)} L",
                    ),
                    SizedBox(width: 10),
                    if (entry.tankFull == 1)
                      _buildInfoItem(RemixIcons.gas_station_fill, "Cheio", color: Colors.orange),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Preço/L: ${currencyController.currencySymbol.value} ${entry.pricePerLiter.toStringAsFixed(2)}",
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          DateFormat.yMMMd().add_Hm().format(entry.entryDate),
                          style: theme.textTheme.bodySmall,
                        ),
                        if (consumptionForThisPeriod > 0)
                          Text(
                            '${controller.formatConsumption(consumptionForThisPeriod)} ${controller.getConsumptionUnitString()}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total',
                            style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                          ),
                          Text(
                            '${currencyController.currencySymbol.value} ${entry.totalCost.toStringAsFixed(2)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewMiniPlate(String plateText) {
    return Container(
      width: 80,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(2),
                topRight: Radius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                plateText,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1,
                  fontFamily: 'Monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlate(String plateText, String city) {
    return Container(
      width: 80,
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        color: Color(0xFFB0B0B0),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Color(0xFF9EA7A7), width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 1, offset: Offset(0, 1))],
      ),
      child: Column(
        children: [
          Container(
            height: 8,
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF8A9393), width: 0.5)),
              borderRadius: BorderRadius.circular(1),
            ),
            child: Row(
              children: [
                _buildParafuso(),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      city.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                _buildParafuso(),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  plateText.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParafuso(){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      width: 1.5,
      height: 1.5,
      decoration: const BoxDecoration(
        color: Colors.black45,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildBadge(String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
