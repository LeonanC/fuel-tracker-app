import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker_app/data/models/vehicle_model.dart';
import 'package:fuel_tracker_app/modules/registro/pages/vehicle_entry_screen.dart';
import 'package:fuel_tracker_app/modules/vehicle/controller/vehicle_controller.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class VehicleScreen extends GetView<VehicleController> {
  const VehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: Obx(() {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 120.h,
              floating: true,
              pinned: true,
              elevation: 0,
              stretch: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: EdgeInsets.only(bottom: 16.h),
                title: Text(
                  'veh_titulo'.tr,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    fontSize: 18.sp,
                  ),
                ),
              ),
            ),
            if (controller.isLoading.value)
              SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),
              )
            else if (controller.vehiclesMap.isEmpty)
              SliverFillRemaining(child: _buildEmptyState(colorScheme))
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final veiculos = controller.vehiclesMap.values.toList();
                    final data = veiculos[index];
                    final veiculo = VehicleModel.fromMap(
                      data,
                      data['pk_vehicle'],
                    );
                    return _buildVehicleCard(veiculo, theme);
                  }, childCount: controller.vehiclesMap.length),
                ),
              ),
          ],
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFab(colorScheme),
    );
  }

  Widget _buildFab(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        backgroundColor: colorScheme.primary,
        onPressed: () => Get.to(() => VehicleEntryScreen()),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        label: Text(
          "veh_novo_veiculo".tr,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
            color: Colors.white,
          ),
        ),
        icon: Icon(RemixIcons.add_fill, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            RemixIcons.car_line,
            size: 80.sp,
            color: colorScheme.primary.withOpacity(0.2),
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          "veh_nenhum_veiculo".tr,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(VehicleModel veiculo, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: InkWell(
          onTap: () => Get.to(() => VehicleEntryScreen(data: veiculo)),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Icon(
                    RemixIcons.car_fill,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        veiculo.nickname,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "${veiculo.make} ${veiculo.model} • ${veiculo.year}",
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDeleteButton(
                  () => _confirmDelete(veiculo, theme),
                  colorScheme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(VoidCallback onTap, ColorScheme colorScheme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: colorScheme.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            RemixIcons.delete_bin_7_line,
            color: colorScheme.error,
            size: 20.sp,
          ),
        ),
      ),
    );
  }

  void _confirmDelete(VehicleModel veiculo, ThemeData theme) {
    Get.defaultDialog(
      title: "veh_excluir_titulo".tr,
      middleText: "veh_excluir_confirm".tr,
      backgroundColor: theme.cardColor,
      titleStyle: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
      middleTextStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
      radius: 20.r,
      textConfirm: 'veh_sim'.tr,
      textCancel: 'veh_nao'.tr,
      confirmTextColor: Colors.white,
      cancelTextColor: theme.colorScheme.primary,
      buttonColor: theme.colorScheme.error,
      onConfirm: () {
        controller.deleteVeiculo(veiculo.id);
        Get.back();
      },
    );
  }
}
