import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/provider/currency_provider.dart';
import 'package:fuel_tracker_app/provider/fuel_entry_provider.dart';
import 'package:fuel_tracker_app/provider/language_provider.dart';
import 'package:fuel_tracker_app/services/application.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

class FuelEntryScreen extends StatefulWidget {
  final double? lastOdometer;
  final FuelEntry? entry;
  const FuelEntryScreen({super.key, this.lastOdometer, this.entry});

  @override
  State<FuelEntryScreen> createState() => _FuelAddEntryScreenState();
}

class _FuelAddEntryScreenState extends State<FuelEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _tipoFuel;
  late String _nomePosto;
  late DateTime _selectedDate;
  late TextEditingController _kmController;
  late MoneyMaskedTextController _litrosController;
  late MoneyMaskedTextController _pricePerLiterController;
  late MoneyMaskedTextController _totalPriceController;
  

  bool _tanqueCheio = true;
  String? _comprovantePath;
  final ImagePicker _picker = ImagePicker();

  late Map<String, String> _serviceCombustivel;
  late Map<String, String> _postoCombustivel;
  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    _initializeServiceCombustivel();
    _initializePostoCombustivel();

    if (_isEditing) {
      final entry = widget.entry!;
      _tipoFuel = entry.tipo;
      _nomePosto = entry.posto;
      _selectedDate = entry.dataAbastecimento;
      _kmController = TextEditingController(text: entry.quilometragem.toStringAsFixed(0));
      _litrosController = MoneyMaskedTextController(
        initialValue: entry.litros,
        decimalSeparator: ',',
        thousandSeparator: '.',
      );
      _pricePerLiterController = MoneyMaskedTextController(
        initialValue: entry.pricePerLiter!,
        decimalSeparator: ',',
        thousandSeparator: '.',
      );
      _totalPriceController = MoneyMaskedTextController(
        initialValue: entry.totalPrice!,
        decimalSeparator: ',',
        thousandSeparator: '.',
      );
      
      _tanqueCheio = entry.tanqueCheio;
      _comprovantePath = entry.comprovantePath ?? '';
    } else {
      _tipoFuel = _serviceCombustivel.keys.first;
      _nomePosto = _postoCombustivel.keys.first;
      _selectedDate = DateTime.now();
      _kmController = widget.lastOdometer != null
          ? TextEditingController(text: widget.lastOdometer!.toStringAsFixed(0))
          : TextEditingController(text: '');
      _litrosController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
      _pricePerLiterController = MoneyMaskedTextController(
        decimalSeparator: ',',
        thousandSeparator: '.',
      );
      _totalPriceController = MoneyMaskedTextController(
        decimalSeparator: ',',
        thousandSeparator: '.',
      );
    }
  }

  void _initializeServiceCombustivel() {
    _serviceCombustivel = {
      context.tr(TranslationKeys.fuelTypeGasolineComum): 'Gasolina Comum',
      context.tr(TranslationKeys.fuelTypeGasolineAditivada): 'Gasolina Aditivada',
      context.tr(TranslationKeys.fuelTypeEthanolAlcool): 'Etanol (Álcool)',
      context.tr(TranslationKeys.fuelTypeGasolinePremium): 'Gasoline Premium',
    };
    if (_isEditing && !_serviceCombustivel.containsKey(widget.entry!.tipo)) {
      _serviceCombustivel[widget.entry!.tipo] = 'OTHER';
    }
  }

  void _initializePostoCombustivel() {
    _postoCombustivel = {
      context.tr(TranslationKeys.postoTypePosto66): 'Posto 66 - Ipiranga',
      context.tr(TranslationKeys.postoTypePostoIA): 'Posto Itaipuaçu AmPm',
      context.tr(TranslationKeys.postoTypePostoBR): 'Posto Bragas (BR)',
      context.tr(TranslationKeys.postoTypePostoPE): 'Posto Petrobras',
      context.tr(TranslationKeys.postoTypePostoAX): 'Posto Amrx',
      context.tr(TranslationKeys.postoTypePostoAL): 'Posto Ale',
      context.tr(TranslationKeys.postoTypePostoGNV): 'Auto Gas GNV',
      context.tr(TranslationKeys.postoTypePostoGA): 'Posto Gasolina',
    };
    if(_isEditing && !_postoCombustivel.containsKey(widget.entry!.posto)){
      _postoCombustivel[widget.entry!.posto] = 'OTHER';
    }
  }

  @override
  void dispose() {
    _kmController.dispose();
    _litrosController.dispose();
    _pricePerLiterController.dispose();
    _totalPriceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023, 1),
      lastDate: DateTime(2030, 12),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  double? _getOdometerValue() => double.tryParse(_kmController.text.replaceAll(',', '.'));
  double? _getLitersValue() => _litrosController.numberValue;
  double? _getPricePerLiterValue() => _pricePerLiterController.numberValue;
  double? _getTotalPriceValue() => _totalPriceController.numberValue;

  void _calculatePrice() {
    final double? liters = _getLitersValue();
    final double? pricePerLiter = _getPricePerLiterValue();
    final double? totalPriceEntered = _getTotalPriceValue();

    if (liters != null && pricePerLiter != null) {
      final double calculatedTotal = liters * pricePerLiter;
      _totalPriceController.updateValue(calculatedTotal);
    } else if (liters != null && totalPriceEntered != null && liters > 0) {
      final calculatedPricePerLiter = totalPriceEntered / liters;
      _pricePerLiterController.updateValue(calculatedPricePerLiter);
    } else if (pricePerLiter != null && totalPriceEntered != null && pricePerLiter > 0) {
      final calculatedLiters = totalPriceEntered / pricePerLiter;
      _litrosController.updateValue(calculatedLiters);
    }
  }

  Future<void> _pickComprovante() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(context.tr(TranslationKeys.entryScreenDialogReceiptTitle)),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: Text(context.tr(TranslationKeys.entryScreenDialogReceiptOptionCamera)),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: Text(context.tr(TranslationKeys.entryScreenDialogReceiptOptionGallery)),
            ),
          ],
        );
      },
    );

    if (source != null) {
      try {
        final XFile? pickedFile = await _picker.pickImage(source: source);
        if (pickedFile != null) {
          setState(() {
            _comprovantePath = pickedFile.path;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.tr(
                    TranslationKeys.entryScreenSnackbarReceiptSelectedPrefix,
                    parameters: {'name': pickedFile.name},
                  ),
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.tr(
                  TranslationKeys.entryScreenSnackbarReceiptSelectedPrefix,
                  parameters: {'error': e.toString()},
                ),
              ),
            ),
          );
        }
      }
    }
  }

  void _saveEntry() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    final FuelEntry newEntry = FuelEntry(
      id: widget.entry?.id,
      tipo: _tipoFuel,
      posto: _nomePosto,
      dataAbastecimento: _selectedDate,
      quilometragem: _getOdometerValue()!,
      litros: _getLitersValue()!,
      pricePerLiter: _getPricePerLiterValue()!,
      totalPrice: _getTotalPriceValue()!,
      comprovantePath: _comprovantePath,
      
      tanqueCheio: _tanqueCheio,
    );
    if (_isEditing) {
      context.read<FuelEntryProvider>().updateEntry(newEntry);
    }
    Navigator.of(context).pop(newEntry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String fullVersionText = '';
    if (widget.lastOdometer != null) {
      final versionLabel1 = context.tr(TranslationKeys.entryScreenInfoLastOdometerPrefix);
      final versionLabel2 = context.tr(TranslationKeys.entryScreenInfoLastOdometerPrefix2);
      fullVersionText =
          '$versionLabel1 ${widget.lastOdometer!.toStringAsFixed(0)} km. $versionLabel2';
    }
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            backgroundColor: theme.brightness == Brightness.dark
                ? AppTheme.backgroundColorDark
                : AppTheme.backgroundColorLight,
            appBar: AppBar(
              title: Text(
                _isEditing
                    ? context.tr(TranslationKeys.entryScreenUpdateAppBarTitle)
                    : context.tr(TranslationKeys.entryScreenAddAppBarTitle),
              ),
              backgroundColor: theme.brightness == Brightness.dark
                  ? AppTheme.backgroundColorDark
                  : AppTheme.backgroundColorLight,
              centerTitle: false,
              elevation: 0,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.access_time,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        context.tr(TranslationKeys.entryScreenLabelDate),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.edit_calendar, color: Theme.of(context).colorScheme.secondary),
                        ],
                      ),
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 20),
                    if (widget.lastOdometer != null)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                fullVersionText,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _kmController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.tr(TranslationKeys.entryScreenLabelOdometer),
                      ),
                      validator: (value) {
                        final double? odometer = _getOdometerValue();
                        if (odometer == null || odometer <= 0) {
                          return context.tr(TranslationKeys.validationRequiredOdometer);
                        }
                        if (widget.lastOdometer != null && odometer < widget.lastOdometer!) {
                          return context.tr(
                            TranslationKeys.validationOdometerMustBeGreater,
                            parameters: {'name': widget.lastOdometer!.toStringAsFixed(0)},
                          );
                        }
                        return null;
                      },
                      onChanged: (_) => _calculatePrice(),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: context.tr(TranslationKeys.entryScreenLabelFuelType),
                        border: OutlineInputBorder(),
                      ),
                      value: _tipoFuel,
                      items: _serviceCombustivel.keys.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(color: AppTheme.textGrey)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _tipoFuel = newValue;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.tr(TranslationKeys.validationRequiredFuelType);
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _litrosController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.tr(TranslationKeys.entryScreenLabelLiters),
                      ),
                      validator: (value) {
                        if (_getLitersValue() == null || _getLitersValue()! <= 0) {
                          return context.tr(TranslationKeys.validationRequiredValidLiters);
                        }
                        return null;
                      },
                      onChanged: (_) => _calculatePrice(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pricePerLiterController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.tr(TranslationKeys.entryScreenLabelPricePerLiter),
                      ),
                      validator: (value) {
                        if (_getPricePerLiterValue() == null || _getPricePerLiterValue()! <= 0) {
                          return context.tr(TranslationKeys.validationRequiredValidPricePerLiter);
                        }
                        return null;
                      },
                      onChanged: (_) => _calculatePrice(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _totalPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.tr(TranslationKeys.entryScreenLabelTotalPrice),
                      ),
                      validator: (value) {
                        if (_getTotalPriceValue() == null || _getTotalPriceValue()! <= 0) {
                          return context.tr(TranslationKeys.validationRequiredValidTotalPrice);
                        }
                        return null;
                      },
                      onChanged: (_) => _calculatePrice(),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: context.tr(TranslationKeys.entryScreenLabelGasStation),
                        border: OutlineInputBorder(),
                      ),
                      value: _nomePosto,
                      items: _postoCombustivel.keys.map((String value){
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(color: AppTheme.textGrey)),
                        );
                      }).toList(),
                      onChanged: (String? newValue){
                        if(newValue != null){
                          setState(() {
                            _nomePosto = newValue;
                          });
                        }
                      },
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return context.tr(TranslationKeys.validationRequiredFuelType);
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _tanqueCheio
                                  ? RemixIcons.gas_station_fill
                                  : RemixIcons.gas_station_line,
                              color: _tanqueCheio
                                  ? Theme.of(context).colorScheme.primary
                                  : AppTheme.textGrey,
                              size: 40,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              context.tr(TranslationKeys.entryScreenLabelFullTank),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _tanqueCheio
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Switch(
                          value: _tanqueCheio,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _tanqueCheio = newValue ?? false;
                            });
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      title: Text(
                        _comprovantePath == null
                            ? context.tr(TranslationKeys.entryScreenReceiptAddOptional)
                            : context.tr(TranslationKeys.entryScreenReceiptSelected),
                        style: TextStyle(
                          color: _comprovantePath == null
                              ? Colors.grey[700]
                              : Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: _comprovantePath != null
                          ? Text(
                              context.tr(
                                TranslationKeys.entryScreenReceiptPathPrefix,
                                parameters: {'name': _comprovantePath!.split('/').last},
                              ),
                            )
                          : null,
                      leading: Icon(
                        _comprovantePath == null ? Icons.camera_alt_outlined : Icons.check_circle,
                        color: _comprovantePath == null
                            ? Colors.grey
                            : Theme.of(context).colorScheme.primary,
                      ),
                      trailing: _comprovantePath != null
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _comprovantePath = null;
                                });
                              },
                            )
                          : null,
                      onTap: _pickComprovante,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveEntry,
                      child: Text(
                        _isEditing
                            ? context.tr(TranslationKeys.entryScreenButtonEdit)
                            : context.tr(TranslationKeys.entryScreenButtonSave),
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
}
