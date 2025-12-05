import 'package:fuel_tracker_app/data/fuel_db.dart';
import 'package:fuel_tracker_app/models/vehicle_model.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class VehicleController extends GetxController {
  var vehicles = <VehicleModel>[].obs;

  final FuelDb _db = FuelDb();

  @override
  void onInit() {
    loadVehicles();
    super.onInit();
  }

  Future<void> loadVehicles() async {
    try {
      final List<VehicleModel> loadedVehicles = await _db.getVehicles();
      vehicles.assignAll(loadedVehicles);
    } catch (e) {
      print('Erro ao carregar veículos do banco de dados: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os veículos.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadNameVehicles(String value) async {
    try {
      final List<VehicleModel> loadedVehicles = await _db.getNamesPerVehicles(value);
      vehicles.assignAll(loadedVehicles);
    } catch (e) {
      print('Erro ao carregar veículos do banco de dados: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os veículos.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void saveVehicle(VehicleModel newVehicle) async {
    final bool isEditing = newVehicle.id.isNotEmpty;

    final vehicleToSave = newVehicle.id.isEmpty
        ? newVehicle.copyWith(id: const Uuid().v4(), createdAt: DateTime.now())
        : newVehicle;

    await _db.insertVehicles(vehicleToSave);
    await loadVehicles();
    //final isNew = vehicles.indexWhere((v) => v.id == vehicleToSave.id) == -1;

    if (!isEditing) {
      Get.snackbar(
        'Sucesso',
        'Veículo adicionado: ${vehicleToSave.nickname}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Sucesso',
        'Veículo atualizado: ${vehicleToSave.nickname}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void deleteVehicle(String id) async {
    await _db.deleteVehicle(id);
    await loadVehicles();
    
    Get.snackbar('Excluído', 'Veículo removido com sucesso.', snackPosition: SnackPosition.BOTTOM);
  }
}

extension VehicleCopyWith on VehicleModel {
  VehicleModel copyWith({
    String? id,
    String? nickname,
    String? make,
    String? model,
    String? fuelType,
    int? year,
    double? initialOdometer,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      make: make ?? this.make,
      model: model ?? this.model,
      fuelType: fuelType ?? this.fuelType,
      year: year ?? this.year,
      initialOdometer: initialOdometer ?? this.initialOdometer,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
