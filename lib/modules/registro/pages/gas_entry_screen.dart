import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker_app/data/models/gas_station_model.dart';
import 'package:fuel_tracker_app/modules/registro/controller/gas_entry_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class GasEntryScreen extends GetView<GasEntryController> {
  final GasStationModel? data;
  GasEntryScreen({super.key, this.data}) {
    Get.put(GasEntryController()).inicializer(data);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            RemixIcons.arrow_left_s_line,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          controller.editingEntry != null ? 'gs_title_edit'.tr : 'gs_novo_posto'.tr,
          style: GoogleFonts.montserrat(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("INFORMAÇÕES BÁSICAS", colorScheme),
            _buildCardContainer(
              theme,
              child: Column(
                children: [
                  _buildInputField(
                    controller.nameController,
                    "Nome do Posto",
                    RemixIcons.gas_station_line,
                    theme,
                  ),
                  Divider(height: 1, indent: 50),
                  _buildInputField(
                    controller.brandController,
                    "Bandeira (Ex: Shell, BR)",
                    RemixIcons.shield_user_line,
                    theme,
                  ),
                  Divider(height: 1, indent: 50),
                  _buildInputField(
                    controller.addressController,
                    'Endereço Completo',
                    RemixIcons.map_pin_2_line,
                    theme,
                  ),
                ],
              ),
            ),
            SizedBox(height: 25.h),
            _buildSectionTitle("LOCALIZAÇÃO GEOGRÁFICA", colorScheme),
            _buildCardContainer(
              theme,
              child: Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      controller.latitudeController,
                      "Latitude",
                      RemixIcons.map_pin_range_line,
                      theme,
                      isText: false,
                      isSuffix: IconButton(
                        icon: Icon(RemixIcons.focus_3_line, color: theme.colorScheme.primary),
                        onPressed: () => controller.fetchLocation(),
                      )
                    ),
                  ),
                  Container(width: 1, height: 40, color: theme.colorScheme.onSurface.withOpacity(0.1)),
                  Expanded(
                    child: _buildInputField(
                      controller.longitudeController,
                      "Longitude",
                      RemixIcons.compass_3_line,
                      theme,
                      isText: false,
                    ),
                  ),
                ],
              )
            ),
            SizedBox(height: 25.h),
            _buildSectionTitle("PREÇOS ATUAIS (R\$)", colorScheme),
            _buildCardContainer(
              theme,
              child: Column(
                children: [
                  _buildInputField(
                    controller.priceGAController,
                    'Gasoline Comum',
                    RemixIcons.drop_line,
                    theme,
                    isText: false,
                  ),
                  _buildInputField(
                    controller.priceETAController,
                    'Etanol / Flex',
                    RemixIcons.leaf_line,
                    theme,
                    isText: false,
                  ),
                  _buildInputField(
                    controller.priceDIEController,
                    'Diesel S10',
                    RemixIcons.truck_line,
                    theme,
                    isText: false,
                  ),
                  _buildInputField(
                    controller.priceGNController,
                    'GNV',
                    RemixIcons.fire_line,
                    theme,
                    isText: false,
                  ),
                ],
              ),
            ),
            SizedBox(height: 25.h),
            _buildSectionTitle("SERVIÇOS E STATUS", colorScheme),
            _buildCardContainer(theme, child: _buildSwitches(controller, theme)),
            SizedBox(height: 40.h),
            _buildSubmitButton(controller, colorScheme),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
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

  Widget _buildCardContainer(ThemeData theme, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInputField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    ThemeData theme, {
    bool isText = true,
    Widget? isSuffix,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isText
          ? TextInputType.text
          : TextInputType.numberWithOptions(decimal: true),
      style: GoogleFonts.montserrat(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),

      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.montserrat(
          color: theme.colorScheme.onSurface.withOpacity(0.4),
          fontSize: 12.sp,
        ),
        prefixIcon: Icon(
          icon,
          size: 20.sp,
          color: theme.colorScheme.primary.withOpacity(0.6),
        ),
        suffixIcon: isSuffix,
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
    );
  }

  Widget _buildSwitches(GasEntryController c, ThemeData theme) {
    return Column(
      children: [
        _buildCustomSwitch(
          title: "Loja de Conveniência",
          icon: RemixIcons.shopping_basket_2_line,
          value: c.hasConvenienceStore,
          theme: theme,
        ),
        const Divider(height: 1, indent: 50),
        _buildCustomSwitch(
          title: "Atendimento 24 Horas",
          icon: RemixIcons.time_line,
          value: c.is24Hours,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildCustomSwitch({
    required String title,
    required IconData icon,
    required RxBool value,
    required ThemeData theme,
  }) {
    return Obx(
      () => SwitchListTile(
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        secondary: Icon(
          icon,
          color: value.value
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withOpacity(0.3),
        ),
        value: value.value,
        activeColor: theme.colorScheme.primary,
        onChanged: (v) => value.value = v,
      ),
    );
  }

  Widget _buildSubmitButton(GasEntryController c, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: 55.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.h),
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: c.submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              c.editingEntry != null
              ? RemixIcons.edit_line
              : RemixIcons.save_3_line, color: Colors.white,
            ),
            SizedBox(width: 10.w),
            Text(
              c.editingEntry != null ? 'gs_btn_update'.tr : 'gs_btn_add'.tr,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ), 
            )
          ],
        ),
      ),
    );
  }
}
