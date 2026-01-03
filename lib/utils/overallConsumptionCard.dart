import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/controllers/unit_controller.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:fuel_tracker_app/utils/unit_nums.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class OverallConsumptionCard extends StatelessWidget {
  OverallConsumptionCard({super.key});

  final FuelListController controller = Get.find<FuelListController>();
  final UnitController unitController = Get.find<UnitController>();
  final CurrencyController currencyController = Get.find<CurrencyController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currencySymbol = currencyController.currencySymbol.value;
      final overallConsumptionValue = controller.overallConsumption.value;
      final overallCostPerDistance = controller.overallCostPerDistance;

      final isZero = overallConsumptionValue <= 0;
      final isCostZero = overallCostPerDistance <= 0;

      final String formattedValue = controller.formatConsumption(overallConsumptionValue);
      final String unitString = controller.getConsumptionUnitString();

      final bool isMiles = unitController.distanceUnit.value == DistanceUnit.miles;
      final double costPerDistanceToDisplay = isMiles
          ? (overallCostPerDistance / controller.kmToMileFactor)
          : overallCostPerDistance;

      final String distanceUnitStr = controller.getDistanceUnitString();
      final String costPerDistanceUnit = '$currencySymbol/$distanceUnitStr';

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    RemixIcons.dashboard_line,
                    color: Theme.of(context).colorScheme.primary,
                    size: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(TranslationKeys.consumptionCardsOverallAverage),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          isZero
                              ? context.tr(TranslationKeys.consumptionCardsNotAvailableShort)
                              : '$formattedValue $unitString',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isZero ? Colors.grey : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),

              Row(
                children: [
                  Icon(
                    RemixIcons.money_dollar_box_line,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(TranslationKeys.consumptionCardsOverallCostPerDistance),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          isCostZero
                              ? context.tr(TranslationKeys.consumptionCardsNotAvailableShort)
                              : '${costPerDistanceToDisplay.toStringAsFixed(2)} $costPerDistanceUnit',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isCostZero ? Colors.grey : Colors.green,
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
      );
    });
  }
}
