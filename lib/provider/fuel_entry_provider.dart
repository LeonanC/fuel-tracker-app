import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/fuelentry_db.dart';
import 'package:fuel_tracker_app/models/fuelentry_model.dart';
import 'package:intl/intl.dart';

class FuelEntryProvider with ChangeNotifier {
  final FuelEntryDb _db = FuelEntryDb();
  List<FuelEntry> _fuelEntries = [];
  String _errorMessage = '';
  bool _isLoading = false;

  double? _lastOdometer;
  double _overallConsumption = 0.0;

  List<double> _periodConsumptions = [];

  List<FuelEntry> get fuelEntries => _fuelEntries;
  bool get isLoading => _isLoading;
  double? get lastOdometer => _lastOdometer;
  String get errorMessage => _errorMessage;
  double get overallConsumption => _overallConsumption;
  List<double> get periodConsumptions => _periodConsumptions;

  FuelEntryProvider() {
    loadFuelEntries();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> loadFuelEntries() async {
    _isLoading = true;
    notifyListeners();

    final List<Map<String, dynamic>> maps = await _db.getAllFuelEntries();
    _fuelEntries = maps.map((map) => FuelEntry.fromMap(map)).toList();
    _lastOdometer = await _db.getLastOdometer();
    _overallConsumption = calculateOverallAverageConsumption();

    _fuelEntries.sort((a, b) => b.dataAbastecimento.compareTo(a.dataAbastecimento));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> insertEntry(FuelEntry entry) async {
    await _db.insertFuelEntrie(entry.toMap());
    await loadFuelEntries();
  }

  Future<void> updateEntry(FuelEntry entry) async {
   if(entry.id == null) return;
   await _db.updateFuelEntrie(entry.toMap());
   await loadFuelEntries();
  }

  Future<void> deleteEntry(int id) async {
    if(await _db.deleteFuelEntrie(id)){
      _fuelEntries.removeWhere((entry) => entry.id == id);
      notifyListeners();
    }
  }

  double calculateOverallAverageConsumption() {
    if (_fuelEntries.length < 2) {
      _periodConsumptions = [];
      return 0.0;
    }

    double totalDistance = 0.0;
    double totalLiters = 0.0;
    _periodConsumptions = [];

    final List<FuelEntry> sortedEntries = List<FuelEntry>.from(_fuelEntries);
    sortedEntries.sort((a, b) {
      return a.quilometragem.compareTo(b.quilometragem);
    });

    for (int i = 1; i < sortedEntries.length; i++) {
      final FuelEntry currentEntry = sortedEntries[i];
      final FuelEntry previousEntry = sortedEntries[i - 1];

      final double currentOdometer = currentEntry.quilometragem;
      final double previousOdometer = previousEntry.quilometragem;
      final double currentLiters = currentEntry.litros;

      final double distance = currentOdometer - previousOdometer;

      double consumptionForThisPeriod = 0.0;

      if (distance > 0 && currentLiters > 0) {
        consumptionForThisPeriod = distance / currentLiters;
      }

      _periodConsumptions.add(consumptionForThisPeriod);

      totalDistance += distance;
      totalLiters += currentLiters;
    }

    if (totalLiters <= 0) return 0.0;

    return totalDistance / totalLiters;
  }

  Future<String> backupEntries() async {
    if (_fuelEntries.isEmpty) {
      await loadFuelEntries();
    }
    if (_fuelEntries.isEmpty) {
      return 'Nenhum registro para backup.';
    }

    final StringBuffer sb = StringBuffer('Data,Hodometro,Litros,PrecoPorLitro,PrecoTotal,Posto,TipoCombustivel,TanqueCheio\n');

    return sb.toString();
  }

  Future<List<FuelEntry>> getAllEntriesForExport() async {
    if (_fuelEntries.isEmpty && !_isLoading) {
      await loadFuelEntries();
    }

    final List<Map> sortedMaps = List.from(_fuelEntries);
    sortedMaps.sort((a, b) => b['data_abastecimento'].compareTo(a['data_abastecimento']));

    final List<FuelEntry> entries = sortedMaps.map((map) {
      return FuelEntry.fromMap(map as Map<String, dynamic>);
    }).toList();

    await Future.delayed(const Duration(milliseconds: 10));

    return entries;
  }

  Future<void> clearAllData() async {
    // _setLoading(true);
    // _setError('');
    // try {
    //   final int deletedCount = await _dbModel.deleteAll();
    //   await loadFuelEntries();
    //   debugPrint('Total de $deletedCount registros apagados.');
    // } catch (e) {
    //   _setError('Falha ao limpar todos os dados: $e');
    // } finally {
    //   _setLoading(false);
    // }
  }
}
