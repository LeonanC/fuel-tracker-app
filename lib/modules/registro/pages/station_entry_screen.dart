import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker_app/modules/registro/controller/station_entry_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class StationEntryScreen extends GetView<StationEntryController> {
  const StationEntryScreen({super.key});

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
                controller.editingEntry != null
                    ? "gs_title_edit".tr
                    : "gs_novo_posto".tr,
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
            _buildSliverAppBar(colorScheme, theme),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSectionTitle("gs_label_section_1".tr, colorScheme),
                  _buildCardContainer(
                    theme,
                    child: Column(
                      children: [
                        _customTextField(
                          controller: controller.nameController,
                          label: 'gs_label_name'.tr,
                          icon: RemixIcons.gas_station_line,
                          theme: theme,
                          isText: true,
                        ),
                        const SizedBox(height: 10),
                        _customTextField(
                          controller: controller.brandController,
                          label: 'gs_label_brand'.tr,
                          icon: RemixIcons.shield_user_line,
                          theme: theme,
                          isText: true,
                        ),
                        const SizedBox(height: 10),
                        _customTextField(
                          controller: controller.addressController,
                          label: 'gs_label_address'.tr,
                          icon: RemixIcons.map_pin_2_line,
                          theme: theme,
                          isText: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionTitle("gs_label_section_2".tr, colorScheme),
                  _buildCardContainer(
                    theme,
                    child: Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: _customTextField(
                              controller: controller.latitudeController,
                              label: "gs_label_latitude".tr,
                              icon: RemixIcons.map_pin_range_line,
                              theme: theme,
                              isBold: false,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: theme.colorScheme.outlineVariant,
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                          ),
                          Expanded(
                            child: _customTextField(
                              controller: controller.longitudeController,
                              label: "gs_label_longitude".tr,
                              icon: RemixIcons.compass_3_line,
                              theme: theme,
                              isBold: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionTitle("gs_label_section_3".tr, colorScheme),
                  _buildCardContainer(
                    theme,
                    child: _buildInputField(controller, theme),
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionTitle("gs_label_section_4".tr, colorScheme),
                  _buildCardContainer(
                    theme,
                    child: _buildSwitches(controller, theme),
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
      actions: [
        controller.isLoading.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : IconButton(
                icon: Icon(
                  RemixIcons.focus_3_line,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () => controller.fetchLocation(),
              ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 50, bottom: 16),
        centerTitle: false,
        title: Text(
          controller.editingEntry != null
              ? 'gs_title_edit'.tr
              : 'gs_novo_posto'.tr,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: colorScheme.primary.withOpacity(0.8),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildCardContainer(ThemeData theme, {required Widget child}) {
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

  Widget _buildInputField(StationEntryController c, ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _customTextField(
                controller: controller.priceGAController,
                label: 'gs_label_price_gasoline'.tr,
                icon: RemixIcons.drop_line,
                theme: theme,
                isBold: false,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _customTextField(
                controller: controller.priceETAController,
                label: 'gs_label_price_ethanol'.tr,
                icon: RemixIcons.leaf_line,
                theme: theme,
                isBold: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _customTextField(
                controller: controller.priceDIEController,
                label: 'gs_label_price_diesel'.tr,
                icon: RemixIcons.truck_line,
                theme: theme,
                isBold: false,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _customTextField(
                controller: controller.priceGNController,
                label: 'gs_label_price_gnv'.tr,
                icon: RemixIcons.fire_line,
                theme: theme,
                isBold: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _customTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeData theme,
    String? suffix,
    bool isText = false,
    bool isBold = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isText ? TextInputType.text : TextInputType.numberWithOptions(decimal: true),
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

  Widget _buildSwitches(StationEntryController c, ThemeData theme) {
    return Column(
      children: [
        _buildCustomSwitch(
          title: "gs_label_convenience_store".tr,
          icon: RemixIcons.shopping_basket_2_line,
          value: c.hasConvenienceStore,
          theme: theme,
        ),
        Divider(
          height: 1,
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          indent: 56.w,
        ),
        _buildCustomSwitch(
          title: "gs_label_24hours".tr,
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
        secondary: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: value.value
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : theme.colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: value.value
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        value: value.value,
        activeColor: theme.colorScheme.primary,
        onChanged: (v) => value.value = v,
      ),
    );
  }

  Widget _buildSubmitButton(StationEntryController c, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: FilledButton.icon(
        onPressed: c.submit,
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          shadowColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 2,
        ),
        icon: Icon(
          c.editingEntry != null
              ? RemixIcons.edit_line
              : RemixIcons.save_3_line,
          size: 20.sp,
        ),
        label: Text(
          c.editingEntry != null ? 'gs_btn_update'.tr : 'gs_btn_add'.tr,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
