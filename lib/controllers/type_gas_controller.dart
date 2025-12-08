import 'package:fuel_tracker_app/data/fuel_db.dart';
import 'package:fuel_tracker_app/models/type_gas_model.dart';
import 'package:fuel_tracker_app/models/vehicle_model.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class TypeGasController extends GetxController {
  var typeGas = <TypeGasModel>[].obs;

  final FuelDb _db = FuelDb();

  TypeGasModel? selectedTypeGas;
  String gasName = '';

  @override
  void onInit() {
    loadGas();
    super.onInit();
  }

  Future<void> loadGas() async {
    try {
      final List<TypeGasModel> loadedGas = await _db.getGas();
      typeGas.assignAll(loadedGas);
    } catch (e) {
      print('Erro ao carregar gas do banco de dados: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os veículos.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadNameVehicles(String value) async {
    if (value.isEmpty) {
      gasName = value;
      selectedTypeGas = null;
      return;
    }
    gasName = value;

    try {
      final List<TypeGasModel> results = await _db.getNamesPerGas(value);
      typeGas.assignAll(results);
    } catch (e) {
      print('Erro ao carregar gas do banco de dados: $e');
      selectedTypeGas = null;
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os gas.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void saveGas(TypeGasModel newGas) async {
    final bool isEditing = newGas.id.isNotEmpty;

    final gasToSave = newGas.id.isEmpty
        ? newGas.copyWith(id: const Uuid().v4())
        : newGas;

    await _db.insertGas(gasToSave);
    await loadGas();

    if (!isEditing) {
      Get.snackbar(
        'Sucesso',
        'Gas adicionado: ${gasToSave.nome}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Sucesso',
        'Gas atualizado: ${gasToSave.nome}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void deleteGas(String id) async {
    await _db.deleteGas(id);
    await loadGas();

    Get.snackbar('Excluído', 'Gas removido com sucesso.', snackPosition: SnackPosition.BOTTOM);
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
