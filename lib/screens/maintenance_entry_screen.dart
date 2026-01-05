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
  final CurrencyController currencyController = Get.find<CurrencyController>();

  final _formKey = GlobalKey<FormState>();

  ServicesTypeModel? selectedService;

  late DateTime _dataServico;
  late bool isEditing;
  bool _lembreteAtivo = false;
  DateTime? _lembreteData;

  late TextEditingController _kmController;
  late TextEditingController _custoController;
  late TextEditingController _observacoesController;
  late TextEditingController _lembreteKmController;

  @override
  void initState() {
    isEditing = widget.entry != null;
    super.initState();

    _dataServico = widget.entry?.dataServico ?? DateTime.now();
    _lembreteData = widget.entry?.lembreteData;
    _lembreteAtivo = widget.entry?.lembreteAtivo ?? false;

    _kmController = TextEditingController(
      text: isEditing
          ? widget.entry!.quilometragem.toStringAsFixed(0)
          : (widget.lastOdometer?.toStringAsFixed(0) ?? ''),
    );

    _custoController = TextEditingController(
      text: (isEditing && widget.entry!.custo != null)
          ? widget.entry!.custo!.toStringAsFixed(2)
          : '',
    );

    _observacoesController = TextEditingController(text: widget.entry?.observacoes ?? '');

    _lembreteKmController = TextEditingController(
      text: (isEditing && widget.entry?.lembreteKm != null)
          ? widget.entry!.lembreteKm!.toStringAsFixed(0)
          : '',
    );

    _loadInitialData();
  }

  void _loadInitialData() {
    final services = serviceController.serviceType;

    if (isEditing) {
      selectedService = services.firstWhereOrNull((s) => s.nome == widget.entry!.tipo);
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

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final double km = double.tryParse(_kmController.text.replaceAll(',', '.')) ?? 0.0;
      final double custo = double.tryParse(_custoController.text.replaceAll(',', '.')) ?? 0.0;
      final double? lembreteKm = _lembreteAtivo
          ? double.tryParse(_lembreteKmController.text.replaceAll(',', '.'))
          : null;

      final updatedEntry = MaintenanceEntry(
        id: widget.entry?.id,
        tipo: selectedService!.nome,
        dataServico: _dataServico,
        quilometragem: km,
        custo: (custo != null && custo > 0) ? custo : null,
        observacoes: _observacoesController.text.trim().isEmpty
            ? null
            : _observacoesController.text.trim(),
        lembreteAtivo: _lembreteAtivo,
        lembreteKm: lembreteKm,
        lembreteData: _lembreteAtivo ? _lembreteData : null,
        veiculoId: widget.entry?.veiculoId ?? 1,
      );

      try {
        await controller.saveMaintenance(updatedEntry);
        Get.back();
        _showSuccessSnackBar(updatedEntry.tipo);
      } catch (e) {
        _showErrorSnackBar(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      return Directionality(
        textDirection: languageController.textDirection,
        child: Scaffold(
          backgroundColor: theme.brightness == Brightness.dark
              ? AppTheme.backgroundColorDark
              : AppTheme.backgroundColorLight,
          appBar: AppBar(
            title: Text(isEditing ? 'Editar Manutenção' : 'Nova Manutenção'),
            actions: [IconButton(icon: const Icon(RemixIcons.save_line), onPressed: _submit)],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildServiceDropdown(theme),
                const SizedBox(height: 20),
                _buildDatePickerTile(theme),
                const SizedBox(height: 20),
                _buildNumericField(
                  _kmController,
                  context.tr(TranslationKeys.commonLabelsOdometer),
                  unitController.distanceUnit.value.name,
                  required: true,
                  icon: RemixIcons.dashboard_3_line,
                ),
                const SizedBox(height: 16),
                _buildNumericField(
                  _custoController,
                  context.tr(TranslationKeys.maintenanceFormCost),
                  currencyController.currencySymbol.value,
                  isDecimal: true,
                  icon: RemixIcons.money_dollar_circle_line,
                ),
                const SizedBox(height: 16),
                _buildNotesField(),
                const SizedBox(height: 30),
                _buildReminderSection(theme),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildServiceDropdown(ThemeData theme) {
    return DropdownButtonFormField<ServicesTypeModel>(
      value: selectedService,
      decoration: const InputDecoration(
        labelText: 'Tipo de Serviço',
        prefixIcon: Icon(RemixIcons.tools_line),
        border: OutlineInputBorder(),
      ),
      items: serviceController.serviceType
          .map((s) => DropdownMenuItem(value: s, child: Text(s.nome)))
          .toList(),
      onChanged: (val) => setState(() => selectedService = val),
      validator: (v) => v == null ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildDatePickerTile(ThemeData theme) {
    return ListTile(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      leading: const Icon(RemixIcons.calendar_event_line),
      title: const Text('Data do Serviço'),
      subtitle: Text(DateFormat('dd/MM/yyyy').format(_dataServico)),
      onTap: () => _selectDate(context, true),
    );
  }

  Widget _buildNumericField(
    TextEditingController ctrl,
    String label,
    String suffix, {
    bool isDecimal = false,
    bool required = false,
    required IconData icon,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(isDecimal ? r'^\d+[,.]?\d{0,2}' : r'^\d+')),
      ],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
      validator: (v) => (required && (v == null || v.isEmpty)) ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _observacoesController,
      maxLength: 50,
      decoration: InputDecoration(
        labelText: context.tr(TranslationKeys.maintenanceFormNotes),
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildReminderSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(RemixIcons.notification_4_line, size: 20),
            const SizedBox(width: 8),
            Text(
              context.tr(TranslationKeys.maintenanceFormReminderSection),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Ativar alerta de manutenção'),
          value: _lembreteAtivo,
          onChanged: (v) => setState(() => _lembreteAtivo = v ?? false),
        ),
        if (_lembreteAtivo) ...[
          const SizedBox(height: 10),
          _buildNumericField(_lembreteKmController, 'Lembrar com (km)', unitController.distanceUnit.value.name, icon: RemixIcons.speed_up_line),
          const SizedBox(height: 10),
          ListTile(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            title: const Text('Data limite do lembrete'),
            subtitle: Text(
              _lembreteData != null
                  ? DateFormat('dd/MM/yyyy').format(_lembreteData!)
                  : 'Não definida',
            ),
            trailing: const Icon(RemixIcons.calendar_2_line),
            onTap: () => _selectDate(context, false),
          ),
        ],
      ],
    );
  }

  void _showSuccessSnackBar(String tipo) {
    Get.snackbar(
      'Sucesso',
      isEditing ? '$tipo atualizado' : '$tipo adicionado',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _showErrorSnackBar(String error) {
    Get.snackbar(
      'Erro',
      'Não foi possível salvar: $error',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }
}
