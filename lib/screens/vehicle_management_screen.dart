import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/models/vehicle_model.dart';
import 'package:fuel_tracker_app/provider/vehicle_provider.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class VehicleManagementScreen extends StatefulWidget {
  const VehicleManagementScreen({super.key});

  @override
  State<VehicleManagementScreen> createState() => _VehicleManagementScreenState();
}

class _VehicleManagementScreenState extends State<VehicleManagementScreen> {
  @override
  Widget build(BuildContext context) {
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
      body: Consumer<VehicleProvider>(
        builder: (context, provider, child) {
          if (provider.vehicles.isEmpty) {
            return Center(
              child: Text('Nenhum veículo cadastrado.', style: theme.textTheme.bodyLarge),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: provider.vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = provider.vehicles[index];
              return VehicleCard(vehicle: vehicle);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showVehicleForm(context),
        backgroundColor: AppTheme.primaryFuelColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

void _showVehicleForm(BuildContext context, [Vehicle? vehicle]) {
  showDialog(
    context: context,
    builder: (_) => VehicleForm(vehicle: vehicle),
  );
}

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  const VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<VehicleProvider>(context, listen: false);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
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
              _confirmDelete(context, provider, vehicle);
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

  void _confirmDelete(BuildContext context, VehicleProvider provider, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.tr(TranslationKeys.vehiclesDelete)),
          content: Text(context.tr(TranslationKeys.vehiclesDeleteConfirm)),
          actions: [
            TextButton(
              child: Text(context.tr(TranslationKeys.vehiclesCancel)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryFuelColor,
                foregroundColor: AppTheme.primaryFuelAccent,
              ),
              child: Text(context.tr(TranslationKeys.vehiclesDelete)),
              onPressed: () {
                provider.deleteVehicle(vehicle.id);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class VehicleForm extends StatefulWidget {
  final Vehicle? vehicle;
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

  @override
  void initState() {
    super.initState();
    final vehicle = widget.vehicle;
    _nickname = vehicle?.nickname ?? '';
    _make = vehicle?.make ?? '';
    _model = vehicle?.model ?? '';
    _fuelType = vehicle?.fuelType ?? 'Flex';
    _year = vehicle?.year ?? DateTime.now().year;
    _initialOdometer = vehicle?.initialOdometer ?? 0.0;
    _imageUrl = vehicle?.imageUrl;
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 100);

    if(pickedFile != null){
      setState(() {
        _imageUrl = pickedFile.path;
      });
    }

    if(Navigator.of(context).canPop()){
      Navigator.of(context).pop();
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context){
        return SafeArea(
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
            ],
          ),
        );
      }
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newVehicle = Vehicle(
        id: widget.vehicle?.id ?? const Uuid().v4(),
        nickname: _nickname,
        make: _make,
        model: _model,
        fuelType: _fuelType,
        year: _year,
        initialOdometer: _initialOdometer,
        imageUrl: _imageUrl,
      );

      Provider.of<VehicleProvider>(context, listen: false).saveVehicle(newVehicle);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vehicle != null;
    return AlertDialog(
      title: Text(
        context.tr(
          isEditing ? TranslationKeys.vehiclesEditVehicle : TranslationKeys.vehiclesAddNewVehicle,
        ),
      ),
      content: SingleChildScrollView(
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
                ),
                onSaved: (value) => _nickname = value ?? '',
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _make,
                decoration: InputDecoration(labelText: context.tr(TranslationKeys.vehiclesMake)),
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
                decoration: InputDecoration(labelText: context.tr(TranslationKeys.vehiclesYear)),
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
                ),
                items: ['Flex', 'Gasolina', 'Etanol', 'Diesel'].map((String value) {
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr(TranslationKeys.vehiclesCancel)),
        ),
        ElevatedButton(onPressed: _submit, child: Text(context.tr(TranslationKeys.vehiclesSave))),
      ],
    );
  }
}
