import 'package:fuel_tracker_app/data/database_helper.dart';
import 'package:fuel_tracker_app/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/models/gas_station_model.dart';
import 'package:fuel_tracker_app/models/maintenance_entry_model.dart';
import 'package:fuel_tracker_app/models/services_type_model.dart';
import 'package:fuel_tracker_app/models/type_gas_model.dart';
import 'package:fuel_tracker_app/models/vehicle_model.dart';
import 'package:sqflite/sqflite.dart';

class FuelDb extends DatabaseHelper {
  static FuelDb? _this;
  factory FuelDb() {
    if (_this == null) {
      _this = FuelDb.instanceHome();
    }
    return _this!;
  }

  FuelDb.instanceHome() : super();

  String get dbname => DatabaseHelper.dbName;
  int get dbversion => DatabaseHelper.dbVersion;

  Future<List<Map<String, dynamic>>> getAllFuelEntries() async {
    final db = await getDb();
    return await db.query('fuel_entries', orderBy: 'quilometragem DESC, data_abastecimento DESC');
  }

  Future<List<GasStationModel>> getStation() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query('gas_stations', orderBy: 'id DESC');

    return List.generate(maps.length, (i) {
      return GasStationModel.fromMap(maps[i]);
    });
  }

  Future<List<VehicleModel>> getNamesPerVehicles(String vehicleName) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'vehicles',
      where: 'nickname = ?',
      whereArgs: [vehicleName],
    );

    return maps.map((map) => VehicleModel.fromMap(map)).toList();
  }

  Future<List<GasStationModel>> getPricesForStation(String stationName) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'gas_stations',
      where: 'nome = ?',
      whereArgs: [stationName],
    );

    return maps.map((map) => GasStationModel.fromMap(map)).toList();
  }

  @override
  Future<double?> getLastOdometer() async {
    final db = await getDb();
    List<Map<String, dynamic>> items = await db.query(
      'fuel_entries',
      columns: ['quilometragem'],
      orderBy: 'data_abastecimento DESC',
      limit: 1,
    );
    if (items.isNotEmpty && items.first['quilometragem'] != null) {
      return (items.first['quilometragem'] as num).toDouble();
    }
    return null;
  }

  Future<int> insertFuel(FuelEntry entry) async {
    final db = await getDb();
    return await db.insert(
      'fuel_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> updateFuelEntrie(Map<String, dynamic> values) async {
    if (values['id'] == null) return false;
    final db = await getDb();
    int rows = await db.update('fuel_entries', values, where: 'id = ?', whereArgs: [values['id']]);
    return (rows != 0);
  }

  Future<bool> deleteFuelEntrie(String id) async {
    final db = await getDb();
    int rows = await db.delete('fuel_entries', where: 'id = ?', whereArgs: [id]);
    return (rows != 0);
  }

  Future<int> deleteAll() async {
    final db = await getDb();
    return await db.delete('fuel_entries');
  }

  Future<int> insertMaintenance(MaintenanceEntry maintenance) async {
    final db = await getDb();
    return await db.insert(
      'manutencao',
      maintenance.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteMaintenance(String id) async {
    final db = await getDb();
    return await db.delete('manutencao', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertStation(GasStationModel station) async {
    final db = await getDb();
    return await db.insert(
      'gas_stations',
      station.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteStation(String id) async {
    final db = await getDb();
    return await db.delete('gas_stations', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllMaintenanceEntries() async {
    final db = await getDb();
    return await db.query('manutencao', orderBy: 'data_servico DESC, quilometragem DESC');
  }

  Future<List<VehicleModel>> getVehicles() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'vehicles',
      orderBy: 'year DESC, initial_odometer DESC, created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return VehicleModel.fromMap(maps[i]);
    });
  }

  Future<int> insertVehicles(VehicleModel vehicle) async {
    final db = await getDb();
    return await db.insert(
      'vehicles',
      vehicle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteVehicle(String id) async {
    final db = await getDb();
    return await db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TypeGasModel>> getGas() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query('fuel_types', orderBy: 'abbr ASC');

    return List.generate(maps.length, (i) {
      return TypeGasModel.fromMap(maps[i]);
    });
  }

  Future<int> insertGas(TypeGasModel typeGas) async {
    final db = await getDb();
    return await db.insert(
      'fuel_types',
      typeGas.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteGas(String id) async {
    final db = await getDb();
    return await db.delete('fuel_types', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TypeGasModel>> getNamesPerGas(String gasName) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'fuel_types',
      where: 'nome = ?',
      whereArgs: [gasName],
    );

    return maps.map((map) => TypeGasModel.fromMap(map)).toList();
  }

  Future<List<ServicesTypeModel>> getServices() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query('service_types', orderBy: 'abbr ASC');

    return List.generate(maps.length, (i) {
      return ServicesTypeModel.fromMap(maps[i]);
    });
  }

  Future<int> insertServices(ServicesTypeModel serviceType) async {
    final db = await getDb();
    return await db.insert(
      'service_types',
      serviceType.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteServices(String id) async {
    final db = await getDb();
    return await db.delete('service_types', where: 'id = ?', whereArgs: [id]);
  }
}
