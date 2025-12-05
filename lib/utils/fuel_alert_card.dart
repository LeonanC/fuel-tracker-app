import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:get/get.dart';

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
      final alertText0 = '${alertData['displayRange']} ${alertData['distanceUnit']}';
      final alertText1 = '${alertData['consumptionValue']} ${alertData['consumptionUnit']}';

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Card(
          color: Colors.orange[50],
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.local_gas_station, color: Colors.orange[800]),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    '$versionLabel1 $alertText0 $versionLabel2 $alertText1',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.orange[900],
                      fontWeight: FontWeight.bold,
                    ),
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
