import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/controllers/language_controller.dart';
import 'package:fuel_tracker_app/controllers/type_gas_controller.dart';
import 'package:fuel_tracker_app/controllers/unit_controller.dart';
import 'package:fuel_tracker_app/controllers/vehicle_controller.dart';
import 'package:fuel_tracker_app/data/fuel_db.dart';
import 'package:fuel_tracker_app/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/controllers/gas_station_controller.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';

class FuelEntryScreen extends StatefulWidget {
  final double? lastOdometer;
  final FuelEntryModel? entry;
  const FuelEntryScreen({super.key, this.lastOdometer, this.entry});

  @override
  State<FuelEntryScreen> createState() => _FuelEntryScreenState();
}

class _FuelEntryScreenState extends State<FuelEntryScreen> {
  final FuelDb _db = FuelDb();
  final FuelListController controller = Get.find<FuelListController>();
  final TypeGasController typeGasController = Get.find<TypeGasController>();
  final GasStationController gasStationController = Get.find<GasStationController>();
  final VehicleController vehicleController = Get.find<VehicleController>();
  final UnitController unitController = Get.find<UnitController>();
  final CurrencyController currencyController = Get.find<CurrencyController>();
  final LanguageController languageController = Get.find<LanguageController>();

  final _formKey = GlobalKey<FormState>();

  int? selectedGas;
  int? selectedVeiculos;
  int? selectedStations;
  late DateTime selectedDate;
  String comprovantePath = '';
  final ImagePicker _picker = ImagePicker();
  late TextEditingController kmController;
  late MoneyMaskedTextController litrosController;
  late MoneyMaskedTextController pricePerLiterController;
  late MoneyMaskedTextController totalPriceController;
  bool isTankFull = false;
  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    _initializeController();

