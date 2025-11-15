import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/fuelentry_db.dart';
import 'package:fuel_tracker_app/models/gas_station_model.dart';

class GasStationProvider with ChangeNotifier {
  final FuelEntryDb _db = FuelEntryDb();
  List<GasStationModel> _postos = [];

  List<GasStationModel> get postos => _postos;

  Future<int> insertGasStation(GasStationModel station) async {
    final db = await _db.getDb();
    return await db.insert('gas_stations', station.toMap());
  } 

  Future<List<GasStationModel>> getAllGasStation() async {
    final db = await _db.getDb();
    final List<Map<String, dynamic>> maps = await db.query('gas_stations');
    return maps.map((map) => GasStationModel.fromMap(map)).toList();
  }

  Future<void> loadGasStation() async {
    notifyListeners();
    final List<Map<String, dynamic>> maps = await _db.getAllGasStation();
    _postos = maps.map((map) => GasStationModel.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> saveGasStation(GasStationModel station) async {
    await _db.insertStation(station.toMap());
    await loadGasStation();
  }

  Future<void> updateGasStation(GasStationModel station) async {
    if(station.id == null) return;
    await _db.updateStation(station.toMap());
    await loadGasStation();
  }

  Future<void> deleteGasStation(int id) async {
    if(await _db.deleteStation(id)){
      _postos.removeWhere((station) => station.id == id);
      notifyListeners();
    }
  }

  Future<List<GasStationModel>> searchGasStationsByName(String query) async {
    final db = await _db.getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'gas_stations',
      where: 'nome LIKE ?',
      whereArgs: ['%$query%'],
    );
    return maps.map((map) => GasStationModel.fromMap(map)).toList();
  }

  Future<int> clearAllStations() async {
    final db = await _db.getDb();
    return await db.delete('gas_stations');
  }
}