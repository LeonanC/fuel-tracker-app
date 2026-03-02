import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker_app/core/app_theme.dart';
import 'package:fuel_tracker_app/data/models/gas_station_model.dart';
import 'package:fuel_tracker_app/data/models/vehicle_model.dart';
import 'package:fuel_tracker_app/data/services/application.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/lookup_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class VehicleScreen extends GetView<FuelListController> {
  const VehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010101),
      appBar: AppBar(
        title: const Text('Meus Veículos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        final veiculos = controller.veiculosMap.values.toList();

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: veiculos.length,
          itemBuilder: (context, index) {
            final vec = veiculos[index];
            return Dismissible(
              key: Key(vec['pk_vehicle'].toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20.w),
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(RemixIcons.delete_bin_line, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                return await Get.dialog<bool>(
                  AlertDialog(
                    backgroundColor: AppTheme.cardDark,
                    title: const Text(
                      "Excluir Veículo",
                      style: TextStyle(color: Colors.white),
                    ),
                    content: Text(
                      "Deseja realmente remover ${vec['nickname']}?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text("Cancelar"),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        child: const Text(
                          "Excluir",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direction) {
                // controller.deletevec(vec['pk_vehicle']);
              },
              child: _buildvecCard(vec),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryFuelColor,
        onPressed: () => _showEditDialog(context),
        child: Icon(RemixIcons.add_line, color: Colors.black),
      ),
    );
  }

  Widget _buildvecCard(Map<String, dynamic> vec) {
    final path = vec['imagem_url'];

    if (path == null || path.toString().isEmpty) {
      return Icon(RemixIcons.car_fill, color: AppTheme.primaryFuelColor);
    }

    final file = File(path);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(
              file,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(RemixIcons.image_line, color: Colors.white24);
              },
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vec['nickname'] ?? 'Sem nome',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${vec['make']} ${vec['model']} ${vec['year']}",
                  style: TextStyle(color: Colors.white60, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(RemixIcons.edit_box_line, color: Colors.white54),
            onPressed: () => _showEditDialog(Get.context!, vec: vec),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, {Map<String, dynamic>? vec}) {
    final fuelListController = Get.find<FuelListController>();
    final lookupController = Get.find<LookupController>();

    final nickCtrl = TextEditingController(text: vec?['nickname']);
    final plateCtrl = TextEditingController(text: vec?['plate']);
    final cityCtrl = TextEditingController(text: vec?['city']);
    final makeCtrl = TextEditingController(text: vec?['make']);
    final modelCtrl = TextEditingController(text: vec?['model']);
    final yearCtrl = TextEditingController(text: vec?['year']?.toString());
    final tankCtrl = TextEditingController(
      text: vec?['tank_capacity']?.toString(),
    );
    final odometerCtrl = TextEditingController(
      text: vec?['initial_odometer']?.toString(),
    );
    final isMercosul = (vec?['is_mercosul'] == true).obs;

    var tipo = (vec?['fk_type_fuel'] ?? lookupController.tipoDrop.first.id);

    Get.bottomSheet(
      isScrollControlled: true,
      ignoreSafeArea: false,
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Editar Veículo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              _buildTextField(
                nickCtrl,
                'Apelido (ex: Meu Carro)',
                RemixIcons.user_smile_line,
              ),
              SizedBox(height: 12.h),
              _buildTextField(cityCtrl, 'Cidade', RemixIcons.community_line),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      makeCtrl,
                      'Marca',
                      RemixIcons.car_line,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildTextField(
                      modelCtrl,
                      'Modelo',
                      RemixIcons.car_washing_line,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        plateCtrl,
                        "Placa",
                        RemixIcons.bank_card_line,
                      ),
                    ),
                    _buildCustomSelectableCard(
                      label: 'Mercosul',
                      icon: RemixIcons.global_line,
                      isSelected: isMercosul.value,
                      onTap: () => isMercosul.toggle(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                yearCtrl,
                "Ano",
                RemixIcons.calendar_line,
                isNumber: true,
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                odometerCtrl,
                "Initial Odometer (Km)",
                RemixIcons.dashboard_line,
                isNumber: true,
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                tankCtrl,
                "Capacidade do Tanque (L)",
                RemixIcons.drop_line,
                isNumber: true,
              ),
              SizedBox(height: 12.h),
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: tipo,
                      style: const TextStyle(color: Colors.white),
                      dropdownColor: AppTheme.cardDark,
                      items: lookupController.tipoDrop
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(
                                e.nome,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) tipo = v;
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryFuelColor,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                  ),
                  onPressed: () async {
                    final novovec = VehicleModel(
                      id:
                          int.tryParse(vec?['pk_vehicle']?.toString() ?? '0') ??
                          0,
                      nickname: nickCtrl.text,
                      plate: plateCtrl.text,
                      city: cityCtrl.text,
                      make: makeCtrl.text,
                      model: modelCtrl.text,
                      year: int.tryParse(yearCtrl.text) ?? 2024,
                      tankCapacity: double.tryParse(tankCtrl.text) ?? 0.0,
                      createdAt:
                          vec?['created_at'] ??
                          DateTime.now().toIso8601String(),
                      fuelType: tipo,
                      initialOdometer:
                          double.tryParse(odometerCtrl.text) ?? 0.0,
                    );

                    // controller.saveOrUpdate(novovec);
                    Get.back();
                  },
                  child: Text(
                    vec == null ? "SALVAR" : "EDITAR",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    bool isAddress = false,
    VoidCallback? onGPSClick,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: AppTheme.primaryFuelColor),
        suffixIcon: isAddress
            ? IconButton(
                icon: Icon(
                  RemixIcons.focus_3_line,
                  color: AppTheme.primaryFuelColor,
                ),
                onPressed: onGPSClick,
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCustomSelectableCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryFuelColor.withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryFuelColor
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryFuelColor : Colors.white38,
                size: 22.sp,
              ),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white38,
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
