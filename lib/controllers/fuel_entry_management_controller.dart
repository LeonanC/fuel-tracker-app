import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/controllers/gas_station_controller.dart';
import 'package:fuel_tracker_app/controllers/language_controller.dart';
import 'package:fuel_tracker_app/controllers/vehicle_controller.dart';
import 'package:fuel_tracker_app/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/models/gas_station_model.dart';
import 'package:fuel_tracker_app/models/vehicle_model.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class FuelEntryManagementController extends GetxController {
  final FuelListController _controller = Get.find<FuelListController>();
  final VehicleController _vehicleController = Get.find<VehicleController>();
  final GasStationController _gasStationController = Get.find<GasStationController>();
  final LanguageController languageController = Get.find<LanguageController>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final tipoFuel = ''.obs;
  final selectedVeiculos = Rxn<VehicleModel>();
  final selectedGasStation = Rxn<GasStationModel>();
  final selectedDate = DateTime.now().obs;
  final tanqueCheio = true.obs;
  final comprovantePath = Rxn<String>();
  final availableVeiculos = <VehicleModel>[].obs;
  final availableGasStations = <GasStationModel>[].obs;

  late TextEditingController kmController;
  late MoneyMaskedTextController litrosController;
  late MoneyMaskedTextController pricePerLiterController;
  late MoneyMaskedTextController totalPriceController;

  late Map<String, String> serviceCombustivel;

  @override
  void onInit() {
    super.onInit();
    _loadGasStations();
  }

  Future<void> _loadGasStations() async {
    final vehicles = _vehicleController.vehicles.toList();
    availableVeiculos.value = vehicles;
    final stations = _gasStationController.stations.toList();
    availableGasStations.value = stations;

    //   final vehicle = vehicles.firstWhereOrNull((v) => v.nickname == entry!.veiculo);
    //   final station = stations.firstWhereOrNull((s) => s.nome == entry!.posto);
    //   if (station != null || vehicle != null) {
    //     selectedVeiculos.value = vehicle;
    //     selectedGasStation.value = station;
    // } else if (stations.isNotEmpty) {
    //   selectedVeiculos.value = vehicles.first;
    //   selectedGasStation.value = stations.first;
    // } else {
    //   selectedVeiculos.value = null;
    //   selectedGasStation.value = null;
    // }
  }

  

  
}
