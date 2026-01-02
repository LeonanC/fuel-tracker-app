import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/models/gas_station_model.dart';
import 'package:fuel_tracker_app/controllers/gas_station_controller.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:uuid/uuid.dart';

class GasStationManagementScreen extends GetView<GasStationController> {
  GasStationManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<GasStationController>()) {
      Get.put(GasStationController());
    }
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
      appBar: AppBar(
        title: Text(context.tr(TranslationKeys.gasStationScreenTitle).tr),
        backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
        elevation: theme.appBarTheme.elevation,
        centerTitle: theme.appBarTheme.centerTitle,
      ),
      body: Obx(() {
        final stations = controller.stations;

        if (stations.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(RemixIcons.gas_station_line, size: 64, color: AppTheme.textGrey),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum Posto cadastrado.'.tr,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium!.copyWith(color: AppTheme.textGrey),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: stations.length,
          itemBuilder: (context, index) {
            final gasStation = stations[index];
            return PostoCard(stations: gasStation);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'gas_station_tag',
        onPressed: () => controller.navigateToAddEntry(context),
        backgroundColor: AppTheme.primaryFuelColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class PostoCard extends StatelessWidget {
  final GasStationModel stations;

  PostoCard({super.key, required this.stations});

  final GasStationController controller = Get.find<GasStationController>();

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
        leading: Icon(RemixIcons.gas_station_fill, color: AppTheme.primaryFuelColor, size: 32),
        title: Text(stations.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bandeira: ${stations.brand}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(RemixIcons.gas_station_fill, size: 16, color: AppTheme.primaryFuelColor),
                const SizedBox(width: 4),
                Flexible(child: Text('G: ${stations.priceGasolineComum}')),
                const SizedBox(width: 12),
                Icon(RemixIcons.flask_fill, size: 16, color: AppTheme.primaryFuelColor),
                const SizedBox(width: 4),
                Flexible(child: Text('E: ${stations.priceEthanol}')),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (String result) {
            if (result == 'share') {
              // _showGasForm(context, stations);
            } else if (result == 'delete') {
              _confirmDelete(context);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(value: 'share', child: Text('Compartilhar')),
            const PopupMenuItem<String>(value: 'delete', child: Text('Excluir')),
          ],
        ),
        onTap: () => controller.navigateToAddEntry(context, data: stations),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final controller = Get.find<GasStationController>();

    Get.defaultDialog(
      title: context.tr(TranslationKeys.gasStationButtonDelete),
      middleText: context.tr(TranslationKeys.gasStationButtonDeleteSubtitle),
      textConfirm: context.tr(TranslationKeys.gasStationButtonDeleteConfirm),
      textCancel: context.tr(TranslationKeys.gasStationButtonDeleteCancel),
      confirmTextColor: AppTheme.cardLight,
      onConfirm: () {
        // controller.deleteGasStation(stations.id);
        Get.back();
      },
      onCancel: () => Get.back(),
      buttonColor: AppTheme.primaryFuelColor,
      cancelTextColor: AppTheme.primaryFuelAccent,
    );
  }
}
