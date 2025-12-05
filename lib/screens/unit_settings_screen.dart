import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/controllers/theme_controller.dart';
import 'package:fuel_tracker_app/controllers/unit_controller.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:fuel_tracker_app/utils/unit_nums.dart';
import 'package:get/get.dart';

class UnitSettingsScreen extends GetView<UnitController> {
  const UnitSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<UnitController>()) {
      Get.put(UnitController());
    }
    if (!Get.isRegistered<ThemeController>()) {
      Get.put(ThemeController());
    }

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final UnitController unitController = controller;

    final backgroundColor = isDarkMode
        ? AppTheme.backgroundColorDark
        : AppTheme.backgroundColorLight;
    final primaryTextColor = isDarkMode
        ? AppTheme.backgroundColorLight
        : AppTheme.backgroundColorDark;

    final dropdownTextStyle = TextStyle(fontSize: 16, color: primaryTextColor);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(context.tr(TranslationKeys.unitSettingsScreenTitle)),
        backgroundColor: theme.brightness == Brightness.dark
            ? AppTheme.backgroundColorDark
            : AppTheme.backgroundColorLight,
        elevation: 0,
        centerTitle: false,
      ),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              context.tr(TranslationKeys.unitSettingsScreenSubtitle),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: primaryTextColor.withOpacity(0.7)),
            ),
            const SizedBox(height: 24),
            _buildUnitDropdown<DistanceUnit>(
              context,
              title: context.tr(TranslationKeys.unitSettingsScreenDistance),
              value: unitController.distanceUnit.value,
              items: {
                DistanceUnit.kilometers: context.tr(TranslationKeys.unitSettingsScreenKilometers),
                DistanceUnit.miles: context.tr(TranslationKeys.unitSettingsScreenMiles),
              },
              onChanged: unitController.setDistanceUnit,
              textStyle: dropdownTextStyle,
            ),
            const Divider(color: AppTheme.cardDark),
            const SizedBox(height: 8),
            _buildUnitDropdown<VolumeUnit>(
              context,
              title: context.tr(TranslationKeys.unitSettingsScreenVolume),
              value: unitController.volumeUnit.value,
              items: {
                VolumeUnit.liters: context.tr(TranslationKeys.unitSettingsScreenLiters),
                VolumeUnit.gallons: context.tr(TranslationKeys.unitSettingsScreenGallons),
              },
              onChanged: unitController.setVolumeUnit,
              textStyle: dropdownTextStyle,
            ),
            const Divider(color: AppTheme.cardDark),
            const SizedBox(height: 8),
            _buildUnitDropdown<ConsumptionUnit>(
              context,
              title: context.tr(TranslationKeys.unitSettingsScreenConsumption),
              value: unitController.consumptionUnit.value,
              items: {
                ConsumptionUnit.kmPerLiter: context.tr(
                  TranslationKeys.unitSettingsScreenKmPerLiter,
                ),
                ConsumptionUnit.litersPer100km: context.tr(
                  TranslationKeys.unitSettingsScreenLitersPer100km,
                ),
                ConsumptionUnit.milesPerGallon: context.tr(TranslationKeys.unitSettingsScreenMpg),
              },
              onChanged: unitController.setConsumptionUnit,
              textStyle: dropdownTextStyle,
            ),
            const Divider(color: AppTheme.cardDark),
            const SizedBox(height: 8),
            _buildUnitDropdown<CurrencyUnit>(
              context,
              title: context.tr(TranslationKeys.toolsScreenCurrencyCardTitle),
              value: unitController.currencyUnit.value,
              items: {
                CurrencyUnit.brl: context.tr(TranslationKeys.unitSettingsScreenBRL),
                CurrencyUnit.usd: context.tr(TranslationKeys.unitSettingsScreenUSD),
                CurrencyUnit.eur: context.tr(TranslationKeys.unitSettingsScreenEUR),
              },
              onChanged: (unit) {
                unitController.setCurrencyUnit(unit);
              },
              textStyle: dropdownTextStyle,
            ),
            const Divider(color: AppTheme.cardDark),
            const SizedBox(height: 16),
            _buildThemeSwitcher(context, primaryTextColor),
            const Divider(color: AppTheme.cardDark),
            const SizedBox(height: 8),

            _buildFontScaleSlider(context, primaryTextColor),
            const Divider(color: AppTheme.cardDark),
            const SizedBox(height: 8),
          ],
        );
      }),
    );
  }

  Widget _buildUnitDropdown<T extends Enum>(
    BuildContext context, {
    required String title,
    required T value,
    required Map<T, String> items,
    required void Function(T?) onChanged,
    required TextStyle textStyle,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final dropdownColor = isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: textStyle)),
          const SizedBox(width: 16),
          DropdownButton<T>(
            value: value,
            dropdownColor: dropdownColor,
            style: textStyle,
            icon: Icon(Icons.arrow_drop_down, color: textStyle.color),
            underline: Container(),
            items: items.entries.map<DropdownMenuItem<T>>((entry) {
              return DropdownMenuItem<T>(value: entry.key, child: Text(entry.value));
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSwitcher(BuildContext context, Color textColor) {
    if (!Get.isRegistered<ThemeController>()) {
      Get.put(ThemeController());
    }
    final themeController = Get.find<ThemeController>();
    final Map<ThemeMode, String> themeItems = {
      ThemeMode.system: context.tr(TranslationKeys.themeOptionSystem),
      ThemeMode.light: context.tr(TranslationKeys.themeOptionLight),
      ThemeMode.dark: context.tr(TranslationKeys.themeOptionDark),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              context.tr(TranslationKeys.themeSectionTitle),
              style: TextStyle(fontSize: 16, color: textColor),
            ),
          ),
          const SizedBox(width: 16),
          Obx(
            () => _buildDropdown(
              context,
              value: themeController.themeMode.value,
              items: themeItems,
              onChanged: themeController.setThemeMode,
              textStyle: TextStyle(fontSize: 16, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontScaleSlider(BuildContext context, Color textColor){
    if(!Get.isRegistered<ThemeController>()){
      Get.put(ThemeController());
    }

    final themeController = Get.find<ThemeController>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Obx((){
      final currentScale = themeController.fontScale.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              context.tr(TranslationKeys.fontSizeSectionTitle),
              style: TextStyle(fontSize: 16, color: textColor),
            ),
          ),
          Slider(
            value: currentScale,
            min: 0.8,
            max: 1.2,
            divisions: 4,
            label: '${(currentScale * 100).round()}%',
            activeColor: AppTheme.primaryFuelColor,
            inactiveColor: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
            onChanged: (double newValue){
              themeController.setFontScale(newValue);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pequena'.tr, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12)),
                Text('Padrão'.tr, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12)),
                Text('Grande'.tr, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    });
  }

  Widget _buildDropdown<T extends Object>(
    BuildContext context, {
    required T value,
    required Map<T, String> items,
    required void Function(T?) onChanged,
    required TextStyle textStyle,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final dropdownColor = isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight;
    return DropdownButton<T>(
      value: value,
      dropdownColor: dropdownColor,
      style: textStyle,
      items: items.entries.map<DropdownMenuItem<T>>((entry){
        return DropdownMenuItem<T>(value: entry.key, child: Text(entry.value));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
