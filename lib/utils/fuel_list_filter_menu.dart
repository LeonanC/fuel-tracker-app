import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class FuelListFilterMenu extends StatelessWidget {
  FuelListFilterMenu({super.key});

  final FuelListController controller = Get.find<FuelListController>();

  PopupMenuItem<String> buildVeiculoTypeItem(String vehicle, bool isSelected) {
    return PopupMenuItem<String>(
      value: 'SetVeiculo:$vehicle',
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: isSelected ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            vehicle,
            style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> buildFuelTypeItem(String key, String value, bool isSelected) {
    return PopupMenuItem<String>(
      value: 'SetFuel:$key',
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: isSelected ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> buildStationItem(String station, bool isSelected) {
    return PopupMenuItem<String>(
      value: 'SetStation:$station',
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: isSelected ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            station,
            style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final selectedVehicleTypeFilter = controller.selectedVehicleFilter.value;
      final selectedFuelTypeFilter = controller.selectedFuelTypeFilter.value;
      final selectedStationFilter = controller.selectedStationFilter.value;
      final bool isFiltered = selectedVehicleTypeFilter != null || selectedFuelTypeFilter != null || selectedStationFilter != null;

      return PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'ClearVeiculo') {
            controller.setVeiculoFilter(null);
          } else if (value.startsWith('SetVeiculo:')) {
            final type = value.substring(11);
            controller.setVeiculoFilter(type);
          } else if (value == 'ClearFuel') {
            controller.setFuelTypeFilter(null);
          } else if (value.startsWith('SetFuel:')) {
            final type = value.substring(8);
            controller.setFuelTypeFilter(type);
          } else if (value == 'ClearStation') {
            controller.setStationFilter(null);
          } else if (value.startsWith('SetStation:')) {
            final station = value.substring(11);
            controller.setStationFilter(station);
          }
        },
        icon: Icon(
          RemixIcons.filter_line,
          color: isFiltered ? Colors.orange : theme.colorScheme.onSurface,
        ),
        tooltip: context.tr(TranslationKeys.dialogFilterTitle),
        itemBuilder: (BuildContext context) {
          final List<PopupMenuEntry<String>> items = [];

          items.add(
            PopupMenuItem<String>(
              enabled: false,
              child: Text(
                context.tr(TranslationKeys.dialogFilterTitle),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          );
          items.add(const PopupMenuDivider());
          items.add(
            PopupMenuItem<String>(
              enabled: false,
              child: Text('Filtro por Veiculos:', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          );
          items.addAll(
            controller.availableVehicleNames.map((vehicleName){
              return buildVeiculoTypeItem(
                vehicleName,
                controller.selectedVehicleFilter.value == vehicleName,
              );
            }),
          );
          items.add(
            PopupMenuItem<String>(
              value: 'ClearVeiculo',
              child: Text('Limpar Filtro', style: const TextStyle(color: Colors.red)),

            ),
          );
          items.add(const PopupMenuDivider());
          items.add(
            PopupMenuItem<String>(
              enabled: false,
              child: Text(
                'Filtro por Tipo de Combustível:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          );
          items.addAll(
            controller.fuelTypeMap.entries.map((entry) {
              return buildFuelTypeItem(entry.key, entry.value, selectedFuelTypeFilter == entry.key);
            }),
          );
          items.add(
            PopupMenuItem<String>(
              value: 'ClearFuel',
              child: Text('Limpar Filtro', style: const TextStyle(color: Colors.red)),
            ),
          );
          items.add(const PopupMenuDivider());
          items.add(
            PopupMenuItem<String>(
              enabled: false,
              child: Text('Filtro por Posto:', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          );
          items.addAll(
            controller.availableGasStationNames.map((stationName) {
              return buildStationItem(
                stationName,
                controller.selectedStationFilter.value == stationName,
              );
            }),
          );
          items.add(
            PopupMenuItem<String>(
              value: 'ClearStation',
              child: Text('Limpar Filtro', style: const TextStyle(color: Colors.red)),
            ),
          );
          items.add(const PopupMenuDivider());
          items.add(
            PopupMenuItem<String>(
              enabled: false,
              child: Text(
                'Filtro por Período: (Em Breve)',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ),
          );
          return items;
        },
      );
    });
  }
}
