import 'package:fuel_tracker_app/data/models/gas_station_model.dart';
import 'package:fuel_tracker_app/data/models/services_type_model.dart';
import 'package:fuel_tracker_app/data/models/type_gas_model.dart';
import 'package:fuel_tracker_app/data/models/vehicle_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LookupController extends GetxController {
  final _supabase = Supabase.instance.client;

  final tipoDrop = <TypeGasModel>[].obs;
  final veiculosDrop = <VehicleModel>[].obs;
  final postosDrop = <GasStationModel>[].obs;
  final servicosDrop = <ServicesTypeModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchLookups();
  }

  void fetchLookups() {
    _supabase.from('tipo_combustivel').stream(primaryKey: ['id']).listen((
      data,
    ) {
      tipoDrop.value = data.map((map) => TypeGasModel.fromMap(map)).toList();
    });

    _supabase.from('veiculos').stream(primaryKey: ['id']).listen((data) {
      veiculosDrop.value = data.map((map) => VehicleModel.fromMap(map)).toList();
    });

    _supabase.from('postos').stream(primaryKey: ['id']).listen((data) {
      postosDrop.value = data
          .map((map) => GasStationModel.fromMap(map))
          .toList();
    });

    _supabase.from('service_type').stream(primaryKey: ['id']).listen((data) {
      servicosDrop.value = data
          .map((map) => ServicesTypeModel.fromMap(map))
          .toList();
    });
  }
}
