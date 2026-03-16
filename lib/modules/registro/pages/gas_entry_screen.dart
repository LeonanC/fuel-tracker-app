import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/data/models/gas_station_model.dart';
import 'package:fuel_tracker_app/modules/registro/controller/gas_entry_controller.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class GasEntryScreen extends StatelessWidget {
  final GasStationModel? data;
  GasEntryScreen({super.key, this.data}) {
    Get.put(GasEntryController()).inicializer(data);
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<GasEntryController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: false,
        elevation: 0,
        title: Text(
          c.editingEntry != null ? 'gs_title_edit'.tr : 'gs_title_new'.tr,
        ),
        actions: [
          IconButton(
            icon: c.editingEntry != null
                ? Icon(RemixIcons.edit_line)
                : Icon(RemixIcons.save_line),
            onPressed: c.submit,
            tooltip: c.editingEntry != null
                ? 'gs_btn_update'.tr
                : 'gs_btn_add'.tr,
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
                      _buildCard(theme, [
                        _buildInputField(
                          c.nameController,
                          "Nome do Posto",
                          RemixIcons.gas_station_line,
                          isText: true,
                          theme,
                        ),
                        const Divider(),
                        _buildInputField(
                          c.brandController,
                          "Bandeira (Ex: Shell)",
                          RemixIcons.flag_line,
                          isText: true,
                          theme,
                        ),
                      ]),
                      const SizedBox(height: 16),

                      _buildCard(theme, [
                        _buildInputField(
                          c.addressController,
                          'Endereço Completo',
                          RemixIcons.map_pin_line,
                          suffix: IconButton(
                            icon: c.isLocationLoading.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    RemixIcons.gps_fill,
                                    color: theme.dividerColor,
                                  ),
                            onPressed: c.fetchLocation,
                          ),
                          theme,
                        ),
                        const Divider(),
                        _buildInputField(
                          c.latitudeController,
                          "Latitude",
                          Icons.explore_outlined,
                          theme,
                          isBold: true,
                        ),
                        const Divider(),
                        _buildInputField(
                          c.longitudeController,
                          "Longitude",
                          Icons.explore_outlined,
                          theme,
                          isBold: true,
                        ),
                      ]),
                      const SizedBox(height: 16),

                      _buildCard(theme, [
                        _buildInputField(
                          c.priceController,
                          'Preço',
                          RemixIcons.drop_line,
                          theme,
                          isText: false,
                          isBold: true,
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _buildSwitches(c, theme),
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
    bool isText = true,
    bool isBold = false,
    Widget? suffix,
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
        suffixIcon: suffix,
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildSwitches(GasEntryController c, ThemeData theme) {
    return Column(
      children: [
        Obx(
          () => SwitchListTile(
            title: Text("Loja de conveniência"),
            value: c.hasConvenienceStore.value,
            secondary: Icon(
              c.hasConvenienceStore.value
                  ? RemixIcons.shopping_basket_2_fill
                  : RemixIcons.shopping_basket_2_line,
            ),
            onChanged: (v) => c.hasConvenienceStore.value = v,
          ),
        ),
        Obx(
          () => SwitchListTile(
            title: Text("Atendimento 24H"),
            value: c.is24Hours.value,
            secondary: Icon(
              c.is24Hours.value ? RemixIcons.time_fill : RemixIcons.time_line,
            ),
            onChanged: (v) => c.is24Hours.value = v,
          ),
        ),
      ],
    );
  }
}
