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
        onPressed: () => _showVehicleForm(context),
        backgroundColor: AppTheme.primaryFuelColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

void _showVehicleForm(BuildContext context, [VehicleModel? vehicle]) {
  Get.dialog(VehicleForm(vehicle: vehicle), useSafeArea: true, barrierDismissible: true);
}

class VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  const VehicleCard({required this.vehicle});

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
        subtitle: Text('${vehicle.make} ${vehicle.model} (${vehicle.year}) | ${vehicle.fuelType}'),
        trailing: PopupMenuButton<String>(
          onSelected: (String result) {
            if (result == 'edit') {
              _showVehicleForm(context, vehicle);
            } else if (result == 'delete') {
              _confirmDelete(context);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(value: 'edit', child: Text('Editar')),
            const PopupMenuItem<String>(value: 'delete', child: Text('Excluir')),
          ],
        ),
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
        controller.deleteVehicle(vehicle.id);
        Get.back();
      },
      onCancel: () => Get.back(),
      buttonColor: AppTheme.primaryFuelColor,
      cancelTextColor: AppTheme.primaryFuelColor,
    );
  }
}

class VehicleForm extends StatefulWidget {
  final VehicleModel? vehicle;
  const VehicleForm({super.key, this.vehicle});

  @override
  State<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  final _formKey = GlobalKey<FormState>();
  late String _nickname;
  late String _make;
  late String _model;
  late String _fuelType;
  late int _year;
  late double _initialOdometer;
  String? _imageUrl;

  final ImagePicker _picker = ImagePicker();
  final VehicleController controller = Get.find<VehicleController>();
  final List<String> _fuelTypes = ['Flex', 'Gasolina', 'Gasolina Comum', 'Etanol', 'Diesel', 'Elétrico'];

  @override
  void initState() {
    super.initState();
    final vehicle = widget.vehicle;
    _nickname = vehicle?.nickname ?? '';
    _make = vehicle?.make ?? '';
    _model = vehicle?.model ?? '';
    _fuelType = vehicle?.fuelType ?? 'Gasolina';
    _year = vehicle?.year ?? DateTime.now().year;
    _initialOdometer = vehicle?.initialOdometer ?? 0.0;
    _imageUrl = vehicle?.imageUrl;
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 79);

    if (pickedFile != null) {
      setState(() {
        _imageUrl = pickedFile.path;
      });
    }

    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        color: Theme.of(context).cardColor,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(context.tr(TranslationKeys.vehiclesChooseFromGallery)),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(context.tr(TranslationKeys.vehiclesTakePhoto)),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              if (_imageUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    context.tr(TranslationKeys.vehiclesRemovePhoto),
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    setState(() {
                      _imageUrl = null;
                    });
                    Get.back();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final vehicleId = widget.vehicle?.id ?? const Uuid().v4();
      final vehicleCreatedAt = widget.vehicle?.createdAt;

      final newVehicle = VehicleModel(
        id: vehicleId,
        nickname: _nickname,
        make: _make,
        model: _model,
        fuelType: _fuelType,
        year: _year,
        initialOdometer: _initialOdometer,
        imageUrl: _imageUrl,
        createdAt: vehicleCreatedAt,
      );
      controller.saveVehicle(newVehicle);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vehicle != null;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        context.tr(
          isEditing ? TranslationKeys.vehiclesEditVehicle : TranslationKeys.vehiclesAddNewVehicle,
        ),
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineSmall,
      ),
      content: SizedBox(
        width: Get.width * 0.9,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _showImageSourceActionSheet(context),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryFuelColor.withOpacity(0.2),
                    backgroundImage: _imageUrl != null ? FileImage(File(_imageUrl!)) : null,
                    child: _imageUrl == null
                        ? Icon(Icons.camera_alt, size: 40, color: AppTheme.primaryFuelColor)
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _nickname,
                  decoration: InputDecoration(
                    labelText: context.tr(TranslationKeys.vehiclesNickname),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  onSaved: (value) => _nickname = value ?? '',
                  validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _make,
                  decoration: InputDecoration(
                    labelText: context.tr(TranslationKeys.vehiclesMake),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  onSaved: (value) => _make = value ?? '',
                  validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _model,
                  decoration: InputDecoration(labelText: context.tr(TranslationKeys.vehiclesModel)),
                  onSaved: (value) => _model = value ?? '',
                  validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _year.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: context.tr(TranslationKeys.vehiclesYear),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  onSaved: (value) {
                    _year = int.tryParse(value ?? '0') ?? 0;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    final year = int.tryParse(value);
                    final currentYear = DateTime.now().year;
                    if (year == null || year < 1900 || year > currentYear + 1) {
                      return 'Ano inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _initialOdometer.toStringAsFixed(0),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: context.tr(TranslationKeys.vehiclesOdometer),
                    suffixText: 'km',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  onSaved: (value) {
                    final cleanedValue = value?.replaceAll(',', '.');
                    _initialOdometer = double.tryParse(cleanedValue ?? '0.0') ?? 0.0;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    final cleanedValue = value.replaceAll(',', '.');
                    if (double.tryParse(cleanedValue) == null) {
                      return 'Insire um valor numérico válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _fuelType,
                  decoration: InputDecoration(
                    labelText: context.tr(TranslationKeys.vehiclesFuelType),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  items: _fuelTypes.map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _fuelType = newValue!;
                    });
                  },
                  onSaved: (value) => _fuelType = value ?? 'Flex',
                ),
              ],
            ),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(context.tr(TranslationKeys.vehiclesCancel)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryFuelColor,
            foregroundColor: AppTheme.cardLight,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(
            context.tr(
              isEditing ? TranslationKeys.vehiclesSave : TranslationKeys.vehiclesAddNewVehicle,
            ),
          ),
        ),
      ],
    );
  }
}
