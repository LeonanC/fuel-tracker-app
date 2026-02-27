// import 'package:flutter/material.dart';
// import 'package:fuel_tracker_app/modules/fuel/controllers/gas_station_controller.dart';
// import 'package:fuel_tracker_app/modules/fuel/controllers/type_gas_controller.dart';
// import 'package:fuel_tracker_app/modules/fuel/controllers/vehicle_controller.dart';
// import 'package:fuel_tracker_app/data/fuel_db.dart';
// import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
// import 'package:get/get.dart';

// class FuelRepository {
//   final FuelDb _db = FuelDb();
//   final Rx<DateTime?> _startDate = Rx<DateTime?>(null);
//   final Rx<DateTime?> _endDate = Rx<DateTime?>(null);

//   DateTime? get startDate => _startDate.value;
//   DateTime? get endDate => _endDate.value;

//   bool get isDateFilterActive =>
//       _startDate.value != null && _endDate.value != null;

//   final GasStationController gasStationController =
//       Get.find<GasStationController>();
//   final TypeGasController typeGasController = Get.find<TypeGasController>();
//   final VehicleController vehicleController = Get.find<VehicleController>();

//   Future<double> calculateFuelConsumption() async {
//     try {
//       final List<FuelEntryModel> entries = await _db.getLastTwoEntries();

//       if (entries.length < 2) {
//         return 0.0;
//       }

//       final latest = entries[0];
//       final previous = entries[1];

//       final distanceKm = latest.odometerKm - previous.odometerKm;
//       final volumeLiters = latest.volumeLiters;

//       if (distanceKm <= 0 || volumeLiters <= 0) {
//         return 0.0;
//       }

//       return distanceKm / volumeLiters;
//     } catch (e) {
//       debugPrint("Erro no cálculo de consumo: $e");
//       return 0.0;
//     }
//   }

//   List<String> get availableVehicleNames {
//     final List<String> names = vehicleController.vehicles
//         .map((vehicle) => vehicle.nickname)
//         .toList();
//     Set<String> allVehicles = {...names};

//     allVehicles.removeWhere((name) => name.isEmpty);

//     return allVehicles.toList();
//   }

//   List<String> get availableTypeGasNames {
//     final List<String> names = typeGasController.typeGas
//         .map((gas) => gas.nome)
//         .toList();
//     Set<String> allGas = {...names};
//     allGas.removeWhere((name) => name.isEmpty);
//     return allGas.toList();
//   }

//   List<String> get availableGasStationNames {
//     final List<String> names = gasStationController.stations
//         .map((station) => station.nome)
//         .toList();

//     Set<String> allStations = {...names};

//     allStations.removeWhere((name) => name.isEmpty);

//     return allStations.toList();
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
//   }

//   String get formattedDateRange {
//     if (isDateFilterActive) {
//       return '${_formatDate(_startDate.value!)} - ${_formatDate(_endDate.value!)}';
//     }
//     return '';
//   }

//   void applyDateFilter(DateTime start, DateTime end) {
//     _startDate.value = start;
//     _endDate.value = end;
//   }

//   void clearDateFilter() {
//     _startDate.value = null;
//     _endDate.value = null;
//   }
// }
