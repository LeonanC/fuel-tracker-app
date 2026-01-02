import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuel_tracker_app/controllers/service_controller.dart';
import 'package:fuel_tracker_app/controllers/unit_controller.dart';
import 'package:fuel_tracker_app/models/maintenance_entry_model.dart';
import 'package:fuel_tracker_app/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/controllers/language_controller.dart';
import 'package:fuel_tracker_app/controllers/maintenance_controller.dart';
import 'package:fuel_tracker_app/models/services_type_model.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:uuid/uuid.dart';

class MaintenanceEntryScreen extends StatefulWidget {
  final double? lastOdometer;
  final MaintenanceEntry? entry;
  const MaintenanceEntryScreen({super.key, this.lastOdometer, this.entry});

  @override
  State<MaintenanceEntryScreen> createState() => _MaintenanceEntryScreenState();
}

class _MaintenanceEntryScreenState extends State<MaintenanceEntryScreen> {
  final ServiceController serviceController = Get.find<ServiceController>();
  final MaintenanceController controller = Get.find<MaintenanceController>();
  final UnitController unitController = Get.find<UnitController>();
  final LanguageController languageController = Get.find<LanguageController>();

  final _formKey = GlobalKey<FormState>();
  ServicesTypeModel? selectedService;

  late DateTime _dataServico;
  late TextEditingController _kmController;
  late TextEditingController _custoController;
  late TextEditingController _observacoesController;

  bool _lembreteAtivo = false;
  late TextEditingController _lembreteKmController;
  DateTime? _lembreteData;

  late List<ServicesTypeModel> availableServices = [];
  late bool isEditing;

  @override
  void initState() {
    isEditing = widget.entry != null;
    super.initState();

    if (isEditing) {
      final entry = widget.entry!;
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
      _dataServico = DateTime.now();
      _kmController = widget.lastOdometer != null
          ? TextEditingController(text: widget.lastOdometer!.toStringAsFixed(0))
          : TextEditingController(text: '');
      _custoController = TextEditingController();
      _observacoesController = TextEditingController();
      _lembreteKmController = TextEditingController();
      _lembreteData = null;
    }

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    availableServices = serviceController.serviceType;

    if (isEditing && widget.entry != null) {
      selectedService = availableServices.firstWhereOrNull((s) => s.nome == widget.entry!.tipo);

      serviceController.selectedServiceType = selectedService;

      setState(() {});
    }
  }

  void updateServiceType(ServicesTypeModel? newService) {
    if (newService != null) {
      setState(() {
        selectedService = newService;
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
        if (label.contains(context.tr(TranslationKeys.commonLabelsOdometer)) &&
            (value == null || value.isEmpty)) {
          return 'context.tr(TranslationKeys.formValidationRequired)';
        }
        return null;
      },
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final double km = double.tryParse(_kmController.text.replaceAll(',', '.')) ?? 0.0;
      final double custo = double.tryParse(_custoController.text.replaceAll(',', '.')) ?? 0.0;
      final double? lembreteKm = (_lembreteAtivo && _lembreteKmController.text.isNotEmpty)
          ? double.tryParse(_lembreteKmController.text.replaceAll(',', '.'))
          : null;
      final serviceName = selectedService?.nome;

      final MaintenanceEntry newEntry = MaintenanceEntry(
        tipo: serviceName!,
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

      try {
        await controller.saveMaintenance(newEntry);
        if (!mounted) return;
        Get.back();

        Get.snackbar(
          'Sucesso',
          isEditing
              ? 'Serviço atualizado: ${newEntry.tipo}'
              : 'Serviço adicionado: ${newEntry.tipo}',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        if (!mounted) return;
        Get.back();
        Get.snackbar(
          'Erro',
          'Falha ao salvar o serviço: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entry != null;
    final theme = Theme.of(context);
    final CurrencyController currencyController = Get.find<CurrencyController>();
    final String _addNewServiceKey = context.tr(TranslationKeys.maintenanceServiceAddNew);
    return Obx(() {
      final currencySymbol = currencyController.currencySymbol.value;
      return Directionality(
        textDirection: languageController.textDirection,
        child: Scaffold(
          backgroundColor: theme.brightness == Brightness.dark
              ? AppTheme.backgroundColorDark
              : AppTheme.backgroundColorLight,
          appBar: AppBar(
            backgroundColor: theme.brightness == Brightness.dark
                ? AppTheme.backgroundColorDark
                : AppTheme.backgroundColorLight,
            key: ValueKey('MaintenanceEntryAppBar_${isEditing ? 'Edit' : 'New'}'),
            title: Text(
              isEditing
                  ? context.tr(TranslationKeys.maintenanceScreenTitle)
                  : context.tr(TranslationKeys.maintenanceScreenTitle),
            ),
            actions: [
              IconButton(
                icon: const Icon(RemixIcons.save_line),
                onPressed: _submit,
                tooltip: context.tr(TranslationKeys.maintenanceFormSaveButton),
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
                  DropdownButtonFormField<ServicesTypeModel>(
                    value: selectedService,
                    items: availableServices.map((ServicesTypeModel service) {
                      return DropdownMenuItem<ServicesTypeModel>(
                        value: service,
                        child: Text(service.nome),
                      );
                    }).toList(),
                    onChanged: availableServices.isEmpty ? null : updateServiceType,
                    validator: (value) {
                      if (value == null) {
                        return context.tr(TranslationKeys.validationRequiredServiceType);
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
                    title: Text(context.tr(TranslationKeys.commonLabelsDate)),
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
                    context.tr(TranslationKeys.commonLabelsOdometer),
                    'km',
                  ),
                  const SizedBox(height: 16),
                  _buildNumericField(
                    _custoController,
                    context.tr(TranslationKeys.maintenanceFormCost),
                    currencySymbol,
                    isDecimal: true,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _observacoesController,
                    decoration: InputDecoration(
                      labelText: context.tr(TranslationKeys.maintenanceFormNotes),
                      border: const OutlineInputBorder(),
                    ),
                    maxLength: 100,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    context.tr(TranslationKeys.maintenanceFormReminderSection),
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  CheckboxListTile(
                    title: Text(context.tr(TranslationKeys.maintenanceFormEnableReminder)),
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
                      context.tr(TranslationKeys.maintenanceFormReminderKm),
                      'km',
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        RemixIcons.calendar_check_line,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      title: Text(context.tr(TranslationKeys.maintenanceFormReminderDate)),
                      trailing: TextButton(
                        onPressed: () => _selectDate(context, false),
                        child: Text(
                          _lembreteData != null
                              ? DateFormat('dd/MM/yyyy').format(_lembreteData!)
                              : context.tr(TranslationKeys.commonLabelsSelect),
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
    });
  }
}
