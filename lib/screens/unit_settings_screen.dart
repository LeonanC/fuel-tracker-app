import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/provider/unit_provider.dart';
import 'package:fuel_tracker_app/services/application.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:provider/provider.dart';

class UnitSettingsScreen extends StatelessWidget {
  const UnitSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(TranslationKeys.unitSettingsScreenTitle)),
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        centerTitle: false,
      ),
      body: Consumer<UnitProvider>(
        builder: (context, unitProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                context.tr(TranslationKeys.unitSettingsScreenSubtitle),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildUnitDropdown<DistanceUnit>(
                context,
                title: context.tr(TranslationKeys.unitSettingsScreenDistance),
                value: unitProvider.distanceUnit,
                items: {
                  DistanceUnit.kilometers: context.tr(
                    TranslationKeys.unitSettingsScreenKilometers,
                  ),
                  DistanceUnit.miles: context.tr(
                    TranslationKeys.unitSettingsScreenMiles,
                  ),
                },
                onChanged: (newValue) {
                  if (newValue != null) {
                    unitProvider.setDistanceUnit(newValue);
                  }
                },
              ),
              const Divider(color: AppTheme.cardDark),
              const SizedBox(height: 8),
              _buildUnitDropdown<VolumeUnit>(
                context,
                title: context.tr(TranslationKeys.unitSettingsScreenVolume),
                value: unitProvider.volumeUnit,
                items: {
                  VolumeUnit.liters: context.tr(
                    TranslationKeys.unitSettingsScreenLiters,
                  ),
                  VolumeUnit.gallons: context.tr(
                    TranslationKeys.unitSettingsScreenGallons,
                  ),
                },
                onChanged: (newValue) {
                  if (newValue != null) {
                    unitProvider.setVolumeUnit(newValue);
                  }
                },
              ),
              const Divider(color: AppTheme.cardDark),
              const SizedBox(height: 8),
              _buildUnitDropdown<ConsumptionUnit>(
                context,
                title: context.tr(TranslationKeys.unitSettingsScreenConsumption),
                value: unitProvider.consumptionUnit,
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
                onChanged: (newValue) {
                  if (newValue != null) {
                    unitProvider.setConsumptionUnit(newValue);
                  }
                },
              ),
              const Divider(color: AppTheme.cardDark),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUnitDropdown<T extends Enum>(BuildContext context, {required String title, required T value, required Map<T, String> items, required void Function(T?) onChanged}){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<T>(
            value: value,
            dropdownColor: AppTheme.cardDark,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryFuelColor),
            underline: Container(),
            items: items.entries.map<DropdownMenuItem<T>>((entry){
              return DropdownMenuItem<T>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
