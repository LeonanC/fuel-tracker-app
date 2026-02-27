import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/core/app_localizations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FuelAlertCard extends StatelessWidget {
  FuelAlertCard({super.key});

  final FuelListController controller = Get.find<FuelListController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final alertData = controller.fuelAlertData;

      if (alertData == null) {
        return const SizedBox.shrink();
      }

      final versionLabel1 = context.tr(TranslationKeys.alertsThresholdMsg1);
      final versionLabel2 = context.tr(TranslationKeys.alertsThresholdMsg2);

      final vehicleName = alertData['vehicleName'] ?? "Veículo";
      final vehicleTank = alertData['tankCapcity'] ?? 0.0;
      final range = '${alertData['displayRange']} ${alertData['distanceUnit']}';
      final consumption =
          '${alertData['consumptionValue']} ${alertData['consumptionUnit']}';

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Card(
          color: Colors.orange[50],
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange[800],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehicleName.toUpperCase()} - Tanque Capacidade: ${vehicleTank.toString()}',
                        style: GoogleFonts.lato(
                          color: Colors.orange[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$versionLabel1 $range. $versionLabel2 $consumption',
                        style: GoogleFonts.lato(
                          color: Colors.orange[500],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
