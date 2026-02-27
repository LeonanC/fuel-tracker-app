import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/data/models/gas_station_model.dart';
import 'package:fuel_tracker_app/core/app_theme.dart';
import 'package:fuel_tracker_app/core/app_localizations.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class GasEntryScreen extends StatefulWidget {
  final GasStationModel? data;
  const GasEntryScreen({super.key, this.data});

  @override
  State<GasEntryScreen> createState() => _GasEntryScreenState();
}

class _GasEntryScreenState extends State<GasEntryScreen> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController brandController;
  late MoneyMaskedTextController latitudeController;
  late MoneyMaskedTextController longitudeController;
  late MoneyMaskedTextController priceGasolineController;
  late MoneyMaskedTextController priceEthanolController;

  bool hasConvenienceStore = false;
  bool is24Hours = false;
  bool isLocationLoading = false;

  bool get isEditing => widget.data != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    const int coordPrecision = 7;
    final d = widget.data;

    if (isEditing) {
      nameController = TextEditingController(text: d?.nome ?? '');
      addressController = TextEditingController(text: d?.address ?? '');
      brandController = TextEditingController(text: d?.brand ?? '');

      latitudeController = MoneyMaskedTextController(
        initialValue: d?.latitude ?? 0.0,
        decimalSeparator: '.',
        thousandSeparator: '',
        precision: coordPrecision,
        leftSymbol: '-',
      );
      longitudeController = MoneyMaskedTextController(
        initialValue: d?.longitude ?? 0.0,
        decimalSeparator: '.',
        thousandSeparator: '',
        precision: coordPrecision,
        leftSymbol: '-',
      );
      hasConvenienceStore = d?.hasConvenientStore ?? false;
      is24Hours = d?.is24Hours ?? false;
    } else {
      nameController = TextEditingController();
      addressController = TextEditingController();
      brandController = TextEditingController();
      latitudeController = MoneyMaskedTextController(
        decimalSeparator: '.',
        thousandSeparator: '',
        precision: coordPrecision,
        leftSymbol: '-',
      );
      longitudeController = MoneyMaskedTextController(
        decimalSeparator: '.',
        thousandSeparator: '',
        precision: coordPrecision,
        leftSymbol: '-',
      );
      priceGasolineController = MoneyMaskedTextController(
        leftSymbol: 'R\$ ',
        decimalSeparator: ',',
        thousandSeparator: '.',
      );
      priceEthanolController = MoneyMaskedTextController(
        leftSymbol: 'R\$ ',
        decimalSeparator: ',',
        thousandSeparator: '.',
      );
      hasConvenienceStore = false;
      is24Hours = false;
    }
  }

  Future<void> getCurrentLocation() async {
    setState(() => isLocationLoading = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Permissão negada';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        addressController.text =
            '${p.thoroughfare}, ${p.subThoroughfare} - ${p.subLocality}';
      }

      latitudeController.updateValue(position.latitude);
      longitudeController.updateValue(position.longitude);

      Get.snackbar(
        'Sucesso',
        'Localização obtida!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        e.toString(),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isLocationLoading = false);
    }
  }

  void _submit() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      final GasStationModel newStation = GasStationModel(
        id: widget.data?.id,
        nome: nameController.text.trim(),
        address: addressController.text.trim(),
        brand: brandController.text.trim(),
        latitude: latitudeController.numberValue,
        longitude: longitudeController.numberValue,
        price: priceGasolineController.numberValue,
        hasConvenientStore: hasConvenienceStore,
        is24Hours: is24Hours,
      );

      try {
        // controller.saveStation(newStation);
        Get.back();
        Get.snackbar(
          'Sucesso',
          'Posto "${newStation.nome}" adicionado com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.back();
        Get.snackbar(
          'Erro',
          'Posto "${newStation.nome}" adicionado com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
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
      backgroundColor: isDarkMode
          ? AppTheme.backgroundColorDark
          : AppTheme.backgroundColorLight,
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? AppTheme.backgroundColorDark
            : AppTheme.backgroundColorLight,
        title: Text(
          isEditing
              ? context.tr(TranslationKeys.gasStationUpdateTitle)
              : context.tr(TranslationKeys.gasStationAddTitle),
        ),
        centerTitle: theme.appBarTheme.centerTitle,
        elevation: theme.appBarTheme.elevation,
        actions: [
          IconButton(
            icon: isLocationLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(),
                  )
                : Icon(Icons.location_on, size: 20),
            onPressed: isLocationLoading ? null : () => getCurrentLocation(),
          ),
          IconButton(
            icon: isEditing
                ? Icon(RemixIcons.edit_line)
                : Icon(RemixIcons.save_line),
            onPressed: _submit,
            tooltip: isEditing
                ? context.tr(TranslationKeys.gasStationUpdateTitle)
                : context.tr(TranslationKeys.gasStationAddTitle),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              _buildInput(
                nameController,
                "Nome do Posto",
                RemixIcons.gas_station_line,
              ),
              const SizedBox(height: 16),
              _buildInput(
                brandController,
                "Bandeira (Ex: Shell)",
                RemixIcons.flag_line,
              ),
              const SizedBox(height: 16),
              _buildInput(
                addressController,
                'Endereço Completo',
                RemixIcons.map_pin_line,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInput(
                      priceGasolineController,
                      'Gasolina',
                      RemixIcons.drop_line,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInput(
                      priceEthanolController,
                      'Etanol',
                      RemixIcons.leaf_line,
                    ),
                  ),
                ],
              ),
              const Divider(height: 40),
              _buildSwitch(
                RemixIcons.store_2_line,
                "Loja de Conveniência",
                hasConvenienceStore,
                (v) => setState(() => hasConvenienceStore = v),
              ),
              _buildSwitch(
                RemixIcons.time_line,
                "Aberto 24 Horas",
                is24Hours,
                (v) => setState(() => is24Hours = v),
              ),

              const SizedBox(height: 20),

              ExpansionTile(
                title: const Text(
                  "Coordenadas Geográficas",
                  style: TextStyle(fontSize: 14),
                ),
                leading: const Icon(RemixIcons.earth_line),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInput(
                          latitudeController,
                          "Latitude",
                          Icons.explore_outlined,
                          isNumeric: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInput(
                          longitudeController,
                          "Longitude",
                          Icons.explore_outlined,
                          isNumeric: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch(
    IconData icon,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon, color: value ? AppTheme.primaryFuelColor : null),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryFuelColor,
    );
  }

  Widget _buildInput(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isNumeric = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => value!.isEmpty ? "Obrigatório" : null,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    brandController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    priceGasolineController.dispose();
    priceEthanolController.dispose();
    super.dispose();
  }
}
