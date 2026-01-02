import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/controllers/vehicle_controller.dart';
import 'package:fuel_tracker_app/models/vehicle_model.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remixicon/remixicon.dart';
import 'package:uuid/uuid.dart';

class VehicleEntryScreen extends StatefulWidget {
  final VehicleModel? data;
  const VehicleEntryScreen({super.key, this.data});

  @override
  State<VehicleEntryScreen> createState() => _VehicleEntryScreenState();
}

class _VehicleEntryScreenState extends State<VehicleEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _nickname;
  late String _make;
  late String _model;
  late int _fuelType;
  late int _year;
  late double _initialOdometer;
  String? _imageUrl;
  int? _selectedFuelId;

  final ImagePicker _picker = ImagePicker();
  final VehicleController controller = Get.find<VehicleController>();

  @override
  void initState() {
    super.initState();
    final vehicle = widget.data;
    _nickname = vehicle?.nickname ?? '';
    _make = vehicle?.make ?? '';
    _model = vehicle?.model ?? '';
    _selectedFuelId = widget.data?.fuelType;
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
      final vehicleCreatedAt = widget.data?.createdAt;

      final newVehicle = VehicleModel(
        nickname: _nickname,
        make: _make,
        model: _model,
        fuelType: _selectedFuelId!,
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
    final isEditing = widget.data != null;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
        title: Text(
          context.tr(
            isEditing ? TranslationKeys.vehiclesEditVehicle : TranslationKeys.vehiclesAddNewVehicle,
          ),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        centerTitle: theme.appBarTheme.centerTitle,
        elevation: theme.appBarTheme.elevation,
        actions: [
          IconButton(
            icon: isEditing ? Icon(RemixIcons.edit_line) : Icon(RemixIcons.save_line),
            onPressed: _submit,
            tooltip: isEditing
                ? context.tr(TranslationKeys.vehiclesEditVehicle)
                : context.tr(TranslationKeys.vehiclesSave),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
              Obx(
                () => DropdownButtonFormField<int>(
                  value:
                      controller.fuelTypes.any(
                        (element) => element.id == _selectedFuelId,
                      )
                      ? _selectedFuelId
                      : null,
                  decoration: InputDecoration(
                    labelText: context.tr(TranslationKeys.vehiclesFuelType),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  items: controller.fuelTypes.map((type) {
                    return DropdownMenuItem<int>(
                      value: type.id, 
                      child: Text(type.nome),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedFuelId = val),
                  validator: (value) => value == null ? 'Selecione um combustível' : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
