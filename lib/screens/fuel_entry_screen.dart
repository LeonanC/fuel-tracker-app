import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/controllers/type_gas_controller.dart';
import 'package:fuel_tracker_app/controllers/unit_controller.dart';
import 'package:fuel_tracker_app/controllers/vehicle_controller.dart';
import 'package:fuel_tracker_app/data/fuel_db.dart';
import 'package:fuel_tracker_app/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/models/gas_station_model.dart';
import 'package:fuel_tracker_app/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/controllers/gas_station_controller.dart';
import 'package:fuel_tracker_app/controllers/language_controller.dart';
import 'package:fuel_tracker_app/models/type_gas_model.dart';
import 'package:fuel_tracker_app/models/vehicle_model.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:uuid/uuid.dart';

class FuelEntryScreen extends StatefulWidget {
  final double? lastOdometer;
  final FuelEntry? entry;
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

  TypeGasModel? selectedGas;
  VehicleModel? selectedVeiculos;
  GasStationModel? selectedStations;

  late String veiculosName;
  late String stationName;
  late DateTime selectedDate;

  late bool tanqueCheio = false;
  late String comprovantePath;
  late List<TypeGasModel> availableTipos = [];
  late List<VehicleModel> availableVeiculos = [];
  late List<GasStationModel> availableGasStations = [];

  late bool isEditing;
  late bool isLoading = true;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController kmController;
  late MoneyMaskedTextController litrosController;
  late MoneyMaskedTextController pricePerLiterController;
  late MoneyMaskedTextController totalPriceController;

  @override
  void initState() {
    isEditing = widget.entry != null;
    super.initState();

    if (isEditing) {
      final fuel = widget.entry;
      kmController = TextEditingController(text: fuel?.quilometragem.toStringAsFixed(0));
      litrosController = MoneyMaskedTextController(
        initialValue: fuel?.litros ?? 0.0,
        decimalSeparator: ',',
        thousandSeparator: '.',
        precision: 2,
      );
      pricePerLiterController = MoneyMaskedTextController(
        initialValue: fuel?.pricePerLiter ?? 0.0,
        leftSymbol: 'R\$ ',
        decimalSeparator: ',',
        thousandSeparator: '.',
        precision: 2,
      );
      totalPriceController = MoneyMaskedTextController(
        initialValue: fuel?.totalPrice ?? 0.0,
        leftSymbol: 'R\$ ',
        decimalSeparator: ',',
        thousandSeparator: '.',
        precision: 2,
      );

      selectedDate = fuel?.dataAbastecimento ?? DateTime.now();
      tanqueCheio = fuel?.tanqueCheio ?? false;
      comprovantePath = fuel?.comprovantePath ?? '';
    } else {
      kmController = widget.lastOdometer != null
          ? TextEditingController(text: widget.lastOdometer!.toStringAsFixed(0))
          : TextEditingController(text: '');
      litrosController = MoneyMaskedTextController();
      pricePerLiterController = MoneyMaskedTextController(leftSymbol: 'R\$ ');
      totalPriceController = MoneyMaskedTextController(leftSymbol: 'R\$ ');
      selectedDate = DateTime.now();
      tanqueCheio = false;
      comprovantePath = '';
    }

    _loadInitialData();

    litrosController.addListener(calculatePrice);
    pricePerLiterController.addListener(calculatePrice);
    totalPriceController.addListener(calculatePrice);
  }

