import 'dart:io';

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
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Meus Veículos',
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
        backgroundColor: theme.colorScheme.primary,
        onPressed: () => Get.to(() => VehicleEntryScreen()),
        label: Text(
          "Novo Veículo",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        icon: Icon(RemixIcons.add_line, color: Colors.black),
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
                Icon(RemixIcons.car_line, size: 64, color: Colors.white10),
                SizedBox(height: 16.h),
                Text(
                  "Nenhum veiculo cadastrado",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchVehicle(),
          color: theme.colorScheme.primary,
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
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: InkWell(
        onTap: () => Get.to(() => VehicleEntryScreen(data: veiculo)),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.r),
                  child:
                      (veiculo.imageUrl != null && veiculo.imageUrl!.isNotEmpty)
                      ? Image.file(
                          File(veiculo.imageUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              RemixIcons.car_fill,
                              color: theme.colorScheme.primary,
                              size: 30.sp,
                            );
                          },
                        )
                      : Icon(
                          RemixIcons.car_fill,
                          color: theme.colorScheme.primary,
                          size: 30.sp,
                        ),
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
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${veiculo.make} ${veiculo.model} ${veiculo.year}",
                      style: TextStyle(color: Colors.white60, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  RemixIcons.delete_bin_line,
                  color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: () => _confirmDelete(veiculo),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(VehicleModel veiculo) {
    Get.defaultDialog(
      title: "Excluir Veiculo",
      middleText: "Deseja remover ${veiculo.nickname}",
      backgroundColor: const Color(0xFF1A1A1A),
      titleStyle: const TextStyle(color: Colors.white),
      middleTextStyle: const TextStyle(color: Colors.white70),
      textConfirm: 'Sim',
      textCancel: 'Não',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        controller.deleteVeiculo(veiculo.id);
        Get.back();
      },
    );
  }
}
