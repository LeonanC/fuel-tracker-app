import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/core/fuel_alert_card.dart';
import 'package:fuel_tracker_app/core/fuel_list_filter_menu.dart';
import 'package:fuel_tracker_app/core/overallConsumptionCard.dart';
import 'package:fuel_tracker_app/data/services/application.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/unit_controller.dart';
import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/modules/fuel/about_screen.dart';
import 'package:fuel_tracker_app/core/app_theme.dart';
import 'package:fuel_tracker_app/core/app_localizations.dart';
import 'package:fuel_tracker_app/core/unit_nums.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class FuelListScreen extends GetView<FuelListController> {
  const FuelListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text(context.tr(TranslationKeys.listScreenAppBarTitle)),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(RemixIcons.refresh_line),
            tooltip: context.tr(TranslationKeys.listScreenRefresh),
            onPressed: () async {
              Get.snackbar(
                context.tr(TranslationKeys.listScreenRefreshing),
                'Sincronizando com a nuvem...',
                duration: const Duration(seconds: 2),
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
              await controller.loadFuel();
            },
          ),
          FuelListFilterMenu(),
          IconButton(
            icon: Icon(Icons.info_outline),
            tooltip: context.tr(TranslationKeys.aboutTitle),
            onPressed: () => Get.to(() => AboutScreen()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value)
          return const Center(child: CircularProgressIndicator());

        final filteredEntries = controller.filteredFuelEntries;
        final lastEntry = filteredEntries.isNotEmpty
            ? filteredEntries.last
            : null;
        final bool isLastTankFull = lastEntry?.tankFull == true;
        final double fuelLevel = lastEntry?.tankCapacity ?? 0.0;
        final vehicleInfo = controller.veiculosMap[lastEntry?.vehicleId];
        final String vehicleName = vehicleInfo?['nickname'] ?? '';

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
                          'Veículo: $vehicleName',
                          style: GoogleFonts.lato(color: Colors.indigo),
                        ),
                        Text(
                          '$fuelLevel',
                          style: GoogleFonts.lato(color: Colors.indigoAccent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: fuelLevel,
                        minHeight: 10,
                        backgroundColor: Colors.orange,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isLastTankFull ? Colors.green : Colors.orangeAccent,
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
                            ? 'Nenhum veiculo encontrado.'
                            : 'Ainda não abasteceu',
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
  final unitController = Get.find<UnitController>();
  final currencyController = Get.find<CurrencyController>();

  @override
  Widget build(BuildContext context) {
    final String distUnit = controller.getDistanceUnitString();

    final isMiles = unitController.distanceUnit.value == DistanceUnit.miles;
    final double odometerDisplay = isMiles
        ? entry.odometerKm * controller.kmToMileFactor
        : entry.odometerKm.toDouble();

    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.navigateToEditEntry(context, entry),
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
                      controller.veiculosMap[entry.vehicleId]?['nickname'] ??
                          "Veículo não identificado",
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (controller.veiculosMap[entry.vehicleId]?['plate'] != true)
                    _buildNewMiniPlate(
                      '${controller.veiculosMap[entry.vehicleId]?['plate']!}',
                    )
                  else
                    _buildMiniPlate(
                      '${controller.veiculosMap[entry.vehicleId]?['city']!}',
                      '${controller.veiculosMap[entry.vehicleId]?['plate']!}',
                    ),
                ],
              ),
              const Divider(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      RemixIcons.map_pin_line,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${controller.postosMap[entry.gasStationId]?['nome']} - ${doubleToCurrency(controller.postosMap[entry.gasStationId]?['preco'])}',
                      style: GoogleFonts.lato(color: Colors.white),
                    ),
                    const Spacer(),
                    _buildBadge(
                      '${controller.tiposMap[entry.fuelTypeId]?['nome']}',
                    ),
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
                  if (entry.tankFull == true)
                    _buildInfoItem(
                      RemixIcons.gas_station_fill,
                      "Cheio",
                      color: Colors.orange,
                    ),
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
                        style: GoogleFonts.lato(color: Colors.white),
                      ),
                      if (consumptionForThisPeriod > 0)
                        Text(
                          '${controller.formatConsumption(consumptionForThisPeriod)} ${controller.getConsumptionUnitString()}',
                          style: GoogleFonts.lato(color: Colors.green),
                        ),
                    ],
                  ),
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total',
                          style: GoogleFonts.lato(color: Colors.grey),
                        ),
                        Text(
                          '${currencyController.currencySymbol.value} ${entry.totalCost.toStringAsFixed(2)}',
                          style: GoogleFonts.lato(color: Colors.indigo),
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
    );
  }
}

Widget _buildNewMiniPlate(String plateText) {
  return Container(
    width: 80,
    height: 30,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: Colors.black, width: 1.5),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 2)),
      ],
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
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 1, offset: Offset(0, 1)),
      ],
    ),
    child: Column(
      children: [
        Container(
          height: 8,
          margin: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFF8A9393), width: 0.5),
            ),
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

Widget _buildParafuso() {
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

Widget _buildBadge(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.indigo,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.white,
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
