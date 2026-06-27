import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/registro/controller/home_entry_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';

class HomeEntryPage extends GetView<HomeEntryController> {
  const HomeEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: Obx(
        () => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ElevatedButton.icon(
              onPressed: controller.isLoading.value ? null : controller.submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              icon: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(RemixIcons.check_line, color: Colors.white),
              label: Text(
                controller.editingEntry != null ? "he_edit".tr : "he_new".tr,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(controller, theme),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("he_label_section_1".tr, theme),
                    _buildCardContainer(child: _buildDropdowns(controller)),

                    const SizedBox(height: 20),
                    _buildSectionTitle("he_label_section_2".tr, theme),
                    _buildCardContainer(
                      child: _buildInputField(controller, theme),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(HomeEntryController c, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120.0,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: theme.appBarTheme.backgroundColor,
      leading: IconButton(
        icon: Icon(RemixIcons.arrow_left_line),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 50, bottom: 16),
        centerTitle: false,
        title: Text(
          controller.editingEntry != null ? 'he_edit'.tr : 'he_new'.tr,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: theme.colorScheme.primary.withOpacity(0.8),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: child,
    );
  }

  Widget _buildInputField(HomeEntryController c, ThemeData theme) {
    return Column(
      children: [
        _customTextField(
          controller: c.kmController,
          label: "he_current_odometer".tr,
          icon: RemixIcons.dashboard_3_line,
          suffix: "km",
          theme: theme,
        ),
        const SizedBox(height: 15),
        _buildDatePickerField(c),
        const Divider(height: 40, color: Colors.white10),
        Row(
          children: [
            Expanded(
              child: _customTextField(
                controller: c.litrosController,
                label: "he_label_liters".tr,
                icon: RemixIcons.drop_line,
                theme: theme,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _customTextField(
                controller: c.pricePerLiterController,
                label: "he_label_price_per_liter".tr,
                icon: RemixIcons.price_tag_3_line,
                theme: theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _customTextField(
          controller: c.totalPriceController,
          label: "he_label_total_price".tr,
          icon: RemixIcons.money_dollar_circle_line,
          isBold: true,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildDatePickerField(HomeEntryController c) {
    return Obx(() {
      final date = c.selectedDate.value;
      final dateStr = DateFormat('dd/MM/yyyy').format(date);
      final timeStr = DateFormat('HH:mm').format(date);
      return InkWell(
        onTap: () => c.selecionarData(Get.context!),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                RemixIcons.calendar_event_line,
                size: 20,
                color: Colors.blueAccent,
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "he_supply_date".tr,
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                  Text(
                    "$dateStr às $timeStr",
                    style: GoogleFonts.firaCode(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(RemixIcons.edit_2_line, size: 16, color: Colors.white24),
            ],
          ),
        ),
      );
    });
  }

  Widget _customTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeData theme,
    String? suffix,
    bool isBold = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      style: GoogleFonts.firaCode(
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        color: isBold ? Colors.greenAccent : Colors.white,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.montserrat(fontSize: 12, color: Colors.white54),
        prefixIcon: Icon(icon, size: 20, color: theme.colorScheme.primary),
        suffixText: suffix,
        suffixStyle: TextStyle(color: Colors.white30),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
      ),
    );
  }

  Widget _buildDropdowns(HomeEntryController c) {
    return Obx(() {
      return Column(
        children: [
          _customDropdown(
            value: c.selectedVeiculos.value,
            label: "he_select_veiculos".tr,
            icon: RemixIcons.car_fill,
            items: c.controller.vehicles
                .map(
                  (v) => DropdownMenuItem(
                    value: v.id,
                    child: Text('${v.model} - (${v.nickname})'),
                  ),
                )
                .toList(),
            onChanged: (v) {
              c.selectedVeiculos.value = v;
              c.atualizarHodometroPorVeiculo(v);
            },
          ),
          const SizedBox(height: 15),
          _customDropdown(
            value: c.selectedStations.value,
            label: "he_select_station".tr,
            icon: RemixIcons.gas_station_line,
            items: c.controller.postos
                .map((p) => DropdownMenuItem(value: p.id, child: Text(p.nome)))
                .toList(),
            onChanged: (p) {
              c.selectedStations.value = p;
            },
          ),
          const SizedBox(height: 15),
          _customDropdown(
            value: c.selectedGas.value,
            label: "he_select_fuel_type".tr,
            icon: RemixIcons.oil_line,
            items: c.controller.tipos
                .map((g) => DropdownMenuItem(value: g.id, child: Text(g.nome)))
                .toList(),
            onChanged: (g) {
              c.selectedGas.value = g;
            },
          ),
        ],
      );
    });
  }

  Widget _customDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}
