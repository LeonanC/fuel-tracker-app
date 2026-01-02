import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/repository/fuel_repository.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:fuel_tracker_app/utils/unit_nums.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class FuelListFilterMenu extends StatelessWidget {
  FuelListFilterMenu({super.key});

  final FuelListController controller = Get.find<FuelListController>();
  final FuelRepository repository = FuelRepository();

  PopupMenuItem<String> _buildFilterItem({
    required String value,
    required String label,
    required bool isSelected,
    required IconData icon,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: isSelected ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            label,
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
      initialDateRange: repository.isDateFilterActive
          ? DateTimeRange(start: repository.startDate!, end: repository.endDate!)
          : null,
      helpText: 'Selecione o Período',
    );

    if (picked != null) {
      repository.applyDateFilter(picked.start, picked.end);
      controller.loadFuel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final selectedVehicle = controller.selectedVehicleFilter.value;
      final selectedFuel = controller.selectedFuelTypeFilter.value;
      final selectedStation = controller.selectedStationFilter.value;

      final bool isFiltered =
          selectedVehicle != null ||
          selectedFuel != null ||
          selectedStation != null ||
          repository.isDateFilterActive;

      return PopupMenuButton<String>(
        icon: Icon(
          RemixIcons.filter_3_line,
          color: isFiltered ? Colors.orange : theme.colorScheme.onSurface,
        ),
        onSelected: (value) {
          if (value == 'ClearAll') {
            controller.setVeiculoFilter(null);
            controller.setFuelTypeFilter(null);
            controller.setStationFilter(null);
            repository.clearDateFilter();
          } else if (value.startsWith('SetVeiculo:')) {
            controller.setVeiculoFilter(value.substring(11));
          } else if (value == 'ClearVeiculo') {
            controller.setVeiculoFilter(null);
          } else if (value.startsWith('SetFuel:')) {
            controller.setFuelTypeFilter(value.substring(8));
          } else if (value == 'ClearFuel') {
            controller.setFuelTypeFilter(null);
          } else if (value.startsWith('SetStation:')) {
            controller.setStationFilter(value.substring(11));
          } else if (value == 'ClearStation') {
            controller.setStationFilter(null);
          } else if (value == 'SetPeriod') {
            _selectDateRange(context);
          } else if (value.startsWith('ClearPeriod')) {
            repository.clearDateFilter();
            controller.loadFuel();
          }
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem(
            enabled: false,
            child: Text(
              "Filtros Ativos",
              style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
            ),
          ),
          const PopupMenuDivider(),

          PopupMenuItem(
            enabled: false,
            child: Text('Veiculos:', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          ...repository.availableVehicleNames.map(
            (name) => _buildFilterItem(
              value: 'SetVeiculo:$name',
              label: name,
              isSelected: selectedVehicle == name,
              icon: RemixIcons.car_line,
            ),
          ),
          const PopupMenuItem(
            value: 'ClearVeiculo',
            child: Text("Limpar Veículo", style: TextStyle(color: Colors.red, fontSize: 13)),
          ),
          const PopupMenuDivider(),

          PopupMenuItem(
            enabled: false,
            child: Text('Combustível', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ),

          ...repository.availableTypeGasNames.map(
            (name) => _buildFilterItem(
              value: 'SetFuel:$name',
              label: name,
              isSelected: selectedFuel == name,
              icon: Icons.oil_barrel,
            ),
          ),

          PopupMenuItem(
            value: 'ClearFuel',
            child: Text(
              'Limpar Combustível',
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),

          const PopupMenuDivider(),

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

          ...repository.availableGasStationNames.map((name) {
            return _buildFilterItem(
              value: 'SetStation:$name',
              label: name,
              isSelected: selectedStation == name,
              icon: Icons.local_gas_station,
            );
          }),

          PopupMenuItem(
            value: 'ClearStation',
            child: Text('Limpar Posto', style: const TextStyle(color: Colors.red, fontSize: 13)),
          ),
          const PopupMenuDivider(),

          PopupMenuItem(
            value: 'SetPeriod',
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text(
                  repository.isDateFilterActive
                      ? repository.formattedDateRange
                      : "Filtrar por Data",
                ),
              ],
            ),
          ),
          if (repository.isDateFilterActive)
            PopupMenuItem(
              value: 'ClearPeriod',
              child: Text(
                'Limpar Período',
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),

          // return items;
        ],
      );
    });
  }
}
