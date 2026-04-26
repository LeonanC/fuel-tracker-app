import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker_app/data/models/gas_station_model.dart';
import 'package:fuel_tracker_app/modules/gas/controller/gasStation_controller.dart';
import 'package:fuel_tracker_app/modules/registro/pages/gas_entry_screen.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class GasStationScreen extends GetView<GasStationController> {
  const GasStationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'gs_titulo'.tr,
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
        onPressed: () => Get.to(() => GasEntryScreen()),
        label: Text(
          "gs_novo_posto".tr,
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
        final postos = controller.postosMap.values.toList();

        if (postos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  RemixIcons.gas_station_line,
                  size: 64.sp,
                  color: colorScheme.onSurface.withOpacity(0.1),
                ),
                SizedBox(height: 16.h),
                Text(
                  "gs_nenhum_posto".tr,
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
          onRefresh: () => controller.fetchPosto(),
          color: colorScheme.primary,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            itemCount: postos.length,
            itemBuilder: (context, index) {
              final data = postos[index];
              final posto = GasStationModel.fromMap(data);

              return _buildPostoCard(posto, theme);
            },
          ),
        );
      }),
    );
  }

  Widget _buildPostoCard(GasStationModel posto, ThemeData theme) {
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
        onTap: () => Get.to(() => GasEntryScreen(data: posto)),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      RemixIcons.gas_station_fill,
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
                          posto.nome,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: colorScheme.onSurface,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          posto.brand,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
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
                    onPressed: () => _confirmDelete(posto, theme),
                  ),
                ],
              ),
              Divider(
                height: 24.h,
                color: colorScheme.onSurface.withOpacity(0.05),
              ),
              Row(
                children: [
                  Icon(
                    RemixIcons.map_pin_2_line,
                    size: 14.sp,
                    color: colorScheme.onSurface.withOpacity(0.4),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      '${posto.address}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  _buildBadge(
                    RemixIcons.shopping_basket_line,
                    "gs_loja".tr,
                    posto.hasConvenientStore,
                    theme,
                  ),
                  SizedBox(width: 8.w),
                  _buildBadge(
                    RemixIcons.time_line,
                    "gs_24h".tr,
                    posto.is24Hours,
                    theme,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
    IconData icon,
    String label,
    bool active,
    ThemeData theme,
  ) {
    final colorSheme = theme.colorScheme;
    final Color activeColor = Colors.greenAccent;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: active
            ? activeColor.withOpacity(0.1)
            : colorSheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 12.sp,
            color: active ? activeColor : colorSheme.onSurface.withOpacity(0.2),
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: active
                  ? activeColor
                  : colorSheme.onSurface.withOpacity(0.2),
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(GasStationModel posto, ThemeData theme) {
    Get.defaultDialog(
      title: "gs_excluir_titulo".tr,
      middleText: "gs_excluir_confirm".tr,
      backgroundColor: const Color(0xFF1A1A1A),
      titleStyle: const TextStyle(color: Colors.white),
      middleTextStyle: const TextStyle(color: Colors.white70),
      textConfirm: 'gs_sim'.tr,
      textCancel: 'gs_nao'.tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        controller.deletePosto(posto.id);
        Get.back();
      },
    );
  }
}
