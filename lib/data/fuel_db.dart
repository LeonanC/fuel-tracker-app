import 'package:fuel_tracker_app/data/database_helper.dart';
import 'package:fuel_tracker_app/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/models/gas_station_model.dart';
import 'package:fuel_tracker_app/models/maintenance_entry_model.dart';
import 'package:fuel_tracker_app/models/services_type_model.dart';
import 'package:fuel_tracker_app/models/type_gas_model.dart';
import 'package:fuel_tracker_app/models/vehicle_model.dart';
import 'package:fuel_tracker_app/services/application.dart';
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

  String get dbname => dbName;
  int get dbversion => dbVersion;

  Future<List<FuelEntryModel>> getFuel() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        f.*,
        c.nome as fuel_name,
        v.nickname as vehicle_name,
        p.nome_posto as station_name
        FROM fuel_entries f
        LEFT JOIN vehicles v ON f.fk_vehicle = v.pk_vehicle
        LEFT JOIN fuel_types c ON f.fk_type_fuel = c.pk_type_fuel        
        LEFT JOIN gas_stations p ON f.fk_station = p.pk_station
        ORDER BY f.odometer_km DESC, f.entry_date DESC
    ''');

    return List.generate(maps.length, (i) {
      return FuelEntryModel.fromMap(maps[i]);
    });
  }

  Future<List<GasStationModel>> getStation() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query('gas_stations', orderBy: 'pk_station DESC');

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

  Future<double> getLastOdometer() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT MAX(odometer_km) as last_km FROM fuel_entries');
    
    if(maps.isNotEmpty && maps.first['last_km'] != null){
      return (maps.first['last_km'] as num).toDouble();
    }
    return 0.0;
  }

  Future<List<FuelEntryModel>> getLastTwoEntries() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'fuel_entries',
      orderBy: 'odometer_km DESC',
      limit: 2,
    );
    return maps.map((map) => FuelEntryModel.fromMap(map)).toList();
  }

  Future<bool> updateFuelEntrie(Map<String, dynamic> values) async {
    if (values['pk_fuel'] == null) return false;
    final db = await getDb();
    int rows = await db.update('fuel_entries', values, where: 'pk_fuel = ?', whereArgs: [values['pk_fuel']]);
    return (rows != 0);
  }

  Future<bool> deleteFuelEntrie(int id) async {
    final db = await getDb();
    int rows = await db.delete('fuel_entries', where: 'pk_fuel = ?', whereArgs: [id]);
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

  Future<int> deleteMaintenance(int id) async {
    final db = await getDb();
    return await db.delete('manutencao', where: 'pk_manutencao = ?', whereArgs: [id]);
  }

  Future<int> insertStation(GasStationModel station) async {
    final db = await getDb();
    return await db.insert(
      'gas_stations',
      station.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteStation(int id) async {
    final db = await getDb();
    return await db.delete('gas_stations', where: 'pk_station = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllMaintenanceEntries() async {
    final db = await getDb();
    return await db.query('manutencao', orderBy: 'data_servico DESC, quilometragem DESC');
  }

  Future<List<VehicleModel>> getVehicles() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        v.*,
        t.nome as fuel_name
      FROM vehicles v
      LEFT JOIN fuel_types t ON v.fk_type_fuel = t.pk_type_fuel
    ''');

    return List.generate(maps.length, (i) => VehicleModel.fromMap(maps[i]));
  }

  Future<int> insertVehicles(VehicleModel vehicle) async {
    final db = await getDb();
    return await db.insert(
      'vehicles',
      vehicle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteVehicle(int id) async {
    final db = await getDb();
    return await db.delete('vehicles', where: 'pk_vehicle = ?', whereArgs: [id]);
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

  Future<int> deleteGas(int id) async {
    final db = await getDb();
    return await db.delete('fuel_types', where: 'pk_fuel = ?', whereArgs: [id]);
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

  Future<int> deleteServices(int id) async {
    final db = await getDb();
    return await db.delete('service_types', where: 'pk_service = ?', whereArgs: [id]);
  }
}
