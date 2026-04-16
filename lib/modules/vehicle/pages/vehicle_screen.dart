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
      appBar: AppBar(
        title: Text(
          'veh_titulo'.tr,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorScheme.primary,
        onPressed: () => Get.to(() => VehicleEntryScreen()),
        label: Text(
          "veh_novo_veiculo".tr,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        icon: Icon(RemixIcons.add_line, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: theme.cardColor),
          );
        }
        final veiculos = controller.vehiclesMap.values.toList();

        if (veiculos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  RemixIcons.car_line,
                  size: 64,
                  color: colorScheme.onSurface.withOpacity(0.1),
                ),
                SizedBox(height: 16.h),
                Text(
                  "veh_nenhum_veiculo".tr,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchVehicle(),
          color: colorScheme.primary,
          backgroundColor: theme.cardColor,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            itemCount: veiculos.length,
            itemBuilder: (context, index) {
              final data = veiculos[index];
              final veiculo = VehicleModel.fromFirestore(
                data,
                data['pk_vehicle'],
              );

              return _buildvecCard(veiculo, theme);
            },
          ),
        );
      }),
    );
  }

  Widget _buildvecCard(VehicleModel veiculo, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: () => Get.to(() => VehicleEntryScreen(data: veiculo)),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  RemixIcons.car_fill,
                  color: colorScheme.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      veiculo.nickname,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${veiculo.make} ${veiculo.model} ${veiculo.year}",
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  RemixIcons.delete_bin_line,
                  color: colorScheme.error,
                  size: 20.sp,
                ),
                onPressed: () => _confirmDelete(veiculo, theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(VehicleModel veiculo, ThemeData theme) {
    Get.defaultDialog(
      title: "veh_excluir_titulo".tr,
      middleText: "veh_excluir_confirm".tr,
      backgroundColor: const Color(0xFF1A1A1A),
      titleStyle: const TextStyle(color: Colors.white),
      middleTextStyle: const TextStyle(color: Colors.white70),
      textConfirm: 'veh_sim'.tr,
      textCancel: 'veh_nao'.tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        controller.deleteVeiculo(veiculo.id);
        Get.back();
      },
    );
  }
}
