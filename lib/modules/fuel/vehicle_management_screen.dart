// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:fuel_tracker_app/data/models/vehicle_model.dart';
// import 'package:fuel_tracker_app/modules/fuel/widgets/vehicle_entry_screen.dart';
// import 'package:fuel_tracker_app/core/app_theme.dart';
// import 'package:fuel_tracker_app/core/app_localizations.dart';
// import 'package:fuel_tracker_app/core/vehicle_plate_widget.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:remixicon/remixicon.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:share_plus/share_plus.dart';

// class VehicleManagementScreen extends GetView<VehicleController> {
//   const VehicleManagementScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     if (!Get.isRegistered<VehicleController>()) {
//       Get.put(VehicleController());
//     }

//     final theme = Theme.of(context);
//     final isDarkMode = theme.brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: isDarkMode
//           ? AppTheme.backgroundColorDark
//           : AppTheme.backgroundColorLight,
//       appBar: AppBar(
//         title: Text(context.tr(TranslationKeys_5.vehiclesScreenTitle)),
//         backgroundColor: isDarkMode
//             ? AppTheme.backgroundColorDark
//             : AppTheme.backgroundColorLight,
//         elevation: theme.appBarTheme.elevation,
//         centerTitle: theme.appBarTheme.centerTitle,
//       ),
//       body: Obx(() {
//         final vehicles = controller.vehicles;
//         if (vehicles.isEmpty) {
//           return Center(
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Text(
//                 context.tr(TranslationKeys_5.vehiclesEmptyList),
//                 style: theme.textTheme.bodyLarge?.copyWith(
//                   color: theme.hintColor,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           );
//         }
//         return ListView.builder(
//           padding: const EdgeInsets.all(8.0),
//           itemCount: vehicles.length,
//           itemBuilder: (context, index) {
//             final vehicle = vehicles[index];
//             return VehicleCard(vehicle: vehicle);
//           },
//         );
//       }),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => controller.navigateToAddEntry(context),
//         backgroundColor: AppTheme.primaryFuelColor,
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
// }

// class VehicleCard extends StatelessWidget {
//   final VehicleModel vehicle;
//   final ScreenshotController _screenshotController = ScreenshotController();
//   VehicleCard({required this.vehicle});

//   final VehicleController controller = Get.find<VehicleController>();

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDarkMode = theme.brightness == Brightness.dark;

//     return Screenshot(
//       controller: _screenshotController,
//       child: Card(
//         color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
//         elevation: 3,
//         margin: const EdgeInsets.only(bottom: 12.0),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: InkWell(
//           onTap: () => controller.navigateToAddEntry(context, data: vehicle),
//           child: Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Column(
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     _buildVehicleAvatar(vehicle),
//                     const SizedBox(width: 12),

//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             vehicle.nickname,
//                             style: theme.textTheme.titleMedium?.copyWith(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             '${vehicle.make} ${vehicle.model} • ${vehicle.year}',
//                             style: theme.textTheme.bodySmall?.copyWith(
//                               color: theme.hintColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     VehiclePlateWidget(
//                       plate: vehicle.plate,
//                       isMercosul: vehicle.isMercosul,
//                       city: vehicle.city,
//                     ),
//                     _buildPopupMenu(context),
//                   ],
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 8.0),
//                   child: Divider(height: 1),
//                 ),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     _buildStatusItem(
//                       context,
//                       RemixIcons.gas_station_line,
//                       vehicle.fuelTypeName ?? "Flex",
//                     ),
//                     _buildStatusItem(
//                       context,
//                       RemixIcons.drop_line,
//                       "${vehicle.tankCapacity.toStringAsFixed(0)}L",
//                     ),
//                     _buildStatusItem(
//                       context,
//                       RemixIcons.speed_up_line,
//                       "${vehicle.initialOdometer.toInt()} km",
//                       label: "Início",
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPopupMenu(BuildContext context) {
//     return PopupMenuButton<String>(
//       icon: const Icon(Icons.more_vert, size: 20),
//       onSelected: (value) {
//         if (value == 'share') _shareCard();
//         if (value == 'delete') _confirmDelete(context);
//       },
//       itemBuilder: (context) => [
//         PopupMenuItem(
//           value: 'share',
//           child: Row(
//             children: [
//               Icon(RemixIcons.share_line, size: 18),
//               SizedBox(width: 8),
//               Text('Compartilhar'),
//             ],
//           ),
//         ),
//         PopupMenuItem(
//           value: 'edit',
//           child: Row(
//             children: [
//               Icon(RemixIcons.edit_line, size: 18),
//               SizedBox(width: 8),
//               Text('Editar'),
//             ],
//           ),
//           onTap: () => controller.navigateToAddEntry(context, data: vehicle),
//         ),
//         PopupMenuItem(
//           value: 'delete',
//           child: Row(
//             children: [
//               Icon(RemixIcons.delete_bin_3_line, size: 18, color: Colors.red),
//               SizedBox(width: 8),
//               Text('Excluir', style: TextStyle(color: Colors.red)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Future<void> _shareCard() async {
//     final image = await _screenshotController.capture();
//     if (image != null) {
//       final directory = await getTemporaryDirectory();
//       final imagePath = await File(
//         '${directory.path}/${vehicle.nickname}.png',
//       ).create();
//       await imagePath.writeAsBytes(image);
//       await Share.shareXFiles([
//         XFile(imagePath.path),
//       ], text: 'Meu veículo cadastrado no Fuel Tracker!');
//     }
//   }

//   Widget _buildStatusItem(
//     BuildContext context,
//     IconData icon,
//     String value, {
//     String? label,
//   }) {
//     return Row(
//       children: [
//         Icon(icon, size: 14, color: Theme.of(context).primaryColor),
//         const SizedBox(width: 4),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (label != null)
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 9,
//                   color: Theme.of(context).hintColor,
//                 ),
//               ),
//             Text(
//               value,
//               style: Theme.of(
//                 context,
//               ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildVehicleAvatar(VehicleModel vehicle) {
//     return CircleAvatar(
//       radius: 28,
//       backgroundColor: AppTheme.primaryFuelColor.withOpacity(0.1),
//       backgroundImage:
//           (vehicle.imageUrl != null && vehicle.imageUrl!.isNotEmpty)
//           ? FileImage(File(vehicle.imageUrl!))
//           : null,
//       child: (vehicle.imageUrl == null || vehicle.imageUrl!.isEmpty)
//           ? Icon(
//               RemixIcons.car_line,
//               color: AppTheme.primaryFuelColor,
//               size: 28,
//             )
//           : null,
//     );
//   }

//   void _confirmDelete(BuildContext context) {
//     final controller = Get.find<VehicleController>();
//     Get.defaultDialog(
//       title: context.tr(TranslationKeys_5.vehiclesDelete),
//       middleText: context
//           .tr(TranslationKeys_5.vehiclesDeleteConfirm)
//           .replaceAll('{nickname}', vehicle.nickname),
//       textConfirm: context.tr(TranslationKeys_5.vehiclesDelete),
//       textCancel: context.tr(TranslationKeys_5.vehiclesCancel),
//       confirmTextColor: AppTheme.cardLight,
//       onConfirm: () {
//         controller.deleteVehicle(vehicle.id!);
//         Get.back();
//       },
//       onCancel: () => Get.back(),
//       buttonColor: AppTheme.primaryFuelColor,
//       cancelTextColor: AppTheme.primaryFuelColor,
//     );
//   }
// }
