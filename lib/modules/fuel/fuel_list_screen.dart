import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/core/fuel_alert_card.dart';
import 'package:fuel_tracker_app/core/fuel_list_filter_menu.dart';
import 'package:fuel_tracker_app/core/overallConsumptionCard.dart';
import 'package:fuel_tracker_app/data/services/application.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/gasStation_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/unit_controller.dart';
import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/modules/fuel/about_screen.dart';
import 'package:fuel_tracker_app/core/app_localizations.dart';
import 'package:fuel_tracker_app/core/unit_nums.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

abstract class TranslationKeysFuel {
  static const String listScreen = 'list_screen';
  static const String listScreenAppBarTitle = 'list_screen.app_bar_title';
  static const String listScreenRefresh = 'list_screen.refresh';
  static const String listScreenRefreshing = 'list_screen.refreshing';

  static const String listScreenSyncing = 'list_screen.syncing';
  static const String listScreenVehicleLabel = 'list_screen.vehicle_label';
  static const String listScreenNoVehicleFound = 'list_screen.no_vehicle_found';
  static const String listScreenNoRefuelYet = 'list_screen.no_refuel_yet';

  static const String listScreenSnackbarEntryAdded =
      'list_screen.snackbar_entry_added';
  static const String listScreenSnackbarEntryUpdated =
      'list_screen.snackbar_entry_updated';
  static const String listScreenSnackbarEntryRemoved =
      'list_screen.snackbar_entry_removed';
}

class FuelListScreen extends GetView<FuelListController> {
  const FuelListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text(context.tr(TranslationKeysFuel.listScreenAppBarTitle)),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(RemixIcons.refresh_line),
            tooltip: context.tr(TranslationKeysFuel.listScreenRefresh),
            onPressed: () async {
              Get.snackbar(
                context.tr(TranslationKeysFuel.listScreenRefreshing),
                'Sincronizando com a nuvem...',
                duration: const Duration(seconds: 2),
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
              controller.setupFuelStream();
            },
          ),
          FuelListFilterMenu(),
          IconButton(
            icon: Icon(Icons.info_outline),
            tooltip: context.tr(TranslationKeysAbout.aboutTitle),
            onPressed: () => Get.to(() => AboutScreen()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value)
          return const Center(child: CircularProgressIndicator());

        final filteredEntries = controller.filteredFuelEntries;

        final hasData = filteredEntries.isNotEmpty;
        final lastEntry = hasData ? filteredEntries.last : null;

        String vehicleName = "Todos os Veículos";
        if (controller.selectedVehicleID.value != null) {
          vehicleName =
              controller.veiculosMap[controller
                  .selectedVehicleID
                  .value]?['nickname'] ??
              "---";
        } else if (lastEntry != null) {
          vehicleName =
              controller.veiculosMap[lastEntry.vehicleId]?['nickname'] ?? "---";
        }

        final double fuelLevel = lastEntry?.tankCapacity ?? 0.0;
        final double progressValue = (fuelLevel / 100).clamp(0.0, 1.0);
        final bool isLastTankFull = lastEntry?.tankFull ?? false;

        return Column(
          children: [
            OverallConsumptionCard(),
            FuelAlertCard(),
            if (filteredEntries.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${context.tr(TranslationKeysFuel.listScreenVehicleLabel)}: $vehicleName',
                          style: GoogleFonts.lato(color: Colors.indigo),
                        ),
                        Text(
                          '${fuelLevel.toStringAsFixed(1)}%',
                          style: GoogleFonts.lato(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ShaderMask(
                      shaderCallback: (rect) => LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.redAccent,
                          Colors.orangeAccent,
                          isLastTankFull ? Colors.greenAccent : Colors.orange,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ).createShader(rect),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          minHeight: 12,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
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
                        filteredEntries.isEmpty
                            ? context.tr(
                                TranslationKeysFuel.listScreenNoVehicleFound,
                              )
                            : context.tr(
                                TranslationKeysFuel.listScreenNoRefuelYet,
                              ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: filteredEntries.length,
                      itemBuilder: (context, index) {
                        final currentEntry = filteredEntries[index];
                        final previousEntry =
                            (index + 1 < filteredEntries.length)
                            ? filteredEntries[index + 1]
                            : null;

                        double consumption = 0.0;
                        if (previousEntry != null &&
                            previousEntry.tankFull == true) {
                          consumption = currentEntry.calculateConsumption(
                            previousEntry,
                          );
                        }

                        return FuelCard(
                          entry: currentEntry,
                          consumptionForThisPeriod: consumption,
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
  FuelCard({
    super.key,
    required this.entry,
    required this.consumptionForThisPeriod,
  });

  final controller = Get.find<FuelListController>();
  final gasController = Get.find<GasStationController>();
  final unitController = Get.find<UnitController>();
  final currencyController = Get.find<CurrencyController>();

  @override
  Widget build(BuildContext context) {
    final String distUnit = controller.getDistanceUnitString();

    final isMiles = unitController.distanceUnit.value == DistanceUnit.miles;
    final double odometerDisplay = isMiles
        ? entry.odometerKm * controller.kmToMileFactor
        : entry.odometerKm.toDouble();
    final vehicleData = controller.veiculosMap[entry.vehicleId];
    final String nickname = vehicleData?['nickname'] ?? "---";
    final String plate = vehicleData?['plate'] ?? "";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => controller.navigateToEditEntry(context, entry),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        nickname,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      context.tr(TranslationKeysFuel.listScreenVehicleLabel),
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    if (plate.isNotEmpty)
                      _buildPlateTag(
                        plate,
                        vehicleData?['is_mercosul'] ?? false,
                      ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white10, height: 1),
                ),

                // INFO DE lOCALIZAÇÃO E COMBUSTÍVEL
                Row(
                  children: [
                    Icon(
                      RemixIcons.map_pin_2_fill,
                      size: 16,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${controller.postosMap[entry.gasStationId]?['nome']}',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildFuelTypeBadge(
                      '${controller.tiposMap[entry.fuelTypeId]?['nome']}',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // GRID DE DADOS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      RemixIcons.dashboard_3_line,
                      "Odómetro",
                      "${odometerDisplay.toStringAsFixed(0)} $distUnit",
                    ),
                    _buildStatItem(
                      RemixIcons.drop_line,
                      "Volume",
                      "${entry.volumeLiters.toStringAsFixed(2)} L",
                    ),
                    if (consumptionForThisPeriod > 0)
                      _buildConsumptionIndicator(consumptionForThisPeriod)
                    else if (entry.tankFull == true)
                      _buildStatItem(
                        RemixIcons.gas_station_fill,
                        "Tanque",
                        "Cheio",
                        color: Colors.orange,
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Preço p/ Litro: ",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            "${currencyController.currencySymbol.value} ${entry.pricePerLiter.toStringAsFixed(2)}",
                            style: GoogleFonts.firaCode(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Custo Total',
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                          Text(
                            '${currencyController.currencySymbol.value} ${entry.totalCost.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlateTag(String plate, bool isMercosul) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMercosul)
            Container(
              width: 12,
              height: 8,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: Colors.blue[900],
                borderRadius: BorderRadius.circular(1),
              ),
              child: Center(
                child: Icon(Icons.public, size: 6, color: Colors.white),
              ),
            ),
          Text(
            plate.toUpperCase(),
            style: GoogleFonts.robotoMono(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelTypeBadge(String text) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color ?? Colors.blueGrey),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildConsumptionIndicator(double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '${value.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            controller.getConsumptionUnitString(),
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
