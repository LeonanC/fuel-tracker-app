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
      body: Form(
        key: controller.formKey,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              expandedHeight: 130.h,
              pinned: true,
              stretch: true,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  RemixIcons.arrow_left_s_line,
                  color: colorScheme.onSurface,
                ),
                onPressed: () => Get.back(),
              ),
              title: Text(
                controller.editingEntry != null
                    ? 'gs_title_edit'.tr
                    : 'gs_novo_posto'.tr,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSectionTitle("gs_label_section_1".tr, colorScheme),
                  _buildCardContainer(
                    theme,
                    child: Column(
                      children: [
                        _buildInputField(
                          ctrl: controller.nameController,
                          label: 'gs_label_name'.tr,
                          icon: RemixIcons.gas_station_line,
                          theme: theme,
                        ),
                        Divider(
                          height: 1,
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                          indent: 16.w,
                        ),
                        _buildInputField(
                          ctrl: controller.brandController,
                          label: 'gs_label_brand'.tr,
                          icon: RemixIcons.shield_user_line,
                          theme: theme,
                        ),
                        Divider(
                          height: 1,
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                          indent: 16.w,
                        ),
                        _buildInputField(
                          ctrl: controller.addressController,
                          label: 'gs_label_address'.tr,
                          icon: RemixIcons.map_pin_2_line,
                          theme: theme,
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
                            child: _buildInputField(
                              ctrl: controller.latitudeController,
                              label: "gs_label_latitude".tr,
                              icon: RemixIcons.map_pin_range_line,
                              theme: theme,
                              isText: false,
                              isSuffix: IconButton(
                                icon: Icon(
                                  RemixIcons.focus_3_line,
                                  color: theme.colorScheme.primary,
                                ),
                                onPressed: () => controller.fetchLocation(),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: theme.colorScheme.outlineVariant,
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                          ),
                          Expanded(
                            child: _buildInputField(
                              ctrl: controller.longitudeController,
                              label: "gs_label_longitude".tr,
                              icon: RemixIcons.compass_3_line,
                              theme: theme,
                              isText: false,
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
                    child: Column(
                      children: [
                        _buildInputField(
                          ctrl: controller.priceGAController,
                          label: 'gs_label_price_gasoline'.tr,
                          icon: RemixIcons.drop_line,
                          theme: theme,
                          isText: false,
                        ),
                        Divider(
                          height: 1,
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                          indent: 16.w,
                        ),
                        _buildInputField(
                          ctrl: controller.priceETAController,
                          label: 'gs_label_price_ethanol'.tr,
                          icon: RemixIcons.leaf_line,
                          theme: theme,
                          isText: false,
                        ),
                        Divider(
                          height: 1,
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                          indent: 16.w,
                        ),
                        _buildInputField(
                          ctrl: controller.priceDIEController,
                          label: 'gs_label_price_diesel'.tr,
                          icon: RemixIcons.truck_line,
                          theme: theme,
                          isText: false,
                        ),
                        Divider(
                          height: 1,
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                          indent: 16.w,
                        ),
                        _buildInputField(
                          ctrl: controller.priceGNController,
                          label: 'gs_label_price_gnv'.tr,
                          icon: RemixIcons.fire_line,
                          theme: theme,
                          isText: false,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionTitle("gs_label_section_4".tr, colorScheme),
                  _buildCardContainer(
                    theme,
                    child: _buildSwitches(controller, theme),
                  ),
                  SizedBox(height: 32.h),
                  _buildSubmitButton(controller, colorScheme),
                  SizedBox(height: 34.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: colorScheme.primary.withValues(alpha: 0.7),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCardContainer(ThemeData theme, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.015),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInputField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    required ThemeData theme,
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
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          icon,
          size: 20.sp,
          color: theme.colorScheme.primary.withValues(alpha: 0.7),
        ),
        suffixIcon: isSuffix,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
