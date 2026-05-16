import 'package:fuel_tracker_app/data/models/vehicle_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LookupController extends GetxController {
  final _supabase = Supabase.instance.client;

  final veiculosDrop = <VehicleModel>[].obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLookups();
  }

  Future<void> fetchLookups() async {
    final result = await Future.wait([
    _supabase.from('veiculos').select(),
    ]);

    veiculosDrop.value = (result[0] as List)
    .map((v) => VehicleModel.fromMap(v)).toList();
  }
}
