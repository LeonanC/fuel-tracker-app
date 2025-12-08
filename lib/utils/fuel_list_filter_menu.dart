import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:fuel_tracker_app/utils/unit_nums.dart';
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

  PopupMenuItem<String> buildFuelTypeItem(String gas, bool isSelected) {
    return PopupMenuItem<String>(
      value: 'SetFuel:$gas',
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: isSelected ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(gas, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
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

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020, 1),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: controller.isDateFilterActive
          ? DateTimeRange(start: controller.startDate!, end: controller.endDate!)
          : null,
      helpText: 'Selecione o Período de Abastecimento',
      saveText: 'Aplicar',
      cancelText: 'Cancelar',
    );

    if(picked != null){
      controller.applyDateFilter(picked.start, picked.end);
      Get.snackbar(
        'Filtro', 
        'Filtro aplicado: ${controller.formattedDateRange}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final selectedVehicleTypeFilter = controller.selectedVehicleFilter.value;
      final selectedFuelTypeFilter = controller.selectedFuelTypeFilter.value;
      final selectedStationFilter = controller.selectedStationFilter.value;

      final bool isFiltered =
          selectedVehicleTypeFilter != null ||
          selectedFuelTypeFilter != null ||
          selectedStationFilter != null;

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
          } else if (value == 'ClearPeriod') {
            controller.clearDateFilter();
          } else if (value.startsWith('SetPeriod:')) {
            _selectDateRange(context);
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
              child: Row(
                children: [
                  Icon(Icons.directions_car, color: Colors.blueGrey),
                  SizedBox(width: 8),
                  Text('Filtro por Veiculos:', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
          items.addAll(
            controller.availableVehicleNames.map((vehicleName) {
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
              child: Row(
                children: [
                  Icon(Icons.oil_barrel, color: Colors.orangeAccent),
                  SizedBox(width: 8),
                  Text(
                    'Filtro por Tipo de Combustível:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
          items.addAll(
            controller.availableTypeGasNames.map((gasName) {
              return buildFuelTypeItem(gasName, controller.selectedFuelTypeFilter.value == gasName);
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
              child: Row(
                children: [
                  Icon(Icons.local_gas_station, color: Colors.blueGrey),
                  SizedBox(width: 8),
                  Text('Filtro por Posto:', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
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
          String periodText = controller.isDateFilterActive
              ? 'Período: ${controller.formattedDateRange}'
              : 'Filtrar por Período';

          items.add(
            PopupMenuItem<String>(
              value: 'SetPeriod:trigger',
              child: Row(
                children: [
                  const Icon(Icons.date_range, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Text(
                    periodText,
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_right_alt, color: Colors.indigoAccent),
                ],
              ),
            ),
          );
          items.add(
            PopupMenuItem<String>(
              value: 'ClearPeriod',
              child: Text('Limpar Filtro', style: const TextStyle(color: Colors.red)),
            ),
          );
          return items;
        },
      );
    });
  }
}
