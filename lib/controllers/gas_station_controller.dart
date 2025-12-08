import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/controllers/language_controller.dart';
import 'package:fuel_tracker_app/data/fuel_db.dart';
import 'package:fuel_tracker_app/models/gas_station_model.dart';
import 'package:fuel_tracker_app/services/gas_station_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class GasStationController extends GetxController {
  var stations = <GasStationModel>[].obs;
  final FuelDb _db = FuelDb();
  final GasStationService _dbService = GasStationService();

  final currencyController = Get.find<CurrencyController>();

  GasStationModel? selectedGasStation;
  String gasStationName = '';
  bool isPriceLoading = true;

  @override
  void onInit(){
    loadStations();
    super.onInit();
  }

  Future<void> loadStations() async {
    try {
      final List<GasStationModel> loadedStations = await _db.getStation();
      stations.assignAll(loadedStations);
    } catch (e) {
      print('Erro ao carregar postos de gasolinas do banco de dados: $e');
      Get.snackbar('Erro', 'Falha ao carregar postos: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> loadGasStationPrices(String value) async {
    if (value.isEmpty) {
        gasStationName = value;
        selectedGasStation = null;
        isPriceLoading = false;
      return;
    }

      isPriceLoading = true;
      gasStationName = value;

    try {
      final List<GasStationModel> results = await _db.getPricesForStation(value);
      stations.assignAll(results);
    } catch (e) {
      print('❌ Erro ao carregar preços do posto: $e');
      selectedGasStation = null;
    } finally {
        isPriceLoading = false;
    }
  }

  Future<List<GasStationModel>> searchStations(String query, {bool returnData = false}) async {
    try {
      final List<GasStationModel> stations = await _dbService.searchStationsByName(query);
      if (returnData) {
        return stations;
      } else {
        stations.clear();
        stations.assignAll(stations);
        return [];
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao buscar postos: $e');
      throw Exception('Falha ao buscar postos: $e');
    }
  }

  void saveStation(GasStationModel newStation) async {
    final bool isEditing = newStation.id.isNotEmpty;
    
    final stationToSave = newStation.id.isEmpty
        ? newStation.copyWith(id: const Uuid().v4())
        : newStation;

    await _db.insertStation(newStation);
    await loadStations();

    if (!isEditing) {
      Get.snackbar(
        'Sucesso',
        'Posto adicionado: ${stationToSave.nome}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Sucesso',
        'Posto atualizado: ${stationToSave.nome}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void deleteGasStation(String id) async {
    await _db.deleteStation(id);
    await loadStations();
    Get.snackbar('Excluído', 'Posto removido com sucesso.', snackPosition: SnackPosition.BOTTOM);
  }
}
