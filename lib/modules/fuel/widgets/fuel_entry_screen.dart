import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/language_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/lookup_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/unit_controller.dart';
import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/core/app_theme.dart';
import 'package:fuel_tracker_app/core/app_localizations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final FuelListController controller = Get.find<FuelListController>();
  final LookupController lookupController = Get.find<LookupController>();
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
      isTankFull = fuel.tankFull;

      selectedDate = DateTime.tryParse(fuel.entryDate) ?? DateTime.now();
      comprovantePath = fuel.receiptPath ?? '';
    } else {
      kmController = TextEditingController(
        text: widget.lastOdometer?.toStringAsFixed(0) ?? '',
      );
      litrosController = MoneyMaskedTextController(
        decimalSeparator: ',',
        thousandSeparator: '.',
      );
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
      isTankFull = false;
      comprovantePath = '';
      selectedStations = 1;
      selectedGas = 1;
      selectedVeiculos = 1;
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

      final double vehicleTankCapacity =
          (controller.veiculosMap[selectedVeiculos!]?['tank_capacity']
              as double?) ??
          0.0;

      final Map<String, dynamic> fuelData = {
        'fk_veiculo': selectedVeiculos!,
        'fk_tipo': selectedGas!,
        'fk_posto': selectedStations!,
        'data': selectedDate.toIso8601String(),
        'velocimetro': currentOdometerValue,
        'litros_volume': litersValue!,
        'preco_litro': getPricePerLiterValue()!,
        'custo_total': getTotalPriceValue()!,
        'tanque_cheio': isTankFull,
        'tank_capacity': vehicleTankCapacity,
        'receipt_path': comprovantePath,
      };

      print(fuelData);

      try {
        if (_isEditing) {
          final updatedModel = FuelEntryModel(
            id: widget.entry?.id,
            vehicleId: fuelData['fk_veiculo'],
            fuelTypeId: fuelData['fk_tipo'],
            gasStationId: fuelData['fk_posto'],
            entryDate: fuelData['data'],
            odometerKm: fuelData['velocimetro'],
            volumeLiters: fuelData['litros_volume'],
            pricePerLiter: fuelData['preco_litro'],
            totalCost: fuelData['custo_total'],
            tankFull: fuelData['tanque_cheio'],
            tankCapacity: fuelData['tank_capacity'],
            receiptPath: fuelData['receipt_path'],
          );

          await controller.updateFuel(updatedModel);
        } else {
          await controller.saveFuel(fuelData);
        }

        Get.back(result: true);
      } catch (e) {
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
    } else if (pricePerLiter != null &&
        totalPriceEntered != null &&
        pricePerLiter > 0) {
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
            child: Text(
              context.tr(TranslationKeys.entryScreenDialogReceiptOptionCamera),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Get.back(result: ImageSource.gallery),
            child: Text(
              context.tr(TranslationKeys.entryScreenDialogReceiptOptionGallery),
            ),
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
            icon: isEditing
                ? Icon(RemixIcons.edit_line)
                : Icon(RemixIcons.save_line),
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
              if (controller.lastOdometer != null && !isEditing)
                Container(
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.5),
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
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontSize: 14.0,
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondary.withOpacity(0.9),
                                height: 1.4,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              _buildDatePicker(),

              const SizedBox(height: 16),
              _buildTextField(
                controller: kmController,
                keyboardType: TextInputType.number,
                label: "Odômetro Atual (km)",
                icon: RemixIcons.dashboard_3_line,
              ),
              const SizedBox(height: 16),
              _buildDropdownVeiculos(),
              const SizedBox(height: 16),
              _buildDropdownTipo(),
              const SizedBox(height: 16),
              _buildDropdownPosto(),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: litrosController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      label: "Litros",
                      icon: RemixIcons.gas_station_line,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      controller: pricePerLiterController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      label: "Preço por Litro",
                      icon: RemixIcons.money_dollar_circle_line,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: totalPriceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                label: "Custo Total",
                icon: RemixIcons.money_dollar_circle_line,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              _buildComprovantes(),
              const SizedBox(height: 16),
              _buildSwitches(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComprovantes() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 0.4),
      ),
      child: ListTile(
        leading: Icon(
          comprovantePath == null
              ? RemixIcons.camera_line
              : RemixIcons.checkbox_circle_line,
        ),
        title: Text(
          comprovantePath == null
              ? "Adicionar Comprovante"
              : "Comprovante Anexado",
        ),
        trailing: comprovantePath != null
            ? IconButton(
                icon: Icon(Icons.close),
                onPressed: () => setState(() => comprovantePath != null),
              )
            : null,
        onTap: pickComprovante,
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) setState(() => selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 0.4),
        ),
        child: Row(
          children: [
            const Icon(
              RemixIcons.calendar_line,
              color: Color(0xFF00A3FF),
              size: 20,
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Text(
                  'Data de Abastecimento',
                  style: GoogleFonts.lato(color: Colors.white38, fontSize: 12),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(selectedDate),
                  style: GoogleFonts.lato(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitches() {
    return SwitchListTile(
      title: Text(
        "Tanque Cheio?",
        style: GoogleFonts.lato(color: Colors.white),
      ),
      secondary: Icon(
        isTankFull ? RemixIcons.gas_station_fill : RemixIcons.gas_station_line,
      ),
      value: isTankFull,
      onChanged: (val) => setState(() => isTankFull = val),
    );
  }

  Widget _buildDropdownVeiculos() {
    return Obx(() {
      return DropdownButtonFormField<int>(
        value: selectedVeiculos,
        dropdownColor: const Color(0xFF1A1A1A),
        style: GoogleFonts.lato(color: Colors.white),
        decoration: _dropdownDecoration("Veículo", RemixIcons.car_line),
        items: lookupController.veiculosDrop
            .map((e) => DropdownMenuItem(value: e.id, child: Text(e.nickname)))
            .toList(),
        onChanged: (val) => setState(() => selectedVeiculos = val),
        validator: (value) => value == null ? 'Selecione um veículo' : null,
      );
    });
  }

  Widget _buildDropdownTipo() {
    return Obx(() {
      return DropdownButtonFormField<int>(
        value: selectedGas,
        dropdownColor: const Color(0xFF1A1A1A),
        style: GoogleFonts.lato(color: Colors.white),
        decoration: _dropdownDecoration(
          'Tipo de Combustível',
          RemixIcons.oil_line,
        ),
        items: lookupController.tipoDrop
            .map((c) => DropdownMenuItem(value: c.id, child: Text(c.nome)))
            .toList(),
        onChanged: (val) => setState(() => selectedGas = val),
        validator: (value) => value == null ? 'Selecione um combustível' : null,
      );
    });
  }

  Widget _buildDropdownPosto() {
    return Obx(() {
      return DropdownButtonFormField<int>(
        value: selectedStations,
        dropdownColor: const Color(0xFF1A1A1A),
        style: GoogleFonts.lato(color: Colors.white),
        decoration: _dropdownDecoration('Posto', RemixIcons.gas_station_line),
        items: lookupController.postosDrop
            .map((p) => DropdownMenuItem(value: p.id, child: Text(p.nome)))
            .toList(),
        onChanged: (val) => setState(() => selectedStations = val),
        validator: (value) => value == null ? 'Selecione um posto' : null,
      );
    });
  }

  InputDecoration _dropdownDecoration(String label, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF1A1A1A),
      labelText: label,
      labelStyle: GoogleFonts.lato(color: Colors.white),
      prefixIcon: Icon(icon, color: const Color(0xFF00A3FF), size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildStationDetails() {
    // final station = controller.gasStationEntries.firstWhereOrNull(
    //   (s) => s.id == selectedStations,
    // );
    // if (station == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Get.theme.colorScheme.primary.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            RemixIcons.money_dollar_circle_line,
            "Gasolina Aditivada:",
            "R\$ {station.priceGasolineAditivada.toStringAsFixed(2)}",
          ),
          _buildInfoRow(
            RemixIcons.money_dollar_circle_line,
            "Gasolina Comum:",
            "R\$ {station.priceGasolineComum.toStringAsFixed(2)}",
          ),
          _buildInfoRow(
            RemixIcons.money_dollar_circle_line,
            "Etanol:",
            "R\$ {station.priceEthanol.toStringAsFixed(2)}",
          ),
          _buildInfoRow(
            RemixIcons.money_dollar_circle_line,
            "Diesel S10:",
            "R\$ {station.priceGasolinePremium.toStringAsFixed(2)}",
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.lato(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (v) =>
          (isRequired && (v == null || v.isEmpty)) ? "Campo obrigatório" : null,
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
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRow(
    BuildContext context,
    IconData icon,
    String label,
    bool status,
  ) {
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
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
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
