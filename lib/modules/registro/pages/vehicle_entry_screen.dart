import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/vehicle_model.dart';
import 'package:fuel_tracker_app/data/global/vehicle_plate_widget.dart';
import 'package:fuel_tracker_app/modules/registro/controller/vehicle_entry_controller.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class VehicleEntryScreen extends StatelessWidget {
  final VehicleModel? data;
  VehicleEntryScreen({super.key, this.data}) {
    Get.put(VehicleEntryController()).inicializer(data);
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VehicleEntryController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: false,
        elevation: 0,
        title: Text(
          c.editingEntry != null ? 'veh_edit_vehicle'.tr : 'veh_add_vehicle'.tr,
        ),
        actions: [
          IconButton(
            icon: c.editingEntry != null
                ? Icon(RemixIcons.edit_line)
                : Icon(RemixIcons.save_line),
            onPressed: c.submit,
            tooltip: c.editingEntry != null
                ? 'veh_btn_edit_vehicle'.tr
                : 'veh_btn_add_vehicle'.tr,
          ),
        ],
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
                      GestureDetector(
                        onTap: c.pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          backgroundImage: c.selectedImageUrl.value != null
                              ? FileImage(File(c.selectedImageUrl.value))
                              : null,
                          child: c.selectedImageUrl.value == null
                              ? Icon(
                                  RemixIcons.camera_2_line,
                                  size: 40,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ValueListenableBuilder(
                        valueListenable: c.plateController,
                        builder: (context, value, child) {
                          return VehiclePlateWidget(
                            plate: c.plateController.text.isEmpty
                                ? "ABC1D23"
                                : c.plateController.text,
                            isMercosul: c.isMercosul.value,
                            city: c.cityController.text.isEmpty
                                ? "BRASIL"
                                : c.cityController.text,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildCard(theme, [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                c.nicknameController,
                                "Apelido (Ex: City)",
                                RemixIcons.medal_line,
                                isText: true,
                                theme,
                              ),
                            ),
                            Expanded(
                              child: _buildInputField(
                                c.plateController,
                                "Placa",
                                RemixIcons.barcode_box_line,
                                isText: true,
                                theme,
                                onChanged: (v) => c.plateController.text = v,
                              ),
                            ),
                          ],
                        ),

                        const Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                c.cityController,
                                "Cidade/País na Placa",
                                RemixIcons.map_pin_user_line,
                                isText: true,
                                theme,
                                onChanged: (v) => c.cityController.text = v,
                              ),
                            ),
                            const Divider(),
                            Expanded(
                              child: _buildInputField(
                                c.yearController,
                                "Ano",
                                RemixIcons.calendar_line,
                                isText: true,
                                theme,
                              ),
                            ),
                          ],
                        ),

                        const Divider(),
                        _buildSwitches(c, theme),
                      ]),
                      const SizedBox(height: 16),
                      _buildCard(theme, [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                c.makeController,
                                "Marca",
                                RemixIcons.building_line,
                                isText: true,
                                theme,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInputField(
                                c.modelController,
                                "Modelo",
                                RemixIcons.car_line,
                                isText: true,
                                theme,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                c.tankCapacityController,
                                "Tanque (L)",
                                RemixIcons.drop_line,
                                isText: true,
                                theme,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInputField(
                                c.odometerController,
                                "KM Inicial",
                                RemixIcons.speed_up_line,
                                isText: true,
                                theme,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        _buildDropdown(c, theme),
                      ]),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDropdown(VehicleEntryController c, ThemeData theme) {
    return _buildCard(theme, [
      _dropdown(
        c.selectedTipo,
        c.lookupController.tipoDrop
            .map((v) => DropdownMenuItem(value: v.id, child: Text(v.nome)))
            .toList(),
        "Combustível",
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

  Widget _buildSwitches(VehicleEntryController c, ThemeData theme) {
    return Obx(
      () => SwitchListTile(
        title: const Text("Padrão Mercosul"),
        value: c.isMercosul.value,
        onChanged: (val) => c.isMercosul.value = val,
        secondary: const Icon(Icons.flag_outlined),
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
    bool isText = true,
    bool isBold = false,
    Function? onChanged,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isText ? TextInputType.text : TextInputType.number,
      style: TextStyle(
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: theme.colorScheme.primary),
        border: InputBorder.none,
      ),
      onChanged: (value) => onChanged,
    );
  }
}
