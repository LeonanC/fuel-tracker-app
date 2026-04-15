import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker_app/data/models/maintenance_entry_model.dart';
import 'package:fuel_tracker_app/modules/maintenance/controler/maintenance_controller.dart';
import 'package:fuel_tracker_app/modules/registro/pages/maintenance_entry_screen.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class MaintenanceScreen extends GetView<MaintenanceController> {
  final double? lastOdometer;
  final MaintenanceModel? entry;
  const MaintenanceScreen({super.key, this.lastOdometer, this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'mt_titulo'.tr,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorScheme.primary,
        onPressed: () => Get.to(() => MaintenanceEntryScreen()),
        label: Text(
          "mt_novo_manutencao".tr,
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
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }
        final manutencao = controller.manutencaoMap.values.toList();

        if (manutencao.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  RemixIcons.tools_line,
                  size: 64.sp,
                  color: colorScheme.onSurface.withOpacity(0.1),
                ),
                SizedBox(height: 16.h),
                Text(
                  "mt_nenhuma_manutencao".tr,
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
          onRefresh: () => controller.fetchManutencao(),
          color: colorScheme.primary,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            itemCount: manutencao.length,
            itemBuilder: (context, index) {
              final data = manutencao[index];
              final maintenance = MaintenanceModel.fromFirestore(
                data,
                data['pk_service'],
              );

              return _buildManutencaoCard(maintenance, theme);
            },
          ),
        );
      }),
    );
  }

  Widget _buildManutencaoCard(MaintenanceModel maintenance, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container();
  }
}
