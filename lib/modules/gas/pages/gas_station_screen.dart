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
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Postos de Combustível',
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => Get.to(() => GasEntryScreen()),
        label: Text(
          "Novo Posto",
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
        final postos = controller.postosMap.values.toList();

        if (postos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  RemixIcons.gas_station_line,
                  size: 64,
                  color: Colors.white10,
                ),
                SizedBox(height: 16.h),
                Text(
                  "Nenhum posto cadastrado",
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
          onRefresh: () => controller.fetchPosto(),
          color: theme.colorScheme.primary,
          backgroundColor: theme.cardColor,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            itemCount: postos.length,
            itemBuilder: (context, index) {
              final data = postos[index];
              final posto = GasStationModel.fromFirestore(
                data,
                data['pk_posto'],
              );

              return _buildPostoCard(posto, theme);
            },
          ),
        );
      }),
    );
  }

  Widget _buildPostoCard(GasStationModel posto, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: InkWell(
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
                      color: const Color(0xFF00A3FF).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      RemixIcons.gas_station_fill,
                      color: Color(0xFF00A3FF),
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
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          posto.brand,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.white60,
                            fontSize: 12.sp,
                          ),
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
                    onPressed: () => _confirmDelete(posto),
                  ),
                ],
              ),
              Divider(height: 24.h, color: Colors.white10),
              Row(
                children: [
                  Icon(
                    RemixIcons.map_pin_2_line,
                    size: 14.sp,
                    color: Colors.white38,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      '${posto.address}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white70,
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
                    "Loja",
                    posto.hasConvenientStore,
                  ),
                  SizedBox(width: 8.w),
                  _buildBadge(RemixIcons.time_line, "24h", posto.is24Hours),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, bool active) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: active
            ? Colors.green.withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 12.sp,
            color: active ? Colors.greenAccent : Colors.white24,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: active ? Colors.greenAccent : Colors.white24,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(GasStationModel posto) {
    Get.defaultDialog(
      title: "Excluir Posto",
      middleText: "Deseja remover ${posto.nome}?",
      backgroundColor: const Color(0xFF1A1A1A),
      titleStyle: const TextStyle(color: Colors.white),
      middleTextStyle: const TextStyle(color: Colors.white70),
      textConfirm: 'Sim',
      textCancel: 'Não',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        controller.deletePosto(posto.id);
        Get.back();
      },
    );
  }
}
