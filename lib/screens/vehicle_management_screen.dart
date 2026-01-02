import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/controllers/vehicle_controller.dart';
import 'package:fuel_tracker_app/models/vehicle_model.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class VehicleManagementScreen extends GetView<VehicleController> {
  const VehicleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<VehicleController>()) {
      Get.put(VehicleController());
    }

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
      appBar: AppBar(
        title: Text(context.tr(TranslationKeys.vehiclesScreenTitle)),
        backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
        elevation: theme.appBarTheme.elevation,
        centerTitle: theme.appBarTheme.centerTitle,
      ),
      body: Obx(() {
        final vehicles = controller.vehicles;
        if (vehicles.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                context.tr(TranslationKeys.vehiclesEmptyList),
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = vehicles[index];
            return VehicleCard(vehicle: vehicle);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.navigateToAddEntry(context),
        backgroundColor: AppTheme.primaryFuelColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  VehicleCard({required this.vehicle});

  final VehicleController controller = Get.find<VehicleController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppTheme.primaryFuelColor.withOpacity(0.15),
          backgroundImage: vehicle.imageUrl != null ? FileImage(File(vehicle.imageUrl!)) : null,
          child: vehicle.imageUrl == null
              ? Icon(Icons.directions_car, color: AppTheme.primaryFuelColor)
              : null,
        ),
        title: Text(vehicle.nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${vehicle.make} ${vehicle.model} (${vehicle.year}) | ${vehicle.fuelTypeName}'),
        trailing: PopupMenuButton<String>(
          onSelected: (String result) {
            if (result == 'share') {
              // _showVehicleForm(context, vehicle);
            } else if (result == 'delete') {
              _confirmDelete(context);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(value: 'share', child: Text('Compartilhar')),
            const PopupMenuItem<String>(value: 'delete', child: Text('Excluir')),
          ],
        ),
        onTap: () => controller.navigateToAddEntry(context, data: vehicle),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final controller = Get.find<VehicleController>();
    Get.defaultDialog(
      title: context.tr(TranslationKeys.vehiclesDelete),
      middleText: context
          .tr(TranslationKeys.vehiclesDeleteConfirm)
          .replaceAll('{nickname}', vehicle.nickname),
      textConfirm: context.tr(TranslationKeys.vehiclesDelete),
      textCancel: context.tr(TranslationKeys.vehiclesCancel),
      confirmTextColor: AppTheme.cardLight,
      onConfirm: () {
        // controller.deleteVehicle(vehicle.id);
        Get.back();
      },
      onCancel: () => Get.back(),
      buttonColor: AppTheme.primaryFuelColor,
      cancelTextColor: AppTheme.primaryFuelColor,
    );
  }
}
