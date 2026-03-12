import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/unit_controller.dart';
import 'package:fuel_tracker_app/core/app_localizations.dart';
import 'package:fuel_tracker_app/core/unit_nums.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class OverallConsumptionCard extends StatelessWidget {
  OverallConsumptionCard({super.key});

  final controller = Get.find<FuelListController>();
  final currencyController = Get.find<CurrencyController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final avgCons = controller.averageConsumption;
      final avgCost = controller.averageCostPerKm;
      final distUnit = controller.getDistanceUnitString();
      final currency = currencyController.currencySymbol.value;

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildStatRow(
              icon: RemixIcons.layout_grid_line,
              iconColor: Colors.blueAccent,
              label: "Consumo Médio Geral",
              value: "${avgCons.toStringAsFixed(2)} $distUnit/L",
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.white10, height: 1),
            ),
            _buildStatRow(
              icon: RemixIcons.money_dollar_box_line,
              iconColor: Colors.redAccent,
              label: "Custo por Distância Total",
              value: "$currency ${avgCost.toStringAsFixed(2)}/$distUnit",
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: iconColor.withOpacity(0.8),
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.firaCode(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
