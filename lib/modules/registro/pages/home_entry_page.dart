import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/modules/registro/controller/home_entry_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class HomeEntryPage extends StatelessWidget {
  final double? lastOdometer;
  final FuelEntryModel? entry;
  HomeEntryPage({super.key, this.lastOdometer, this.entry}) {
    Get.put(HomeEntryController()).inicializar(entry, lastOdometer);
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeEntryController>();

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: false,
        elevation: 0,
        title: Text(c.editingEntry != null ? 'he_edit'.tr : 'he_new'.tr),
        actions: [
          Obx(
            () => c.isLoading.value
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: CircularProgressIndicator(strokeWidth: 1),
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      RemixIcons.check_double_line,
                      size: 28,
                      color: Colors.greenAccent,
                    ),
                    onPressed: c.submit,
                  ),
          ),
        ],
        leading: IconButton(
          icon: Icon(RemixIcons.arrow_left_line),
          onPressed: () => Get.back(),
        ),
      ),
      body: Form(
        key: c.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("INFORMAÇÕES BÁSICAS", theme),
              _buildCardContainer(child: _buildDropdowns(c)),

              const SizedBox(height: 20),
              _buildSectionTitle("VALORES E MEDIÇÃO", theme),
              _buildCardContainer(child: _buildInputField(c)),
              const SizedBox(height: 20),
              _buildImagePicker(c, theme),
              const SizedBox(height: 20),
              _buildSwitches(c, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.blueAccent,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInputField(HomeEntryController c) {
    return Column(
      children: [
        _customTextField(
          controller: c.kmController,
          label: "Odômetro Atual",
          icon: RemixIcons.dashboard_3_line,
          suffix: "km",
        ),
        const SizedBox(height: 15),
        _buildDatePickerField(c),
        const Divider(height: 30, color: Colors.white10),
        Row(
          children: [
            Expanded(
              child: _customTextField(
                controller: c.litrosController,
                label: "Litro",
                icon: RemixIcons.drop_line,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _customTextField(
                controller: c.pricePerLiterController,
                label: "Preço/Litro",
                icon: RemixIcons.price_tag_3_line,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _customTextField(
          controller: c.totalPriceController,
          label: "Valor Total",
          icon: RemixIcons.money_dollar_circle_line,
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildDatePickerField(HomeEntryController c){
    return Obx(() {
      final date = c.selectedDate.value;
      final dateStr = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
      final timeStr = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
      return InkWell(
        onTap: () => c.selecionarData(Get.context!),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(RemixIcons.calendar_event_line, size: 20, color: Colors.blueAccent),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Data do Abastecimento",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    "$dateStr às $timeStr",
                    style: GoogleFonts.firaCode(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
              const Spacer(),
              Icon(RemixIcons.edit_line, size: 18, color: Colors.white10),
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
    String? suffix,
    bool isBold = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.firaCode(
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        color: isBold ? Colors.greenAccent : Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.black26,
      ),
    );
  }

  Widget _buildImagePicker(HomeEntryController c, ThemeData theme) {
    return Obx(() {
      final path = c.comprovantePath.value;
      return GestureDetector(
        onTap: c.pickComprovante,
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: theme.dividerColor),
          ),
          child: path.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(RemixIcons.camera_line, size: 40),
                    Text("Tirar foto do recibo"),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: path.startsWith('http')
                      ? Image.network(path, fit: BoxFit.cover)
                      : Image.file(File(path), fit: BoxFit.cover),
                ),
        ),
      );
    });
  }

  Widget _buildDropdowns(HomeEntryController c) {
    return Column(
      children: [
        _customDropdown(
          value: c.selectedVeiculos,
          label: "Selecione o Veículo",
          icon: RemixIcons.car_fill,
          items: c.controller.vehicles
              .map(
                (v) => DropdownMenuItem(value: v.id, child: Text(v.nickname)),
              )
              .toList(),
          onChanged: (v) {
            c.selectedVeiculos.value = v;
            c.atualizarHodometroPorVeiculo(v);
          },
        ),
        const SizedBox(height: 15),
        _customDropdown(
          value: c.selectedStations,
          label: "Selecione o Posto",
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
          value: c.selectedGas,
          label: "Selecione o Combustível",
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
  }

  Widget _customDropdown({
    required RxnString value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: value.value,
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
      ),
    );
  }

  Widget _buildSwitches(HomeEntryController c, ThemeData theme) {
    return Obx(
      () => SwitchListTile(
        title: Text("Tanque Cheio?"),
        value: c.isTankFull.value,
        secondary: Icon(RemixIcons.gas_station_fill),
        onChanged: (v) => c.isTankFull.value = v,
      ),
    );
  }
}
