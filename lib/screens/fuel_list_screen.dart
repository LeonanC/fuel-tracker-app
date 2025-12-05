import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/controllers/gas_station_controller.dart';
import 'package:fuel_tracker_app/controllers/unit_controller.dart';
import 'package:fuel_tracker_app/controllers/vehicle_controller.dart';
import 'package:fuel_tracker_app/data/fuel_db.dart';
import 'package:fuel_tracker_app/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/models/gas_station_model.dart';
import 'package:fuel_tracker_app/models/vehicle_model.dart';
import 'package:fuel_tracker_app/screens/about_screen.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:fuel_tracker_app/utils/fuel_alert_card.dart';
import 'package:fuel_tracker_app/utils/fuel_list_filter_menu.dart';
import 'package:fuel_tracker_app/utils/overallConsumptionCard.dart';
import 'package:fuel_tracker_app/utils/unit_nums.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:uuid/uuid.dart';

class FuelListScreen extends GetView<FuelListController> {
  const FuelListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FuelListController>()) {
      Get.put(FuelListController());
    }
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
      appBar: AppBar(
        title: Text(context.tr(TranslationKeys.listScreenAppBarTitle)),
        backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
        elevation: theme.appBarTheme.elevation,
        centerTitle: theme.appBarTheme.centerTitle,
        actions: [
          IconButton(
            icon: Icon(RemixIcons.refresh_line),
            tooltip: context.tr(TranslationKeys.listScreenRefresh),
            onPressed: () async {
              controller.loadFuelEntries();
              Get.snackbar(
                context.tr(TranslationKeys.listScreenRefreshing),
                '',
                duration: const Duration(seconds: 2),
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            tooltip: context.tr(TranslationKeys.aboutTitle),
            onPressed: () => Get.to(() => AboutScreen()),
          ),
          FuelListFilterMenu(),
        ],
      ),
      body: Obx(() {
        final fuel = controller.loadedEntries;

        if (fuel.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                context.tr('Nenhum abastecimento registrado.').tr,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final filteredEntries = controller.filteredEntries;

        return Column(
          children: [
            OverallConsumptionCard(),
            FuelAlertCard(),
            Expanded(
              child: filteredEntries.isEmpty
                  ? Center(
                      child: Text(
                        controller.selectedVehicleFilter.value != null ||
                                controller.selectedFuelTypeFilter.value != null ||
                                controller.selectedStationFilter.value != null
                            ? 'Nenhum item encontrado com os filtros aplicados.'
                            : 'Ainda não Abasteceu',
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredEntries.length,
                      itemBuilder: (context, index) {
                        final FuelEntry currentEntry = filteredEntries[index];
                        final FuelEntry? previousEntry = (index + 1 < filteredEntries.length)
                            ? filteredEntries[index + 1]
                            : null;

                        double consumptionForThisPeriod = 0.0;

                        if (previousEntry != null && previousEntry.tanqueCheio != 0) {
                          consumptionForThisPeriod = currentEntry.calculateConsumption(
                            previousEntry,
                          );
                        }

                        return FuelCard(
                          entry: currentEntry,
                          consumptionForThisPeriod: consumptionForThisPeriod,
                        );
                      },
                    ),
            ),
          ],
        );
      }),

      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_fuelentry_list',
        onPressed: () => _showFuelForm(context),
        child: Icon(RemixIcons.gas_station_line, color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

void _showFuelForm(BuildContext context, [FuelEntry? fuel]) {
  Get.dialog(FuelForm(fuel: fuel), useSafeArea: true, barrierDismissible: true);
}

class FuelCard extends StatelessWidget {
  final FuelEntry entry;
  final double consumptionForThisPeriod;
  FuelCard({super.key, required this.entry, required this.consumptionForThisPeriod});

  final FuelListController controller = Get.find<FuelListController>();
  final UnitController unitController = Get.find<UnitController>();
  final CurrencyController currencyController = Get.find<CurrencyController>();

  Future<bool?> _deleteConfirmation(BuildContext context) async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: Text(context.tr(TranslationKeys.dialogDeleteTitle)),
        content: Text(context.tr(TranslationKeys.dialogDeleteContent)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(context.tr(TranslationKeys.dialogDeleteButtonCancel)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(context.tr(TranslationKeys.dialogDeleteButtonDelete)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final overallConsumption = controller.overallConsumption;
    final String formattedValue = controller.formatConsumption(overallConsumption.value);
    final String unitString = controller.getConsumptionUnitString();
    final isMiles = unitController.distanceUnit.value == DistanceUnit.miles;

    String getFuelType(String type) {
      return controller.fuelTypeMap[type] ?? context.tr(TranslationKeys.fuelTypeOther);
    }

    final String dateOnly = DateFormat('dd/MM/yyyy').format(entry.dataAbastecimento);
    String titleText = dateOnly;

    if (entry.posto != null && entry.posto.isNotEmpty) {
      titleText += ' - ${entry.posto}';
    }

    final String distanceUnitStr = controller.getDistanceUnitString();
    final double odometerDisplay = isMiles
        ? entry.quilometragem * controller.kmToMileFactor
        : entry.quilometragem.toDouble();
    final String consumptionDisplay = controller.formatConsumption(consumptionForThisPeriod);
    final String consumptionUnitStr = controller.getConsumptionUnitString();

    String typeText = entry.tipo;

    String odoAndLiters =
        '${context.tr(TranslationKeys.commonLabelsOdometer)}: ${odometerDisplay.toStringAsFixed(0)} $distanceUnitStr | '
        '${context.tr(TranslationKeys.commonLabelsLiters)}: ${entry.litros.toStringAsFixed(2)} L';

    final consumptionUnit =
        '${context.tr(TranslationKeys.consumptionCardsConsumptionPeriod)}: $consumptionDisplay $consumptionUnitStr';

    String subtitleText = '$typeText\n$odoAndLiters\n$consumptionUnit';

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(RemixIcons.delete_bin_line, color: Colors.white),
      ),
      confirmDismiss: (direction) => _deleteConfirmation(context),
      onDismissed: (direction) async {
        if (entry.id != null) {
          await controller.deleteEntry(entry.id!);
          Get.snackbar(
            context.tr(TranslationKeys.commonLabelsDeleteConfirmation),
            '',
            duration: const Duration(seconds: 2),
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.white,
          );
        }
      },
      child: Card(
        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          leading: Icon(
            entry.tanqueCheio == 1 ? RemixIcons.gas_station_fill : RemixIcons.gas_station_line,
            color: Theme.of(context).colorScheme.secondary,
          ),
          title: Text(
            titleText,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitleText),
          trailing: Obx(() {
            final currencySymbol = currencyController.currencySymbol.value;
            return Text(
              '$currencySymbol ${entry.totalPrice!.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }),
          onTap: () => _showFuelForm(context, entry),
        ),
      ),
    );
  }
}

class FuelForm extends StatefulWidget {
  final FuelEntry? fuel;
  const FuelForm({super.key, this.fuel});

  @override
  State<FuelForm> createState() => _FuelFormState();
}

class _FuelFormState extends State<FuelForm> {
  final FuelDb _db = FuelDb();
  final _formKey = GlobalKey<FormState>();

  late String tipoFuel = '';
  
  VehicleModel? selectedVeiculos;
  GasStationModel? selectedStations;

  late String veiculosName;
  late String stationName;
  late DateTime selectedDate;

  late bool tanqueCheio = false;
  late String comprovantePath;
  late List<VehicleModel> availableVeiculos = [];
  late List<GasStationModel> availableGasStations = [];

  late Map<String, String> serviceCombustivel;
  final FuelListController controller = Get.find<FuelListController>();
  final GasStationController stationController = Get.find<GasStationController>();
  final VehicleController vehicleController = Get.find<VehicleController>();
  late bool isEditing = false;
  late bool isLoading = true;
  final ImagePicker _picker = ImagePicker();

  void _initializeServiceCombustivel() {
    serviceCombustivel = {
      context.tr(TranslationKeys.fuelTypeGasolineComum): 'Gasolina Comum',
      context.tr(TranslationKeys.fuelTypeGasolineAditivada): 'Gasolina Aditivada',
      context.tr(TranslationKeys.fuelTypeEthanolAlcool): 'Etanol (Álcool)',
      context.tr(TranslationKeys.fuelTypeGasolinePremium): 'Gasoline Premium',
    };
    if (isEditing) {
      if (!serviceCombustivel.containsKey(widget.fuel!.tipo)) {
        serviceCombustivel[widget.fuel!.tipo] = 'OTHER';
      }
      tipoFuel = widget.fuel!.tipo;
    } else {
      tipoFuel = serviceCombustivel.keys.first;
    }
  }

  Future<void> loadVehicles() async {
    try {
      final vehicles = await _db.getVehicles();
      VehicleModel? initialVehicle;
      if (isEditing && widget.fuel != null) {
        initialVehicle = vehicles.firstWhereOrNull((v) => v.nickname == widget.fuel?.veiculo);
      }

      setState(() {
        availableVeiculos = vehicles;
        selectedVeiculos = initialVehicle ?? vehicles.firstWhereOrNull((v) => true);
      });
    } catch (e) {
      print('Erro ao carregar veículos do banco de dados: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os veículos.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadStations() async {
    try {
      final station = await _db.getStation();
      GasStationModel? initialStation;
      if (isEditing && widget.fuel != null) {
        initialStation = station.firstWhereOrNull((v) => v.nome == widget.fuel?.posto);
      }

      setState(() {
        availableGasStations = station;
        selectedStations = initialStation ?? station.firstWhereOrNull((v) => true);
      });
    } catch (e) {
      print('Erro ao carregar veículos do banco de dados: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os veículos.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeServiceCombustivel();
    loadVehicles();
    loadStations();

    final fuel = widget.fuel;
    tipoFuel = fuel?.tipo ?? '';

    stationName = fuel?.posto ?? 'Outro';
    stationController.loadGasStationPrices(stationName);

    veiculosName = fuel?.veiculo ?? 'Fit Prata';
    vehicleController.loadNameVehicles(veiculosName);

    final initialKM = fuel?.quilometragem ?? 0.0;
    controller.kmController = MoneyMaskedTextController(initialValue: initialKM);

    final initialLitros = fuel?.litros ?? 0.0;
    controller.litrosController = MoneyMaskedTextController(initialValue: initialLitros);

    final initialPrecoPorLitros = fuel?.pricePerLiter ?? 0.0;
    controller.pricePerLiterController = MoneyMaskedTextController(
      initialValue: initialPrecoPorLitros,
      leftSymbol: 'R\$ ',
    );

    final initialPrecoLitro = fuel?.totalPrice ?? 0.0;
    controller.totalPriceController = MoneyMaskedTextController(initialValue: initialPrecoLitro, leftSymbol: 'R\$ ');

    selectedDate = fuel?.dataAbastecimento ?? DateTime.now();
    tanqueCheio = fuel?.tanqueCheio ?? false;
    comprovantePath = fuel?.comprovantePath ?? '';
  }

  @override
  void dispose() {
    controller.kmController.dispose();
    controller.litrosController.dispose();
    controller.pricePerLiterController.dispose();
    controller.totalPriceController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final currentOdometer = controller.getOdometerValue();
      final litersValue = controller.getLitersValue();
      final vehicleNome = selectedVeiculos?.nickname;
      final stationName = selectedStations?.nome;

      if (!isEditing) {
        final lastOdometer = await _db.getLastOdometer();
        if (lastOdometer != null) {
          Get.snackbar(
            'Erro de Quilometragem',
            'A quilometragem atual (${controller.getOdometerValue()} Km) não pode ser menor que a última registrada (${lastOdometer.toStringAsFixed(2)} Km).',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
          return;
        }
      }

      final fuelId = widget.fuel?.id ?? const Uuid().v4();

      final newFuel = FuelEntry(
        id: fuelId,
        tipo: tipoFuel,
        dataAbastecimento: selectedDate,
        veiculo: vehicleNome!,
        posto: stationName!,
        quilometragem: controller.getOdometerValue()!,
        litros: controller.getLitersValue()!,
        pricePerLiter: controller.getPricePerLiterValue(),
        totalPrice: controller.getTotalPriceValue(),
        tanqueCheio: tanqueCheio,
        comprovantePath: comprovantePath,
      );

      try {
        print(newFuel.toMap());
        // await controller.saveFuel(newFuel);

        Get.snackbar(
          'Sucesso',
          'Abastecimento em "${newFuel.posto}" adicionado com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.back();
      } catch (e) {
        Get.snackbar(
          'Erro',
          'Falha ao salvar o abastecimento: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
        );

        Get.back();
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
      selectedDate = picked;
    }
  }

  void updateFuelType(String? newValue) {
    if (newValue != null) {
      tipoFuel = newValue;
    }
  }

  void updateGasStation(GasStationModel? newStation) {
    if (newStation != null) {
      setState(() {
        stationController.selectedGasStation = newStation;
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
          comprovantePath = pickedFile.path;

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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.fuel != null;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        isEditing
            ? context.tr(TranslationKeys.entryScreenUpdateAppBarTitle)
            : context.tr(TranslationKeys.entryScreenAddAppBarTitle),
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineSmall,
      ),
      content: SizedBox(
        width: Get.width * 0.9,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(RemixIcons.time_line, color: Theme.of(context).colorScheme.primary),
                  title: Text(
                    context.tr(TranslationKeys.entryScreenLabelDate),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(selectedDate),
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        RemixIcons.calendar_2_fill,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                  onTap: () => selectDate(context),
                ),

                const SizedBox(height: 20),
                if (controller.lastOdometer != null)
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
                            '${context.tr(TranslationKeys.entryScreenInfoLastOdometerPrefix)} ${controller.lastOdometer.toStringAsFixed(0)} km. ${context.tr(TranslationKeys.entryScreenInfoLastOdometerPrefix2)}',
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
                  controller: controller.kmController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: context.tr(TranslationKeys.entryScreenLabelOdometer),
                  ),
                  validator: (value) {
                    if (controller.getOdometerValue() == 0.0) {
                      return 'Informe a quilometragem atual.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: context.tr(TranslationKeys.entryScreenLabelFuelType),
                    border: OutlineInputBorder(),
                  ),
                  value: tipoFuel.isNotEmpty && serviceCombustivel.containsKey(tipoFuel)
                      ? tipoFuel
                      : null,
                  items: serviceCombustivel.keys.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(color: AppTheme.textGrey)),
                    );
                  }).toList(),
                  onChanged: updateFuelType,
                  validator: controller.validateFuelType,
                ),
                const SizedBox(height: 16),
                _buildValueField(
                  context,
                  controller.litrosController,
                  context.tr(TranslationKeys.entryScreenLabelLiters),
                  controller.validateLiters,
                ),
                const SizedBox(height: 16),
                _buildValueField(
                  context,
                  controller.pricePerLiterController,
                  context.tr(TranslationKeys.entryScreenLabelPricePerLiter),
                  controller.validatePricePerLiter,
                ),
                const SizedBox(height: 16),
                _buildValueField(
                  context,
                  controller.totalPriceController,
                  context.tr(TranslationKeys.entryScreenLabelTotalPrice),
                  controller.validateTotalPrice,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<VehicleModel>(
                  decoration: InputDecoration(
                    labelText: controller.tr(TranslationKeys.entryScreenLabelVeiculos),
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
                      return controller.tr(TranslationKeys.validationRequiredVeiculos);
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                DropdownButtonFormField<GasStationModel>(
                  decoration: InputDecoration(
                    labelText: controller.tr(TranslationKeys.entryScreenLabelGasStation),
                    border: OutlineInputBorder(),
                  ),
                  value: stationController.selectedGasStation,
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
                      return controller.tr(TranslationKeys.validationRequiredFuelType);
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                if (stationController.selectedGasStation != null && stationController.selectedGasStation!.id != -1)
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
                    child: stationController.isPriceLoading
                        ? const Center(child: LinearProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Detalhes do Posto: ${stationController.selectedGasStation!.nome} (${stationController.selectedGasStation!.brand})',
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
                              if (tipoFuel == 'Gasolina Comum')
                                _buildInfoRow(
                                  context,
                                  RemixIcons.oil_line,
                                  'Gasolina (R\$):',
                                  stationController.selectedGasStation!.priceGasolineComum.toStringAsFixed(2),
                                ),

                              _buildInfoRow(
                                context,
                                RemixIcons.oil_line,
                                'Etanol (R\$):',
                                stationController.selectedGasStation!.priceEthanol.toStringAsFixed(2),
                              ),
                              _buildServiceRow(
                                context,
                                RemixIcons.store_2_line,
                                'Loja de Conv.:',
                                stationController.selectedGasStation!.hasConvenientStore,
                              ),
                              _buildServiceRow(
                                context,
                                RemixIcons.time_line,
                                '24 Horas:',
                                stationController.selectedGasStation!.is24Hours,
                              ),
                            ],
                          ),
                  ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tanqueCheio ? RemixIcons.gas_station_fill : RemixIcons.gas_station_line,
                          color: tanqueCheio
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
                            color: tanqueCheio
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
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
                  ),
                  subtitle: comprovantePath != null
                      ? Text(
                          context.tr(
                            TranslationKeys.entryScreenReceiptPathPrefix,
                            parameters: {'name': comprovantePath.split('/').last},
                          ),
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
              ],
            ),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [],
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
