import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuel_tracker_app/controllers/unit_controller.dart';
import 'package:fuel_tracker_app/models/maintenance_entry_model.dart';
import 'package:fuel_tracker_app/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/controllers/language_controller.dart';
import 'package:fuel_tracker_app/controllers/maintenance_controller.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class MaintenanceEntryScreen extends StatefulWidget {
  final double? lastOdometer;
  final MaintenanceEntry? entry;
  const MaintenanceEntryScreen({super.key, this.lastOdometer, this.entry});

  @override
  State<MaintenanceEntryScreen> createState() => _MaintenanceEntryScreenState();
}

class _MaintenanceEntryScreenState extends State<MaintenanceEntryScreen> {
  
  final MaintenanceController maintenanceController = Get.find<MaintenanceController>();
  final UnitController unitController = Get.find<UnitController>();
  final LanguageController languageController = Get.find<LanguageController>();

  final _formKey = GlobalKey<FormState>();
  late String _tipoServico;
  late DateTime _dataServico;
  late TextEditingController _kmController;
  late TextEditingController _custoController;
  late TextEditingController _observacoesController;

  bool _lembreteAtivo = false;
  late TextEditingController _lembreteKmController;
  DateTime? _lembreteData;

  late Map<String, String> _serviceTypes;
  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    _initializeServiceTypes();

