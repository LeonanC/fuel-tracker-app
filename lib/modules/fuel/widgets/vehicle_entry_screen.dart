import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/vehicle_model.dart';
import 'package:fuel_tracker_app/core/app_theme.dart';
import 'package:fuel_tracker_app/core/app_localizations.dart';
import 'package:fuel_tracker_app/core/vehicle_plate_widget.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remixicon/remixicon.dart';

class TranslationKeys_5 {
  static const String vehiclesScreenTitle = 'vehicles.screen_title';
  static const String vehiclesScreenDescription = 'vehicles.screen_description';
  static const String vehiclesEmptyList = 'vehicles.empty_list';
  static const String vehiclesAddNewVehicle = 'vehicles.add_new_vehicle';
  static const String vehiclesEditVehicle = 'vehicles.edit_vehicle';
  static const String vehiclesNickname = 'vehicles.nickname';
  static const String vehiclesPlate = 'vehicles.plate';
  static const String vehiclesNewPlate = 'Placa Mercosul';
  static const String vehiclesOldPlate = 'Placa Antiga';
  static const String vehiclesTankCapacity = 'Capacidade do Tanque';
  static const String vehiclesCity = 'vehicles.city';
  static const String vehiclesMake = 'vehicles.make';
  static const String vehiclesModel = 'vehicles.model';
  static const String vehiclesYear = 'vehicles.year';
  static const String vehiclesFuelType = 'vehicles.fuel_type';
  static const String vehiclesOdometer = 'vehicles.odometer';
  static const String vehiclesImage = 'vehicles.image';
  static const String vehiclesSelectImage = 'vehicles.select_image';
  static const String vehiclesChooseFromGallery =
      'vehicles.choose_from_gallery';
  static const String vehiclesTakePhoto = 'vehicles.take_photo';
  static const String vehiclesDeleteConfirm = 'vehicles.delete_confirm_message';
  static const String vehiclesDelete = 'vehicles.delete';
  static const String vehiclesSave = 'vehicles.save';
  static const String vehiclesCancel = 'vehicles.cancel';
  static const String vehiclesRemovePhoto = 'vehicles.remove_photo';
}

class VehicleEntryScreen extends StatefulWidget {
  final VehicleModel? data;
  const VehicleEntryScreen({super.key, this.data});

  @override
  State<VehicleEntryScreen> createState() => _VehicleEntryScreenState();
}

class _VehicleEntryScreenState extends State<VehicleEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nicknameController;
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _plateController;
  late TextEditingController _yearController;
  late TextEditingController _tankCapacityController;
  late TextEditingController _odometerController;
  late TextEditingController _cityController;

  String? _selectedImageUrl;
  bool _isMercosul = true;
  bool get _isEditing => widget.data != null;

  @override
  void initState() {
    super.initState();
    final e = widget.data;
    _nicknameController = TextEditingController(text: e?.nickname ?? '');
    _makeController = TextEditingController(text: e?.make ?? '');
    _modelController = TextEditingController(text: e?.model ?? '');
    _yearController = TextEditingController(text: e?.year.toString() ?? '');
    _plateController = TextEditingController(text: e?.plate ?? '');
    _tankCapacityController = TextEditingController(
      text: e?.tankCapacity.toString() ?? '50',
    );
    _odometerController = TextEditingController(
      text: e?.initialOdometer.toString() ?? '0',
    );
    _cityController = TextEditingController(text: e?.city ?? 'BRASIL');
    _selectedImageUrl = e?.imageUrl;
    _isMercosul = e?.isMercosul ?? true;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _selectedImageUrl = pickedFile.path);
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final vehicle = VehicleModel(
        id: widget.data?.id,
        nickname: _nicknameController.text,
        make: _makeController.text,
        model: _modelController.text,
        year: int.parse(_yearController.text),
        plate: _plateController.text,
        tankCapacity: double.parse(_tankCapacityController.text),
        initialOdometer: double.parse(_odometerController.text),
        imageUrl: _selectedImageUrl,
        isMercosul: _isMercosul,
        city: _cityController.text,
        fuelType: widget.data?.fuelType ?? 0,
        createdAt: DateTime.now().toIso8601String(),
      );

      try {
        // await controller.saveVehicle(vehicle.toMap());
        if (!mounted) return;
        Get.back();
        Get.snackbar(
          'Sucesso',
          _isEditing
              ? 'Veículo atualizado com sucesso!'
              : 'Veículo "${vehicle.nickname}" adicionado com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        print(e);
        if (!mounted) return;
        Get.back();
        Get.snackbar(
          'Erro',
          'Falha ao salvar o veículo: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.data != null;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        title: Text(
          isEditing
              ? context.tr(TranslationKeys_5.vehiclesEditVehicle)
              : context.tr(TranslationKeys_5.vehiclesAddNewVehicle),
        ),
        actions: [
          IconButton(
            icon: isEditing
                ? Icon(RemixIcons.edit_line)
                : Icon(RemixIcons.save_line),
            onPressed: _save,
            tooltip: isEditing
                ? context.tr(TranslationKeys_5.vehiclesEditVehicle)
                : context.tr(TranslationKeys_5.vehiclesSave),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryFuelColor.withOpacity(0.2),
                  backgroundImage: _selectedImageUrl != null
                      ? FileImage(File(_selectedImageUrl!))
                      : null,
                  child: _selectedImageUrl == null
                      ? Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: AppTheme.primaryFuelColor,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder(
                valueListenable: _plateController,
                builder: (context, value, child) {
                  return VehiclePlateWidget(
                    plate: _plateController.text.isEmpty
                        ? "ABC1D23"
                        : _plateController.text,
                    isMercosul: _isMercosul,
                    city: _cityController.text,
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _nicknameController,
                      "Apelido (Ex: City)",
                      RemixIcons.medal_line,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      _plateController,
                      "Placa",
                      RemixIcons.barcode_box_line,
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text("Padrão Mercosul"),
                value: _isMercosul,
                onChanged: (val) => setState(() => _isMercosul = val),
                secondary: const Icon(Icons.flag_outlined),
              ),

              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _makeController,
                      "Marca",
                      RemixIcons.building_line,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      _modelController,
                      "Modelo",
                      RemixIcons.car_line,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _tankCapacityController,
                      "Tanque (L)",
                      RemixIcons.drop_line,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      _odometerController,
                      "KM Inicial",
                      RemixIcons.speed_up_line,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _cityController,
                "Cidade/País na Placa",
                RemixIcons.map_pin_user_line,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _yearController,
                "Ano",
                RemixIcons.calendar_line,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryFuelColor,
                  ),
                  child: const Text(
                    "SALVAR VEÍCULO",
                    style: TextStyle(
                      color: Colors.white,
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => value!.isEmpty ? "Obrigatório" : null,
      onChanged: (val) => setState(() {}),
    );
  }
}