    litrosController.addListener(calculatePrice);
    pricePerLiterController.addListener(calculatePrice);
    totalPriceController.addListener(calculatePrice);
  }

  void _initializeController() {
    if (_isEditing) {
      final fuel = widget.entry!;
      kmController = TextEditingController(text: fuel.odometerKm.toString());
      litrosController = MoneyMaskedTextController(
        initialValue: fuel.volumeLiters,
        decimalSeparator: ',',
        thousandSeparator: '.',
        precision: 2,
      );
      pricePerLiterController = MoneyMaskedTextController(
        initialValue: fuel.pricePerLiter,
        leftSymbol: currencyController.currencySymbol.value,
        decimalSeparator: ',',
        thousandSeparator: '.',
        precision: 2,
      );
      totalPriceController = MoneyMaskedTextController(
        initialValue: fuel.totalCost,
        leftSymbol: currencyController.currencySymbol.value,
        decimalSeparator: ',',
        thousandSeparator: '.',
        precision: 2,
      );
      selectedGas = fuel.fuelTypeId;
      selectedVeiculos = fuel.vehicleId;
      selectedStations = fuel.gasStationId;

      selectedDate = fuel.entryDate;
      comprovantePath = fuel.receiptPath ?? '';
    } else {
      kmController = TextEditingController(text: widget.lastOdometer?.toStringAsFixed(0) ?? '');
      litrosController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
      pricePerLiterController = MoneyMaskedTextController(
        leftSymbol: currencyController.currencySymbol.value,
        decimalSeparator: ',',
        thousandSeparator: '.',
      );
      totalPriceController = MoneyMaskedTextController(
        leftSymbol: currencyController.currencySymbol.value,
        decimalSeparator: ',',
        thousandSeparator: '.',
      );
      selectedDate = DateTime.now();
      comprovantePath = '';
    }
  }

  @override
  void dispose() {
    kmController.dispose();
    litrosController.removeListener(calculatePrice);
    pricePerLiterController.removeListener(calculatePrice);
    totalPriceController.removeListener(calculatePrice);

    pricePerLiterController.dispose();
    totalPriceController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final currentOdometerValue = getOdometerValue() ?? 0.0;
      final litersValue = getLitersValue();

      final newFuel = FuelEntryModel(
        id: widget.entry?.id,
        vehicleId: selectedVeiculos!,
        fuelTypeId: selectedGas!,
        gasStationId: selectedStations!,
        entryDate: selectedDate,
        odometerKm: currentOdometerValue,
        volumeLiters: litersValue!,
        pricePerLiter: getPricePerLiterValue()!,
        totalCost: getTotalPriceValue()!,
        tankFull: isTankFull == false ? 0 : 1,
        receiptPath: comprovantePath,
      );

      try {
        await controller.saveFuel(newFuel.toMap());
        if (!mounted) return;
        Get.back();

        Get.snackbar(
          'Sucesso',
          _isEditing
              ? 'Abastecimento atualizado com sucesso!'
              : 'Abastecimento em "${newFuel.gasStationId}" adicionado com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        if (!mounted) return;
        Get.back();

        Get.snackbar(
          'Erro',
          'Falha ao salvar o abastecimento: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
        );
      }
    }
  }

  double? getOdometerValue() => double.tryParse(kmController.text);
  double? getLitersValue() => litrosController.numberValue;
  double? getPricePerLiterValue() => pricePerLiterController.numberValue;
  double? getTotalPriceValue() => totalPriceController.numberValue;

  void calculatePrice() {
    final double? liters = getLitersValue();
    final double? pricePerLiter = getPricePerLiterValue();
    final double? totalPriceEntered = getTotalPriceValue();

    if (liters != null && pricePerLiter != null) {
      final double calculatedTotal = liters * pricePerLiter;

      totalPriceController.removeListener(calculatePrice);
      totalPriceController.updateValue(calculatedTotal);
      totalPriceController.addListener(calculatePrice);
    } else if (liters != null && totalPriceEntered != null && liters > 0) {
      final calculatedPricePerLiter = totalPriceEntered / liters;
      pricePerLiterController.removeListener(calculatePrice);
      pricePerLiterController.updateValue(calculatedPricePerLiter);
      pricePerLiterController.addListener(calculatePrice);
    } else if (pricePerLiter != null && totalPriceEntered != null && pricePerLiter > 0) {
      final calculatedLiters = totalPriceEntered / pricePerLiter;
      litrosController.removeListener(calculatePrice);
      litrosController.updateValue(calculatedLiters);
      litrosController.addListener(calculatePrice);
    }
  }

  Future<void> pickComprovante() async {
    final source = await Get.dialog<ImageSource>(
      SimpleDialog(
        title: Text(context.tr(TranslationKeys.entryScreenDialogReceiptTitle)),
        children: [
          SimpleDialogOption(
            onPressed: () => Get.back(result: ImageSource.camera),
            child: Text(context.tr(TranslationKeys.entryScreenDialogReceiptOptionCamera)),
          ),
          SimpleDialogOption(
            onPressed: () => Get.back(result: ImageSource.gallery),
            child: Text(context.tr(TranslationKeys.entryScreenDialogReceiptOptionGallery)),
          ),
        ],
      ),
    );

    if (source != null) {
      try {
        final XFile? pickedFile = await _picker.pickImage(source: source);
        if (pickedFile != null) {
          setState(() {
            comprovantePath = pickedFile.path;
          });

          Get.snackbar(
            'Comprovante Selecionado',
            context.tr(
              TranslationKeys.entryScreenSnackbarReceiptSelectedPrefix,
              parameters: {'name': pickedFile.name},
            ),
          );
        }
      } catch (e) {
        Get.snackbar(
          'Erro',
          context.tr(
            TranslationKeys.entryScreenSnackbarReceiptSelectedPrefix,
            parameters: {'error': e.toString()},
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entry != null;
    final controller = Get.put(FuelListController());

    final theme = Theme.of(context);
    final languageController = Get.find<LanguageController>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        title: Text(
          isEditing
              ? context.tr(TranslationKeys.entryScreenTitleEdit)
              : context.tr(TranslationKeys.entryScreenTitleNew),
        ),
        actions: [
          IconButton(
            icon: isEditing ? Icon(RemixIcons.edit_line) : Icon(RemixIcons.save_line),
            onPressed: _submit,
            tooltip: isEditing
                ? context.tr(TranslationKeys.entryScreenButtonEdit)
                : context.tr(TranslationKeys.entryScreenButtonSave),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: Icon(RemixIcons.calendar_event_line),
                title: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                subtitle: Text(context.tr(TranslationKeys.entryScreenLabelDate)),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => selectedDate = date);
                },
              ),

              const SizedBox(height: 20),
              if (controller.lastOdometer != null && !isEditing)
                Container(
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${context.tr(TranslationKeys.entryScreenInfoLastOdometerPrefix)} ${controller.lastOdometer} km. ${context.tr(TranslationKeys.entryScreenInfoLastOdometerPrefix2)}',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 14.0,
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: kmController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Odômetro Atual (km)",
                  prefixIcon: Icon(RemixIcons.dashboard_3_line),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              Obx(
                () => DropdownButtonFormField<int>(
                  value: selectedVeiculos,
                  decoration: InputDecoration(
                    labelText: "Veículo",
                    prefixIcon: Icon(RemixIcons.car_line),
                  ),
                  items: controller.vehicleEntries
                      .map(
                        (v) => DropdownMenuItem(
                          value: v.id,
                          child: Text(v.nickname, style: TextStyle(color: AppTheme.textGrey)),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedVeiculos = val),
                  validator: (value) => value == null ? 'Selecione um veículo' : null,
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => DropdownButtonFormField<int>(
                  value: selectedGas,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Combustível',
                    prefixIcon: Icon(RemixIcons.oil_line),
                  ),
                  items: controller.fuelTypeEntries
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.nome, style: TextStyle(color: AppTheme.textGrey)),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedGas = val),
                  validator: (value) => value == null ? 'Selecione um combustível' : null,
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => DropdownButtonFormField<int>(
                  value: selectedStations,
                  decoration: InputDecoration(
                    labelText: 'Posto',
                    prefixIcon: Icon(RemixIcons.gas_station_line),
                  ),
                  items: controller.gasStationEntries
                      .map(
                        (p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.nome, style: TextStyle(color: AppTheme.textGrey)),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedStations = val),
                  validator: (value) => value == null ? 'Selecione um posto' : null,
                ),
              ),
              const SizedBox(height: 16),
              if (selectedStations != null) _buildStationDetails(),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: _buildValueField(litrosController, "Litros")),
                  const SizedBox(width: 10),
                  Expanded(child: _buildValueField(pricePerLiterController, "Preço/L")),
                ],
              ),
              const SizedBox(height: 16),
              _buildValueField(totalPriceController, "Custo Total", readOnly: false),
              const SizedBox(height: 16),

              SwitchListTile(
                title: Text("Tanque Cheio?"),
                secondary: Icon(
                  isTankFull ? RemixIcons.gas_station_fill : RemixIcons.gas_station_line,
                ),
                value: isTankFull,
                onChanged: (val) => setState(() => isTankFull = val),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Icon(
                  comprovantePath == null
                      ? RemixIcons.camera_line
                      : RemixIcons.checkbox_circle_line,
                ),
                title: Text(
                  comprovantePath == null ? "Adicionar Comprovante" : "Comprovante Anexado",
                ),
                trailing: comprovantePath != null
                    ? IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => setState(() => comprovantePath != null),
                      )
                    : null,
                onTap: pickComprovante,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStationDetails() {
    final station = controller.gasStationEntries.firstWhereOrNull((s) => s.id == selectedStations);
    if (station == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Get.theme.colorScheme.primary.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            RemixIcons.money_dollar_circle_line,
            "Gasolina Aditivada:",
            "R\$ ${station.priceGasolineAditivada.toStringAsFixed(2)}",
          ),
          _buildInfoRow(
            RemixIcons.money_dollar_circle_line,
            "Gasolina Comum:",
            "R\$ ${station.priceGasolineComum.toStringAsFixed(2)}",
          ),
          _buildInfoRow(
            RemixIcons.money_dollar_circle_line,
            "Etanol:",
            "R\$ ${station.priceEthanol.toStringAsFixed(2)}",
          ),
          _buildInfoRow(
            RemixIcons.money_dollar_circle_line,
            "Diesel S10:",
            "R\$ ${station.priceGasolinePremium.toStringAsFixed(2)}",
          ),
        ],
      ),
    );
  }

  Widget _buildValueField(TextEditingController ctrl, String label, {bool readOnly = false}) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      validator: (v) => (ctrl as MoneyMaskedTextController).numberValue <= 0 ? "Invalido" : null,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textGrey),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildServiceRow(BuildContext context, IconData icon, String label, bool status) {
    final color = status ? Colors.green.shade700 : Colors.red.shade700;
    final text = status ? 'SIM' : 'NÃO';
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: AppTheme.textGrey)),
        const Spacer(),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
