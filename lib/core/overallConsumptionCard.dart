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

      final String formattedValue = controller.formatConsumption(
        overallConsumptionValue,
      );
      final String unitString = controller.getConsumptionUnitString();

      final bool isMiles =
          unitController.distanceUnit.value == DistanceUnit.miles;
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
                    color: Colors.indigo,
                    size: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(
                            TranslationKeys.consumptionCardsOverallAverage,
                          ),
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        Text(
                          isZero
                              ? context.tr(
                                  TranslationKeys
                                      .consumptionCardsNotAvailableShort,
                                )
                              : '$formattedValue $unitString',
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.w800,
                            color: Colors.grey,
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
                    color: Colors.redAccent,
                    size: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(
                            TranslationKeys
                                .consumptionCardsOverallCostPerDistance,
                          ),
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                        Text(
                          isCostZero
                              ? context.tr(
                                  TranslationKeys
                                      .consumptionCardsNotAvailableShort,
                                )
                              : '${costPerDistanceToDisplay.toStringAsFixed(2)} $costPerDistanceUnit',
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.w800,
                            color: Colors.grey,
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
