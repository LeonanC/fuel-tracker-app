import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class FuelListFilterMenu extends GetView<HomeController> {
  const FuelListFilterMenu({super.key});

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
        if (value.startsWith('SetVeiculo:')) {
          controller.selectedVehicleID.value = value.split(':')[1];
        } else if (value == 'ClearVeiculo') {
          controller.selectedVehicleID.value = null;
        } else if (value.startsWith('SetFuel:')) {
          controller.selectedTipoID.value = value.split(':')[1];
        } else if (value == 'ClearFuel') {
          controller.selectedTipoID.value = null;
        } else if (value.startsWith('SetStation:')) {
          controller.selectedPostoID.value = value.split(':')[1];
        } else if (value == 'ClearStation') {
          controller.selectedPostoID.value = null;
        }
      },
      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry<String>> items = [];

        items.add(_buildSectionHeader("Veículos"));
        controller.veiculosMap.forEach((id, nome) {
          items.add(
            _buildFilterItem(
              value: 'SetVeiculo:$id',
              label: '${controller.veiculosMap[id]?['nickname']}',
              isSelected: controller.selectedVehicleID.value == id,
            ),
          );
        });
        items.add(_buildClearItem('ClearVeiculo', "Limpar Veículo"));
        items.add(PopupMenuDivider());

        items.add(_buildSectionHeader("Combustível"));
        controller.tiposMap.forEach((id, nome) {
          items.add(
            _buildFilterItem(
              value: 'SetFuel:$id',
              label: '${controller.tiposMap[id]?['nome']}',
              isSelected: controller.selectedTipoID.value == id,
            ),
          );
        });

        items.add(_buildClearItem("ClearFuel", "Limpar Combustível"));
        items.add(const PopupMenuDivider());

        items.add(_buildSectionHeader("Postos"));
        controller.postosMap.forEach((id, nome) {
          items.add(
            _buildFilterItem(
              value: 'SetStation:$id',
              label: '${controller.postosMap[id]?['nome']}',
              isSelected: controller.selectedPostoID.value == id,
            ),
          );
        });

        items.add(_buildClearItem('ClearStation', 'Limpar Posto'));

        return items;
      },
    );
  }

  PopupMenuItem<String> _buildClearItem(String value, String label) {
    return PopupMenuItem(
      value: value,
      child: Text(
        label,
        style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.red),
      ),
    );
  }

  PopupMenuItem<String> _buildSectionHeader(String title) {
    return PopupMenuItem(
      enabled: false,
      child: Text(
        title,
        style: GoogleFonts.lato(
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }
}
