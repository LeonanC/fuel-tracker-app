import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker_app/modules/vehicle/pages/widgets/vehicle_plate_widget.dart';
import 'package:fuel_tracker_app/modules/registro/controller/vehicle_entry_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class VehicleEntryScreen extends GetView<VehicleEntryController> {
  const VehicleEntryScreen({super.key});

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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                controller.editingEntry != null
                    ? 'veh_edit_vehicle'.tr
                    : 'veh_novo_veiculo'.tr,
                style: GoogleFonts.montserrat(),
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
            _buildSliverAppBar(colorScheme, theme),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImagePicker(controller, theme),
                      SizedBox(height: 25.h),
                      _buildSectionTitle(
                        "veh_label_identification".tr,
                        colorScheme,
                      ),
                      _buildCard(theme, [
                        ValueListenableBuilder(
                          valueListenable: controller.plateController,
                          builder: (context, value, child) {
                            return VehiclePlateWidget(
                              plate: controller.plateController.text.isEmpty
                                  ? "ABC1D23"
                                  : controller.plateController.text,
                              isMercosul: controller.isMercosul.value,
                              city: controller.cityController.text.isEmpty
                                  ? "BRASIL"
                                  : controller.cityController.text,
                            );
                          },
                        ),
                        const Divider(),
                        _customTextField(
                          controller: controller.nicknameController,
                          label: "veh_nickname".tr,
                          icon: RemixIcons.medal_line,
                          isText: true,
                        ),
                        const Divider(),
                        _customTextField(
                          controller: controller.plateController,
                          label: "veh_plate".tr,
                          icon: RemixIcons.medal_line,
                          isText: true,
                        ),
                      ]),
                      SizedBox(height: 25.h),
                      _buildSectionTitle(
                        "veh_label_vehicle_information".tr,
                        colorScheme,
                      ),
                      _buildCard(theme, [
                        Row(
                          children: [
                            Expanded(
                              child: _customTextField(
                                controller: controller.makeController,
                                label: "veh_make".tr,
                                icon: RemixIcons.building_line,
                                isText: true,
                              ),
                            ),
                            const VerticalDivider(),
                            Expanded(
                              child: _customTextField(
                                controller: controller.modelController,
                                label: "veh_model".tr,
                                icon: RemixIcons.car_line,
                                isText: true,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: _customTextField(
                                controller: controller.yearController,
                                label: "veh_year".tr,
                                icon: RemixIcons.calendar_line,
                              ),
                            ),
                            const VerticalDivider(),
                            Expanded(
                              child: _customTextField(
                                controller: controller.cityController,
                                label: "veh_city".tr,
                                icon: RemixIcons.community_line,
                                isText: true,
                              ),
                            ),
                          ],
                        ),
                      ]),
                      SizedBox(height: 25.h),
                      _buildSectionTitle(
                        "veh_label_technical_specifications".tr,
                        colorScheme,
                      ),
                      _buildCard(theme, [
                        Row(
                          children: [
                            Expanded(
                              child: _customTextField(
                                controller: controller.odometerController,
                                label: "veh_odometer".tr,
                                icon: RemixIcons.dashboard_3_line,
                              ),
                            ),
                            Expanded(
                              child: _customTextField(
                                controller: controller.tankCapacityController,
                                label: "veh_fuel_tank".tr,
                                icon: RemixIcons.oil_line,
                              ),
                            ),
                          ],
                        ),
                        _buildDropdowns(controller),
                        _buildSwitches(controller, theme),
                      ]),

                      SizedBox(height: 25.h),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(ColorScheme colorScheme, ThemeData theme) {
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
          controller.editingEntry != null
              ? 'veh_edit_vehicle'.tr
              : 'veh_novo_veiculo'.tr,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w800,
            fontSize: 18.sp,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(VehicleEntryController c, ThemeData theme) {
    return Obx(() {
      final path = c.selectedImageUrl.value;
      return GestureDetector(
        onTap: c.processarUpload,
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
                    Text("veh_take_photo".tr),
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

  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: colorScheme.primary.withOpacity(0.7),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDropdowns(VehicleEntryController v) {
    return Column(
      children: [
        _customDropdown(
          value: v.selectedTipo,
          label: 'veh_select_type_fuel'.tr,
          icon: RemixIcons.oil_line,
          items: v.controller.tipos
              .map((g) => DropdownMenuItem(value: g.id, child: Text(g.nome)))
              .toList(),
          onChanded: (g) {
            v.selectedTipo.value = g;
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
    required Function(String?) onChanded,
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
        onChanged: onChanded,
      ),
    );
  }

  Widget _buildSwitches(VehicleEntryController c, ThemeData theme) {
    return Obx(
      () => SwitchListTile(
        title: const Text("Padrão Mercosul"),
        value: controller.isMercosul.value,
        onChanged: (val) => controller.isMercosul.value = val,
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

  Widget _customTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? suffix,
    bool isText = false,
    bool isBold = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isText ? TextInputType.text : TextInputType.number,
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
}
