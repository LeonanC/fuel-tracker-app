import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/models/gas_station_model.dart';
import 'package:fuel_tracker_app/controllers/gas_station_controller.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

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
  final ScreenshotController _screenshotController = ScreenshotController();

  PostoCard({super.key, required this.stations});

  final GasStationController controller = Get.find<GasStationController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Screenshot(
      controller: _screenshotController,
      child: Card(
        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => controller.navigateToAddEntry(context, data: stations),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryFuelColor.withOpacity(0.1),
                      child: Icon(RemixIcons.gas_station_fill, color: AppTheme.primaryFuelColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(stations.nome, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text(stations.brand, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                        ],
                      ),
                    ),
                    _buildStatusIcons(),
                    _buildPopupMenu(context),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPriceInfo(context, "Gasolina", stations.priceGasolineComum, RemixIcons.drop_fill),
                    Container(width: 1, height: 30, color: theme.dividerColor),
                    _buildPriceInfo(context, "Etanol", stations.priceEthanol, RemixIcons.leaf_fill),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcons(){
    return Row(
      children: [
        if(stations.is24Hours)
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(RemixIcons.time_line, size: 28, color: Colors.orange),
          ),
        if(stations.hasConvenientStore)
          const Icon(RemixIcons.store_2_line, size: 18, color: Colors.blue),
      ],
    );
  }

  Widget _buildPriceInfo(BuildContext context, String label, double price, IconData icon){
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.primaryFuelColor),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        Text(
          'R\$ ${price.toStringAsFixed(3)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        )
      ],
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      onSelected: (value) {
        if(value == 'share') _shareCard();
        if (value == 'delete') _confirmDelete(context);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 'share',
          child: Row(
            children: [Icon(RemixIcons.share_line, size: 18), SizedBox(width: 8), Text('Compartilhar')],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [Icon(RemixIcons.edit_line, size: 18), SizedBox(width: 8), Text('Editar')],
          ),
          onTap: () => controller.navigateToAddEntry(context, data: stations),
        ),
        PopupMenuItem(
          value: 'delete', 
          child: Row(
            children: [
              Icon(RemixIcons.delete_bin_3_line, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Excluir', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _shareCard() async {
    final image = await _screenshotController.capture();
    if(image != null){
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/${stations.nome}.png').create();
      await imagePath.writeAsBytes(image);
      await Share.shareXFiles([XFile(imagePath.path)], text: 'Localização do posto cadastro no Fuel Tracker!');
    }
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
        controller.deleteGasStation(stations.id!);
        Get.back();
      },
      onCancel: () => Get.back(),
      buttonColor: AppTheme.primaryFuelColor,
      cancelTextColor: AppTheme.primaryFuelAccent,
    );
  }
}
