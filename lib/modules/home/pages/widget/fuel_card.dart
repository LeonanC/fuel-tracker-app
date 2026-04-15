import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class FuelCard extends StatelessWidget {
  final FuelEntryModel entry;
  final HomeController controller;
  const FuelCard({super.key, required this.entry, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vehicle = controller.veiculosMap[entry.vehicleId];
    final station = controller.postosMap[entry.gasStationId]?['nome'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: InkWell(
        onTap: () => controller.navigateToEditEntry(context, entry),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    vehicle?['nickname'] ?? "---",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  _plateWidget(
                    vehicle?['plate'] ?? "",
                    vehicle?['is_mercosul'] ?? false,
                  ),
                ],
              ),

              const Divider(color: Colors.white10, height: 24),

              // INFO DE lOCALIZAÇÃO E COMBUSTÍVEL
              _rowInfo(
                RemixIcons.map_pin_2_line,
                station,
                _badge(controller.tiposMap[entry.fuelTypeId]?['nome'] ?? "---"),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _miniStat(
                    "hp_odometro".tr,
                    controller.settingsController.formatarDistancia(
                      entry.odometerKm,
                    ),
                  ),
                  _miniStat(
                    "hp_volume".tr,
                    controller.settingsController.formatarVolume(
                      entry.volumeLiters,
                    ),
                  ),
                  if (entry.tankFull) _consumptionTag(),
                ],
              ),

              const SizedBox(height: 16),

              _priceFooter(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceFooter(ThemeData theme) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.black12,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Preço/L", style: TextStyle(fontSize: 9, color: Colors.grey)),
            Text(
              controller.settingsController.formatarCurrency(
                entry.pricePerLiter,
              ),
              style: GoogleFonts.firaCode(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Total pago",
              style: TextStyle(fontSize: 9, color: Colors.blueAccent),
            ),
            Text(
              controller.settingsController.formatarCurrency(entry.totalCost),
              style: GoogleFonts.inter(
                color: Colors.blueAccent,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _miniStat(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    ],
  );

  Widget _consumptionTag() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.green.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Text(
      "CHEIO",
      style: TextStyle(
        color: Colors.greenAccent,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _rowInfo(IconData icon, String text, Widget trailing) => Row(
    children: [
      Icon(icon, size: 16, color: Colors.blueAccent),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing,
    ],
  );

  Widget _badge(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 9,
        color: Colors.blueAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _plateWidget(String plate, bool mercosul) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(width: 1),
    ),
    child: Text(
      plate,
      style: GoogleFonts.robotoMono(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
    ),
  );
}
