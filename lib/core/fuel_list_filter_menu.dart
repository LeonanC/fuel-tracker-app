import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/fuel_list_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class FuelListFilterMenu extends StatelessWidget {
  FuelListFilterMenu({super.key});

  final FuelListController controller = Get.find<FuelListController>();

  PopupMenuItem<String> _buildFilterItem({
    required String value,
    required String label,
    required bool isSelected,
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
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      icon: Icon(RemixIcons.filter_3_line, color: theme.colorScheme.onSurface),
      onSelected: (value) {
        if (value == 'ClearAll') {
          controller.clearAllFilters();
        } else if (value.startsWith('SetVeiculo:')) {
          controller.selectedVehicleID.value = int.parse(value.split(':')[1]);
        } else if (value == 'ClearVeiculo') {
          controller.selectedVehicleID.value = null;
        } else if (value.startsWith('SetFuel:')) {
          controller.selectedTipoID.value = int.parse(value.split(':')[1]);
        } else if (value == 'ClearFuel') {
          controller.selectedTipoID.value = null;
        } else if (value.startsWith('SetStation:')) {
          controller.selectedPostoID.value = int.parse(value.split(':')[1]);
        } else if (value == 'ClearStation') {
          controller.selectedPostoID.value = null;
        }
      },
      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry<String>> items = [];
        items.add(
          PopupMenuItem(
            enabled: false,
            child: Text(
              "Filtros Ativos",
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ),
        );
        items.add(const PopupMenuDivider());

        items.add(
          PopupMenuItem(
            enabled: false,
            child: Text(
              'Veiculos:',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ),
        );
        controller.veiculosMap.forEach((id, name) {
          items.add(
            _buildFilterItem(
              value: 'SetVeiculo:$id',
              label: '${controller.veiculosMap[id]?['nickname']}',
              isSelected: controller.selectedVehicleID.value == id,
            ),
          );
        });
        items.add(
          PopupMenuItem(
            value: 'ClearVeiculo',
            child: Text(
              "Limpar Veículo",
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        );
        items.add(PopupMenuDivider());

        items.add(
          PopupMenuItem(
            enabled: false,
            child: Text(
              'Combustível',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ),
        );

        controller.tiposMap.forEach((id, name) {
          items.add(
            _buildFilterItem(
              value: 'SetFuel:$id',
              label: '${controller.tiposMap[id]?['nome']}',
              isSelected: controller.selectedTipoID.value == id,
            ),
          );
        });
        items.add(
          PopupMenuItem(
            value: 'ClearFuel',
            child: Text(
              'Limpar Combustível',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        );

        items.add(const PopupMenuDivider());

        items.add(
          PopupMenuItem<String>(
            enabled: false,
            child: Text(
              'Postos',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ),
        );

        controller.postosMap.forEach((id, nome) {
          items.add(
            _buildFilterItem(
              value: 'SetStation:$id',
              label: '${controller.postosMap[id]?['nome']}',
              isSelected: controller.selectedPostoID.value == id,
            ),
          );
        });
        items.add(
          PopupMenuItem(
            value: 'ClearStation',
            child: Text(
              'Limpar Posto',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        );

        return items;
      },
    );
  }
}
