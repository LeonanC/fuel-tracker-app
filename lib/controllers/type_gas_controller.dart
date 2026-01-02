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
    await _db.insertGas(newGas);
    await loadGas();
  }

  void deleteGas(int id) async {
    await _db.deleteGas(id);
    await loadGas();

    Get.snackbar('Excluído', 'Gas removido com sucesso.', snackPosition: SnackPosition.BOTTOM);
  }
}


