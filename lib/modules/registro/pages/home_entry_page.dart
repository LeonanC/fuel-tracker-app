import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/modules/registro/controller/home_entry_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
          IconButton(
            icon: c.editingEntry != null
                ? Icon(RemixIcons.edit_line)
                : Icon(RemixIcons.save_line),
            onPressed: c.submit,
            tooltip: c.editingEntry != null
                ? 'he_btn_edit'.tr
                : 'he_btn_save'.tr,
          ),
        ],
        leading: IconButton(
          icon: Icon(RemixIcons.arrow_left_line),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => c.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: c.formKey,
                  child: Column(
                    children: [
                      _buildCard(theme, [
                        _buildDateTile(c, theme),
                        const Divider(),
                        _buildInputField(
                          c.kmController,
                          "Odômetro Atual",
                          RemixIcons.dashboard_3_line,
                          theme,
                        ),
                      ]),

                      const SizedBox(height: 16),
                      _buildDropdowns(c, theme),
                      const SizedBox(height: 16),
                      _buildCard(theme, [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                c.litrosController,
                                "Litros",
                                RemixIcons.gas_station_line,
                                theme,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInputField(
                                c.pricePerLiterController,
                                "Preço/L",
                                RemixIcons.money_dollar_circle_line,
                                theme,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          c.totalPriceController,
                          "Custo Total",
                          RemixIcons.bank_card_line,
                          theme,
                          isBold: true,
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _buildReceiptSection(c, theme),
                      const SizedBox(height: 16),
                      _buildSwitches(c, theme),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCard(ThemeData theme, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInputField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    ThemeData theme, {
    bool isBold = false,
  }) {
    return TextFormField(
      controller: ctrl,
      style: TextStyle(
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: theme.colorScheme.primary),
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildDateTile(HomeEntryController c, ThemeData theme) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        RemixIcons.calendar_event_line,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        "Data do Abastecimento",
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Obx(
        () => Text(DateFormat('dd/MM/yyyy').format(c.selectedDate.value)),
      ),
      onTap: () => c.selecionarData(Get.context!),
    );
  }

  Widget _buildDropdowns(HomeEntryController c, ThemeData theme) {
    return _buildCard(theme, [
      _dropdown(
        c.selectedVeiculos,
        c.lookupController.veiculosDrop
            .map((v) => DropdownMenuItem(value: v.id, child: Text(v.nickname)))
            .toList(),
        "Veículo",
      ),
      const Divider(),
      _dropdown(
        c.selectedGas,
        c.lookupController.tipoDrop
            .map((v) => DropdownMenuItem(value: v.id, child: Text(v.nome)))
            .toList(),
        "Combustível",
      ),
      const Divider(),
      _dropdown(
        c.selectedStations,
        c.lookupController.postosDrop
            .map((v) => DropdownMenuItem(value: v.id, child: Text(v.nome)))
            .toList(),
        "Posto de Combustível",
      ),
    ]);
  }

  Widget _dropdown(
    RxnInt val,
    List<DropdownMenuItem<int>> items,
    String label,
  ) {
    return Obx(
      () => DropdownButtonFormField<int>(
        value: val.value,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
        items: items,
        onChanged: (v) => val.value = v,
      ),
    );
  }

  Widget _buildReceiptSection(HomeEntryController c, ThemeData theme) {
    return Obx(() {
      final hasImage =
          c.comprovantePath.value != null &&
          c.comprovantePath.value!.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "COMPROVANTE",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyMedium!.color,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => c.pickComprovante(),
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasImage
                      ? theme.colorScheme.primary
                      : theme.dividerColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(c.comprovantePath.value),
                            fit: BoxFit.cover,
                          ),
                          Container(color: Colors.black26),
                          Icon(
                            RemixIcons.camera_switch_line,
                            color: Colors.white,
                            size: 30,
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          RemixIcons.camera_line,
                          color: theme.colorScheme.primary,
                          size: 30,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Anexar Foto do Recibo",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSwitches(HomeEntryController c, ThemeData theme) {
    return Obx(
      () => SwitchListTile(
        title: Text("Tanque Cheio?"),
        value: c.isTankFull.value,
        secondary: Icon(
          c.isTankFull.value
              ? RemixIcons.gas_station_fill
              : RemixIcons.gas_station_line,
        ),
        onChanged: (v) => c.isTankFull.value = v,
      ),
    );
  }
}
