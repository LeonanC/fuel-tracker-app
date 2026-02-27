import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/theme_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/unit_controller.dart';
import 'package:fuel_tracker_app/core/app_theme.dart';
import 'package:fuel_tracker_app/core/app_localizations.dart';
import 'package:fuel_tracker_app/core/unit_nums.dart';
import 'package:get/get.dart';

class UnitSettingsScreen extends GetView<UnitController> {
  const UnitSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final UnitController unitController = controller;
    final ThemeController themeController = Get.find<ThemeController>();

    final backgroundColor = isDarkMode
        ? AppTheme.backgroundColorDark
        : AppTheme.backgroundColorLight;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final dividerColor = isDarkMode ? Colors.white12 : Colors.black12;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(context.tr(TranslationKeys.unitSettingsScreenTitle)),
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                context.tr(TranslationKeys.unitSettingsScreenSubtitle),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor.withOpacity(0.6),
                ),
              ),
            ),
            _buildRowItem(
              title: context.tr(TranslationKeys.unitSettingsScreenDistance),
              child: _buildDropdown<DistanceUnit>(
                value: unitController.distanceUnit.value,
                items: {
                  DistanceUnit.kilometers: context.tr(
                    TranslationKeys.unitSettingsScreenKilometers,
                  ),
                  DistanceUnit.miles: context.tr(
                    TranslationKeys.unitSettingsScreenMiles,
                  ),
                },
                onChanged: unitController.setDistanceUnit,
                isDarkMode: isDarkMode,
              ),
            ),
            Divider(color: dividerColor),

            _buildRowItem(
              title: context.tr(TranslationKeys.unitSettingsScreenVolume),
              child: _buildDropdown<VolumeUnit>(
                value: unitController.volumeUnit.value,
                items: {
                  VolumeUnit.liters: context.tr(
                    TranslationKeys.unitSettingsScreenLiters,
                  ),
                  VolumeUnit.gallons: context.tr(
                    TranslationKeys.unitSettingsScreenGallons,
                  ),
                },
                onChanged: unitController.setVolumeUnit,
                isDarkMode: isDarkMode,
              ),
            ),
            Divider(color: dividerColor),
            _buildRowItem(
              title: context.tr(TranslationKeys.unitSettingsScreenConsumption),
              child: _buildDropdown<ConsumptionUnit>(
                value: unitController.consumptionUnit.value,
                items: {
                  ConsumptionUnit.kmPerLiter: context.tr(
                    TranslationKeys.unitSettingsScreenKmPerLiter,
                  ),
                  ConsumptionUnit.litersPer100km: context.tr(
                    TranslationKeys.unitSettingsScreenLitersPer100km,
                  ),
                  ConsumptionUnit.milesPerGallon: context.tr(
                    TranslationKeys.unitSettingsScreenMpg,
                  ),
                },
                onChanged: unitController.setConsumptionUnit,
                isDarkMode: isDarkMode,
              ),
            ),
            Divider(color: dividerColor),
            _buildRowItem(
              title: context.tr(TranslationKeys.toolsScreenCurrencyCardTitle),
              child: _buildDropdown<CurrencyUnit>(
                value: unitController.currencyUnit.value,
                items: {
                  CurrencyUnit.brl: context.tr(
                    TranslationKeys.unitSettingsScreenBRL,
                  ),
                  CurrencyUnit.usd: context.tr(
                    TranslationKeys.unitSettingsScreenUSD,
                  ),
                  CurrencyUnit.eur: context.tr(
                    TranslationKeys.unitSettingsScreenEUR,
                  ),
                },
                onChanged: (unit) {
                  unitController.setCurrencyUnit(unit);
                },
                isDarkMode: isDarkMode,
              ),
            ),
            Divider(color: dividerColor),
            _buildRowItem(
              title: context.tr(TranslationKeys.themeSectionTitle),
              child: _buildDropdown<ThemeMode>(
                value: themeController.themeMode.value,
                items: {
                  ThemeMode.system: context.tr(
                    TranslationKeys.themeOptionSystem,
                  ),
                  ThemeMode.light: context.tr(TranslationKeys.themeOptionLight),
                  ThemeMode.dark: context.tr(TranslationKeys.themeOptionDark),
                },
                onChanged: themeController.setThemeMode,
                isDarkMode: isDarkMode,
              ),
            ),
            Divider(color: dividerColor),
            const SizedBox(height: 16),
            _buildFontScaleSlider(context, themeController, textColor),
          ],
        );
      }),
    );
  }

  Widget _buildRowItem({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdown<T extends Object>({
    required T value,
    required Map<T, String> items,
    required void Function(T?) onChanged,
    required bool isDarkMode,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        dropdownColor: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppTheme.primaryFuelColor,
        ),
        onChanged: onChanged,
        items: items.entries.map((entry) {
          return DropdownMenuItem<T>(
            value: entry.key,
            child: Text(entry.value, style: const TextStyle(fontSize: 15)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFontScaleSlider(
    BuildContext context,
    ThemeController themeController,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr(TranslationKeys.fontSizeSectionTitle),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Slider(
          value: themeController.fontScale.value,
          min: 0.8,
          max: 1.2,
          divisions: 4,
          label: '${(themeController.fontScale.value * 100).round()}%',
          activeColor: AppTheme.primaryFuelColor,
          onChanged: themeController.setFontScale,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pequena'.tr,
                style: TextStyle(
                  color: textColor.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              Text(
                'Padrão'.tr,
                style: TextStyle(
                  color: textColor.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              Text(
                'Grande'.tr,
                style: TextStyle(
                  color: textColor.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
