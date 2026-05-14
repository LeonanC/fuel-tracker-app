import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class FuelListFilterMenu extends GetView<HomeController> {
  const FuelListFilterMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopupMenuButton<String>(
      icon: Icon(RemixIcons.filter_3_line, color: colorScheme.onSurface),
      tooltip: "Filtrar registros",
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      offset: Offset(0, 45),
      onSelected: (value) => _handleSelection(value),
      itemBuilder: (BuildContext context) {
        return [
          _buildSectionHeader(RemixIcons.car_line, "Veículos", colorScheme),
          ...controller.veiculosMap.entries.map((entry) {
            return _buildFilterItem(
              value: 'SetVeiculo:${entry.key}',
              label: '${entry.value["nickname"]}',
              isSelected: controller.selectedVehicleID.value == entry.key,
              colorScheme: colorScheme,
            );
          }),
          _buildClearItem(
            "ClearVeiculo",
            "Limpar Veículo",
            controller.selectedVehicleID.value != null,
          ),
          const PopupMenuDivider(),
          _buildSectionHeader(
            RemixIcons.gas_station_line,
            "Combustível",
            colorScheme,
          ),
          ...controller.tiposMap.entries.map((entry) {
            return _buildFilterItem(
              value: 'SetFuel:${entry.key}',
              label: '${entry.value["nome"]}',
              isSelected: controller.selectedTipoID.value == entry.key,
              colorScheme: colorScheme,
            );
          }),
          _buildClearItem(
            "ClearFuel",
            "Limpar Combustível",
            controller.selectedTipoID.value != null,
          ),
          const PopupMenuDivider(),

          _buildSectionHeader(RemixIcons.map_pin_2_line, "Postos", colorScheme),
          ...controller.postosMap.entries.map((entry) {
            return _buildFilterItem(
              value: 'SetStation:${entry.key}',
              label: '${entry.value["nome"]}',
              isSelected: controller.selectedPostoID.value == entry.key,
              colorScheme: colorScheme,
            );
          }),
          _buildClearItem(
            "ClearStation",
            "Limpar Posto",
            controller.selectedPostoID.value != null,
          ),
        ];
      },
    );
  }

  void _handleSelection(String value) {
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
  }

  PopupMenuItem<String> _buildSectionHeader(
    IconData icon,
    String title,
    ColorScheme color,
  ) {
    return PopupMenuItem(
      enabled: false,
      height: 32,
      child: Row(
        children: [
          Icon(icon, size: 14, color: color.primary),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: color.primary,
            ),
          )
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildFilterItem({
    required String value,
    required String label,
    required bool isSelected,
    required ColorScheme colorScheme,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? RemixIcons.checkbox_circle_fill
                  : RemixIcons.checkbox_blank_circle_line,
                size: 18,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildClearItem(
    String value,
    String label,
    bool isVisible,
  ) {
    if (!isVisible)
      return PopupMenuItem(enabled: false, height: 0, child: SizedBox.shrink());

    return PopupMenuItem(
      value: value,
      height: 35,
      child: Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
