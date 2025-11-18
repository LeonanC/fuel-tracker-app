import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/models/gas_station_model.dart';
import 'package:fuel_tracker_app/provider/currency_provider.dart';
import 'package:fuel_tracker_app/provider/gas_station_provider.dart';
import 'package:fuel_tracker_app/provider/language_provider.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:geolocator/geolocator.dart';

class GasStationEntryScreen extends StatefulWidget {
  final GasStationModel? station;
  const GasStationEntryScreen({super.key, this.station});

  @override
  State<GasStationEntryScreen> createState() => _GasStationEntryScreenState();
}

class _GasStationEntryScreenState extends State<GasStationEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _brandController;
  late MoneyMaskedTextController _latitudeController;
  late MoneyMaskedTextController _longitudeController;
  late MoneyMaskedTextController _priceGasolineController;
  late MoneyMaskedTextController _priceEthanolController;
  late bool _hasConvenienceStore;
  late bool _is24Hours;

  bool get _isEditing => widget.station != null;

  @override
  void initState() {
    super.initState();

    const int coordinatePrecision = 7;
    const String coordinateDecimalSeparator = '.';

    if (_isEditing) {
      final station = widget.station!;
      _nameController = TextEditingController(text: station.nome);
      _addressController = TextEditingController(text: station.address ?? '');
      _brandController = TextEditingController(text: station.brand);
      _latitudeController = MoneyMaskedTextController(
        initialValue: station.latitude,
        decimalSeparator: '.',
        thousandSeparator: '',
        precision: coordinatePrecision,
        leftSymbol: '-',
      );
      _longitudeController = MoneyMaskedTextController(
        initialValue: station.longitude,
        decimalSeparator: '.',
        thousandSeparator: '',
        precision: coordinatePrecision,
        leftSymbol: '-',
      );
      _priceGasolineController = MoneyMaskedTextController(
        initialValue: station.priceGasoline,
        decimalSeparator: ',',
        thousandSeparator: '.',
      );
      _priceEthanolController = MoneyMaskedTextController(
        initialValue: station.priceEthanol,
        decimalSeparator: ',',
        thousandSeparator: '.',
      );
      _hasConvenienceStore = station.hasConvenientStore;
      _is24Hours = station.is24Hours;
    } else {
      _nameController = TextEditingController();
      _addressController = TextEditingController();
      _brandController = TextEditingController();
      _latitudeController = MoneyMaskedTextController(
        decimalSeparator: '.',
        thousandSeparator: '',
        precision: coordinatePrecision,
        leftSymbol: '-',
      );
      _longitudeController = MoneyMaskedTextController(
        decimalSeparator: '.',
        thousandSeparator: '',
        precision: coordinatePrecision,
        leftSymbol: '-',
      );
      _priceGasolineController = MoneyMaskedTextController(
        leftSymbol: 'R\$ ',
        decimalSeparator: ',',
        thousandSeparator: '.',
      );
      _priceEthanolController = MoneyMaskedTextController(
        leftSymbol: 'R\$ ',
        decimalSeparator: ',',
        thousandSeparator: '.',
      );
      _hasConvenienceStore = false;
      _is24Hours = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _brandController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _priceGasolineController.dispose();
    _priceEthanolController.dispose();
    super.dispose();
  }

  void _saveGasStation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final GasStationModel newStation = GasStationModel(
      id: widget.station?.id,
      nome: _nameController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      brand: _brandController.text.trim(),
      latitude: _latitudeController.numberValue,
      longitude: _longitudeController.numberValue,
      priceGasoline: _priceGasolineController.numberValue,
      priceEthanol: _priceEthanolController.numberValue,
      hasConvenientStore: _hasConvenienceStore,
      is24Hours: _is24Hours,
    );

    final provider = GasStationProvider();
    if (_isEditing) {
      await provider.updateGasStation(newStation);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Posto "${newStation.nome}" atualizado com sucesso!')));
    } else {
      await provider.saveGasStation(newStation);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Posto "${newStation.nome}" adicionado com sucesso!')));
    }
    Navigator.of(context).pop(true);
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Serviços de localização desabilitados.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Permissão de localização negada.')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Permissão negada permanentemente. Por favor, habilite nas configurações do app.',
          ),
        ),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Obtendo sua localização...')));

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String formattedAddress = "Endereço não encontrado.";
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        formattedAddress = [
          placemark.thoroughfare,
          placemark.subThoroughfare,
          placemark.subLocality,
          placemark.locality,
        ].where((element) => element != null && element.isNotEmpty).join(', ');
      }

      setState(() {
        _latitudeController.updateValue(position.latitude);
        _longitudeController.updateValue(position.longitude);
        _addressController.text = formattedAddress;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Localização atualizada com sucesso!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Não foi possível obter a localização: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final currencySymbol = context.watch<CurrencyProvider>().currencySymbol;
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: isDarkMode
                ? AppTheme.backgroundColorDark
                : AppTheme.backgroundColorLight,
            appBar: AppBar(
              backgroundColor: isDarkMode
                  ? AppTheme.backgroundColorDark
                  : AppTheme.backgroundColorLight,
              title: Text(
                context.tr(
                  _isEditing
                      ? TranslationKeys.gasStationUpdateTitle
                      : TranslationKeys.gasStationAddTitle,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: context.tr(TranslationKeys.gasStationLabelName),
                        hintText: 'Ex: Posto Amarelo',
                      ),
                      validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: context.tr(TranslationKeys.gasStationLabelAddress),
                        hintText: 'Ex: Av. Principal, 123',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.tr(TranslationKeys.gasStationRequiredFieldName);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _brandController,
                      decoration: InputDecoration(
                        labelText: context.tr(TranslationKeys.gasStationLabelBrand),
                        hintText: 'Ex: Ipiranga, Shell',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.tr(TranslationKeys.gasStationRequiredFieldBrand);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latitudeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: context.tr(TranslationKeys.gasStationLabelLatitude),
                              hintText: '-23.56789',
                              suffixIcon: IconButton(
                                icon: const Icon(RemixIcons.user_location_line, size: 20),
                                color: Theme.of(context).colorScheme.primary,
                                onPressed: _getCurrentLocation,
                              ),
                            ),
                            validator: (value) {
                              if (_latitudeController.numberValue == 0.0) {
                                return context.tr(TranslationKeys.gasStationRequiredValidLatitude);
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _longitudeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: context.tr(TranslationKeys.gasStationLabelLongitude),
                              hintText: '-46.12345',
                            ),
                            validator: (value) {
                              if (_longitudeController.numberValue == 0.0) {
                                return context.tr(TranslationKeys.gasStationRequiredValidLongitude);
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceGasolineController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText:
                                  '${context.tr(TranslationKeys.gasStationLabelPriceGasoline)} ($currencySymbol)',
                              hintText: '5,99',
                            ),
                            validator: (value) {
                              if (_priceGasolineController.numberValue <= 0) {
                                return context.tr(TranslationKeys.gasStationRequiredValidPrice);
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _priceEthanolController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText:
                                  '${context.tr(TranslationKeys.gasStationLabelPriceEthanol)} ($currencySymbol)',
                              hintText: '3,99',
                            ),
                            validator: (value) {
                              if (_priceEthanolController.numberValue <= 0) {
                                return context.tr(TranslationKeys.gasStationRequiredValidPrice);
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSwitchTile(
                      icon: RemixIcons.store_2_fill,
                      label: context.tr(TranslationKeys.gasStationLabelConvenienceStore),
                      value: _hasConvenienceStore,
                      onChanged: (newValue) {
                        setState(() {
                          _hasConvenienceStore = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildSwitchTile(
                      icon: RemixIcons.time_fill,
                      label: context.tr(TranslationKeys.gasStationLabel24Hours),
                      value: _is24Hours,
                      onChanged: (newValue) {
                        setState(() {
                          _is24Hours = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveGasStation,
                      child: Text(
                        _isEditing
                            ? context.tr(TranslationKeys.gasStationButtonUpdate)
                            : context.tr(TranslationKeys.gasStationButtonSave),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: value ? Theme.of(context).colorScheme.primary : AppTheme.primaryFuelColor,
              size: 28,
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: value
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}