    if (_isEditing) {
      final entry = widget.entry!;
      _tipoServico = entry.tipo;
      _dataServico = entry.dataServico;
      _kmController = TextEditingController(text: entry.quilometragem.toStringAsFixed(0));
      _custoController = TextEditingController(
        text: entry.custo != null ? entry.custo!.toStringAsFixed(2) : '',
      );
      _observacoesController = TextEditingController(text: entry.observacoes ?? '');
      _lembreteAtivo = entry.lembreteAtivo;
      _lembreteKmController = TextEditingController(
        text: entry.lembreteKm != null ? entry.lembreteKm!.toStringAsFixed(0) : '',
      );
      _lembreteData = entry.lembreteData;
    } else {
      _tipoServico = _serviceTypes.keys.first;
      _dataServico = DateTime.now();
      _kmController = widget.lastOdometer != null
          ? TextEditingController(text: widget.lastOdometer!.toStringAsFixed(0))
          : TextEditingController(text: '');
      _custoController = TextEditingController();
      _observacoesController = TextEditingController();
      _lembreteKmController = TextEditingController();
      _lembreteData = null;
    }
  }

  void _initializeServiceTypes() {
    _serviceTypes = {
      maintenanceController.tr(TranslationKeys.maintenanceServiceOilChange): 'OIL',
      maintenanceController.tr(TranslationKeys.maintenanceServiceTireRotation): 'TIRE',
      maintenanceController.tr(TranslationKeys.maintenanceServiceBrakePads): 'BRAKE',
      maintenanceController.tr(TranslationKeys.maintenanceServiceGeneralInspect): 'INSPECT',
    };
    if (_isEditing && !_serviceTypes.containsKey(widget.entry!.tipo)) {
      _serviceTypes[widget.entry!.tipo] = 'OTHER';
    }
  }

  Future<void> _showAddServiceDialog() async {
    final TextEditingController newServiceController = TextEditingController();
    final String? newServiceName = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(maintenanceController.tr(TranslationKeys.maintenanceServiceAddNew)),
          content: TextField(
            controller: newServiceController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: maintenanceController.tr(TranslationKeys.maintenanceDialogAddServiceLabel),
              hintText: maintenanceController.tr(TranslationKeys.maintenanceDialogAddServiceHint),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: Text(maintenanceController.tr(TranslationKeys.maintenanceDialogButtonCancel)),
            ),
            ElevatedButton(
              onPressed: () {
                final String name = newServiceController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(dialogContext).pop(name);
                }
              },
              child: Text(maintenanceController.tr(TranslationKeys.maintenanceDialogButtonAdd)),
            ),
          ],
        );
      },
    );

    if (newServiceName != null) {
      final String newServiceCode = 'CUSTOM_${DateTime.now().millisecondsSinceEpoch}';
      setState(() {
        _serviceTypes[newServiceName] = newServiceCode;
        _tipoServico = newServiceName;
      });
    }
  }

  @override
  void dispose() {
    _kmController.dispose();
    _custoController.dispose();
    _observacoesController.dispose();
    _lembreteKmController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isServiceDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isServiceDate
          ? _dataServico
          : (_lembreteData ?? DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isServiceDate) {
          _dataServico = picked;
        } else {
          _lembreteData = picked;
        }
      });
    }
  }

  Widget _buildNumericField(
    TextEditingController controller,
    String label,
    String suffix, {
    double? initialValue,
    bool isDecimal = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
      keyboardType: isDecimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+[,.]?\d{0,2}'))],
      validator: (value) {
        if (label.contains(maintenanceController.tr(TranslationKeys.commonLabelsOdometer)) &&
            (value == null || value.isEmpty)) {
          return 'context.tr(TranslationKeys.formValidationRequired)';
        }
        return null;
      },
    );
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    final double km = double.tryParse(_kmController.text.replaceAll(',', '.')) ?? 0.0;
    final double custo = double.tryParse(_custoController.text.replaceAll(',', '.')) ?? 0.0;
    final double? lembreteKm = (_lembreteAtivo && _lembreteKmController.text.isNotEmpty)
        ? double.tryParse(_lembreteKmController.text.replaceAll(',', '.'))
        : null;

    final MaintenanceEntry newEntry = MaintenanceEntry(
      id: widget.entry?.id,
      tipo: _tipoServico,
      dataServico: _dataServico,
      quilometragem: km,
      custo: custo > 0 ? custo : null,
      observacoes: _observacoesController.text.trim().isEmpty
          ? null
          : _observacoesController.text.trim(),
      lembreteAtivo: _lembreteAtivo,
      lembreteKm: lembreteKm,
      lembreteData: _lembreteAtivo ? _lembreteData : null,
      veiculoId: 1,
    );

    if (_isEditing) {
      // context.read<MaintenanceProvider>().updateEntry(newEntry);
    }

    Navigator.of(context).pop(newEntry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencySymbol = unitController.currencyUnit.value;
    final String _addNewServiceKey = maintenanceController.tr(TranslationKeys.maintenanceServiceAddNew);
    return Obx(() {
        return Directionality(
          textDirection: languageController.textDirection,
          child: Scaffold(
            backgroundColor: theme.brightness == Brightness.dark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
            appBar: AppBar(
              backgroundColor: theme.brightness == Brightness.dark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
              key: ValueKey('MaintenanceEntryAppBar_${_isEditing ? 'Edit' : 'New'}'),
              title: Text(
                _isEditing
                    ? maintenanceController.tr(TranslationKeys.maintenanceScreenTitle)
                    : maintenanceController.tr(TranslationKeys.maintenanceScreenTitle),
              ),
              actions: [
                IconButton(
                  icon: const Icon(RemixIcons.save_line),
                  onPressed: _saveForm,
                  tooltip: maintenanceController.tr(TranslationKeys.maintenanceFormSaveButton),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _tipoServico,
                      items: [
                        ..._serviceTypes.keys.map((String key) {
                          return DropdownMenuItem<String>(value: key, child: Text(key));
                        }).toList(),

                        const DropdownMenuItem<String>(
                          value: 'SEPARATOR',
                          enabled: false,
                          child: Divider(),
                        ),

                        DropdownMenuItem<String>(
                          value: _addNewServiceKey,
                          child: Row(
                            children: [
                              Icon(
                                RemixIcons.add_circle_line,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _addNewServiceKey,
                                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          if (newValue == _addNewServiceKey) {
                            _showAddServiceDialog();
                          } else if (newValue != 'SEPARATOR') {
                            setState(() {
                              _tipoServico = newValue;
                            });
                          }
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty || value == _addNewServiceKey) {
                          return maintenanceController.tr(TranslationKeys.validationRequiredServiceType);
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        RemixIcons.calendar_line,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(maintenanceController.tr(TranslationKeys.commonLabelsDate)),
                      trailing: TextButton(
                        onPressed: () => _selectDate(context, true),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_dataServico),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                    const Divider(),
                    _buildNumericField(
                      _kmController,
                      maintenanceController.tr(TranslationKeys.commonLabelsOdometer),
                      'km',
                    ),
                    const SizedBox(height: 16),
                    _buildNumericField(
                      _custoController,
                      maintenanceController.tr(TranslationKeys.maintenanceFormCost),
                      '$currencySymbol',
                      isDecimal: true,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _observacoesController,
                      decoration: InputDecoration(
                        labelText: maintenanceController.tr(TranslationKeys.maintenanceFormNotes),
                        border: const OutlineInputBorder(),
                      ),
                      maxLength: 100,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      maintenanceController.tr(TranslationKeys.maintenanceFormReminderSection),
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    CheckboxListTile(
                      title: Text(maintenanceController.tr(TranslationKeys.maintenanceFormEnableReminder)),
                      value: _lembreteAtivo,
                      onChanged: (bool? value) {
                        setState(() {
                          _lembreteAtivo = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_lembreteAtivo) ...[
                      const SizedBox(height: 8),
                      _buildNumericField(
                        _lembreteKmController,
                        maintenanceController.tr(TranslationKeys.maintenanceFormReminderKm),
                        'km',
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          RemixIcons.calendar_check_line,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        title: Text(maintenanceController.tr(TranslationKeys.maintenanceFormReminderDate)),
                        trailing: TextButton(
                          onPressed: () => _selectDate(context, false),
                          child: Text(
                            _lembreteData != null
                                ? DateFormat('dd/MM/yyyy').format(_lembreteData!)
                                : maintenanceController.tr(TranslationKeys.commonLabelsSelect),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                      const Divider(),
                    ],
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