  Future<void> _loadInitialData() async {
    availableTipos = typeGasController.typeGas;
    availableVeiculos = vehicleController.vehicles;
    availableGasStations = gasStationController.stations;

    if (isEditing && widget.entry != null) {
      selectedGas = availableTipos.firstWhereOrNull((t) => t.nome == widget.entry!.tipo);
      selectedVeiculos = availableVeiculos.firstWhereOrNull(
        (v) => v.nickname == widget.entry!.veiculo,
      );
      selectedStations = availableGasStations.firstWhereOrNull(
        (s) => s.nome == widget.entry!.posto,
      );

      typeGasController.selectedTypeGas = selectedGas;
      vehicleController.selectedVehicle = selectedVeiculos;
      gasStationController.selectedGasStation = selectedStations;

      setState(() {});
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

      final currentOdometer = getOdometerValue();
      final litersValue = getLitersValue();
      final typeGasName = selectedGas?.nome;
      final vehicleNome = selectedVeiculos?.nickname;
      final stationName = selectedStations?.nome;

      if (!isEditing) {
        final lastOdometer = await _db.getLastOdometer();

        if (currentOdometer == kmController.text) {
          Get.snackbar(
            'Erro de Quilometragem',
            'A quilometragem atual ($currentOdometer Km) não pode ser menor que a última registrada ($lastOdometer Km).',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
          return;
        }
      }

      final fuelId = widget.entry?.id ?? const Uuid().v4();

      final newFuel = FuelEntry(
        id: fuelId,
        tipo: typeGasName!,
        dataAbastecimento: selectedDate,
        veiculo: vehicleNome!,
        posto: stationName!,
        quilometragem: getOdometerValue()!,
        litros: litersValue!,
        pricePerLiter: getPricePerLiterValue(),
        totalPrice: getTotalPriceValue(),
        tanqueCheio: tanqueCheio,
        comprovantePath: comprovantePath,
      );

      try {
        await controller.saveFuel(newFuel);
        if (!mounted) return;
        Get.back();

        Get.snackbar(
          'Sucesso',
          isEditing
              ? 'Abastecimento atualizado com sucesso!'
              : 'Abastecimento em "${newFuel.posto}" adicionado com sucesso!',
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

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023, 1),
      lastDate: DateTime(2030, 12),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
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

  void removeComprovante() {
    setState(() {
      comprovantePath != comprovantePath;
    });
  }

  void updateFuelType(TypeGasModel? newGas) {
    if (newGas != null) {
      selectedGas = newGas;
    }
  }

  void updateGasStation(GasStationModel? newStation) {
    if (newStation != null) {
      setState(() {
        selectedStations = newStation;
      });
    }
  }

  void updateVeiculos(VehicleModel? newVehicle) {
    if (newVehicle != null) {
      setState(() {
        selectedVeiculos = newVehicle;
      });
    }
  }

  void toggleFullTank(bool? newValue) {
    setState(() {
      tanqueCheio = newValue ?? false;
    });
  }

  String? validateLiters(String? value) {
    if (getLitersValue() == null || getLitersValue()! <= 0) {
      return context.tr(TranslationKeys.validationRequiredValidLiters);
    }
    return null;
  }

  String? validatePricePerLiter(String? value) {
    if (getPricePerLiterValue() == null || getPricePerLiterValue()! <= 0) {
      return context.tr(TranslationKeys.validationRequiredValidPricePerLiter);
    }
    return null;
  }

  String? validateTotalPrice(String? value) {
    if (getTotalPriceValue() == null || getTotalPriceValue()! <= 0) {
      return context.tr(TranslationKeys.validationRequiredValidTotalPrice);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entry != null;
    final controller = Get.put(FuelListController());

    final theme = Theme.of(context);
    final languageController = Get.find<LanguageController>();

    return Obx(
      () => Directionality(
        textDirection: languageController.textDirection,
        child: Scaffold(
          backgroundColor: theme.brightness == Brightness.dark
              ? AppTheme.backgroundColorDark
              : AppTheme.backgroundColorLight,
          appBar: AppBar(
            backgroundColor: theme.brightness == Brightness.dark
                ? AppTheme.backgroundColorDark
                : AppTheme.backgroundColorLight,
            centerTitle: false,
            elevation: 0,
            title: Text(
              isEditing
                  ? context.tr(TranslationKeys.entryScreenTitleEdit)
                  : context.tr(TranslationKeys.entryScreenTitleNew),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    leading: Icon(
                      RemixIcons.time_line,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      DateFormat('dd/MM/yyyy').format(selectedDate),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      context.tr(TranslationKeys.entryScreenLabelDate),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: Icon(
                      RemixIcons.calendar_2_fill,
                      color: Theme.of(context).colorScheme.secondary,
                    ),

                    onTap: () => selectDate(context),
                    dense: true,
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
                              '${context.tr(TranslationKeys.entryScreenInfoLastOdometerPrefix)} ${controller.lastOdometer.toStringAsFixed(0)} km. ${context.tr(TranslationKeys.entryScreenInfoLastOdometerPrefix2)}',
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
                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                    decoration: InputDecoration(
                      labelText: context.tr(TranslationKeys.entryScreenLabelOdometer),
                    ),
                    validator: (value) {
                      if (getOdometerValue() == 0.0) {
                        return 'Informe a quilometragem atual.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<TypeGasModel>(
                    decoration: InputDecoration(
                      labelText: context.tr(TranslationKeys.entryScreenLabelFuelType),
                      border: OutlineInputBorder(),
                    ),
                    value: selectedGas,
                    items: availableTipos.map((TypeGasModel gas) {
                      return DropdownMenuItem<TypeGasModel>(
                        value: gas,
                        child: Text(gas.nome, style: TextStyle(color: AppTheme.textGrey)),
                      );
                    }).toList(),
                    onChanged: availableTipos.isEmpty ? null : updateFuelType,
                    validator: (value) {
                      if (value == null) {
                        return context.tr(TranslationKeys.validationRequiredFuelType);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildValueField(
                    context,
                    litrosController,
                    context.tr(TranslationKeys.entryScreenLabelLiters),
                    validateLiters,
                  ),
                  const SizedBox(height: 16),
                  _buildValueField(
                    context,
                    pricePerLiterController,
                    context.tr(TranslationKeys.entryScreenLabelPricePerLiter),
                    validatePricePerLiter,
                  ),
                  const SizedBox(height: 16),
                  _buildValueField(
                    context,
                    totalPriceController,
                    context.tr(TranslationKeys.entryScreenLabelTotalPrice),
                    validateTotalPrice,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<VehicleModel>(
                    decoration: InputDecoration(
                      labelText: context.tr(TranslationKeys.entryScreenLabelVeiculos),
                      border: OutlineInputBorder(),
                    ),
                    value: selectedVeiculos,
                    items: availableVeiculos.isEmpty
                        ? null
                        : availableVeiculos.map((VehicleModel vehicle) {
                            return DropdownMenuItem<VehicleModel>(
                              value: vehicle,
                              child: Text(
                                vehicle.nickname,
                                style: TextStyle(color: AppTheme.textGrey),
                              ),
                            );
                          }).toList(),
                    onChanged: availableVeiculos.isEmpty ? null : updateVeiculos,
                    validator: (value) {
                      if (value == null) {
                        return context.tr(TranslationKeys.validationRequiredVeiculos);
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),
                  DropdownButtonFormField<GasStationModel>(
                    decoration: InputDecoration(
                      labelText: context.tr(TranslationKeys.entryScreenLabelGasStation),
                      border: OutlineInputBorder(),
                    ),
                    value: selectedStations,
                    items: availableGasStations.isEmpty
                        ? null
                        : availableGasStations.map((GasStationModel station) {
                            return DropdownMenuItem<GasStationModel>(
                              value: station,
                              child: Text(station.nome, style: TextStyle(color: AppTheme.textGrey)),
                            );
                          }).toList(),
                    onChanged: availableGasStations.isEmpty ? null : updateGasStation,
                    validator: (value) {
                      if (value == null) {
                        return context.tr(TranslationKeys.validationRequiredFuelType);
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  if (selectedStations != null && selectedStations!.id != -1)
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detalhes do Posto: ${selectedStations!.nome} (${selectedStations!.brand})',
                            style: theme.textTheme.titleMedium!.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            context,
                            RemixIcons.car_line,
                            'Veículo:',
                            selectedVeiculos!.nickname,
                          ),
                          _buildInfoRow(
                            context,
                            RemixIcons.oil_line,
                            'Gasolina Comum (R\$):',
                            selectedStations!.priceGasolineComum.toStringAsFixed(2),
                          ),
                          _buildInfoRow(
                            context,
                            RemixIcons.oil_line,
                            'Gasolina Aditivada (R\$):',
                            selectedStations!.priceGasolineAditivada.toStringAsFixed(2),
                          ),
                          _buildInfoRow(
                            context,
                            RemixIcons.oil_line,
                            'Gasolina Premium (R\$):',
                            selectedStations!.priceGasolinePremium.toStringAsFixed(2),
                          ),
                          _buildInfoRow(
                            context,
                            RemixIcons.oil_line,
                            'Etanol (R\$):',
                            selectedStations!.priceEthanol.toStringAsFixed(2),
                          ),
                          _buildServiceRow(
                            context,
                            RemixIcons.store_2_line,
                            'Loja de Conv.:',
                            selectedStations!.hasConvenientStore,
                          ),
                          _buildServiceRow(
                            context,
                            RemixIcons.time_line,
                            '24 Horas:',
                            selectedStations!.is24Hours,
                          ),
                        ],
                      ),
                    ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              tanqueCheio
                                  ? RemixIcons.gas_station_fill
                                  : RemixIcons.gas_station_line,
                              color: tanqueCheio
                                  ? Theme.of(context).colorScheme.primary
                                  : AppTheme.textGrey,
                              size: 40,
                            ),
                            const SizedBox(width: 16),
                            Flexible(
                              child: Text(
                                context.tr(TranslationKeys.entryScreenLabelFullTank),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: tanqueCheio
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: tanqueCheio,
                        onChanged: toggleFullTank,
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    title: Text(
                      comprovantePath == null
                          ? context.tr(TranslationKeys.entryScreenReceiptAddOptional)
                          : context.tr(TranslationKeys.entryScreenReceiptSelected),
                      style: TextStyle(
                        color: comprovantePath == null
                            ? Colors.grey[700]
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: comprovantePath != null
                        ? Text(
                            context.tr(
                              TranslationKeys.entryScreenReceiptPathPrefix,
                              parameters: {'name': comprovantePath.split('/').last},
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
                        : null,
                    leading: Icon(
                      comprovantePath == null ? Icons.camera_alt_outlined : Icons.check_circle,
                      color: comprovantePath == null
                          ? Colors.grey
                          : Theme.of(context).colorScheme.primary,
                    ),
                    trailing: comprovantePath != null
                        ? IconButton(icon: const Icon(Icons.close), onPressed: removeComprovante)
                        : null,
                    onTap: pickComprovante,
                  ),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(
                      isEditing
                          ? context.tr(TranslationKeys.entryScreenButtonEdit)
                          : context.tr(TranslationKeys.entryScreenButtonSave),
                    ),
                  ),
                  const SizedBox(height: 27),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValueField(
    BuildContext context,
    TextEditingController controller,
    String label,
    String? Function(String?) validator,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      validator: validator,
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textGrey),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: AppTheme.textGrey)),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
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
