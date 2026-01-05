import 'package:fuel_tracker_app/data/database_helper.dart';
import 'package:fuel_tracker_app/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/models/gas_station_model.dart';
import 'package:fuel_tracker_app/models/maintenance_entry_model.dart';
import 'package:fuel_tracker_app/models/services_type_model.dart';
import 'package:fuel_tracker_app/models/type_gas_model.dart';
import 'package:fuel_tracker_app/models/vehicle_model.dart';
import 'package:fuel_tracker_app/services/application.dart';
import 'package:sqflite/sqflite.dart';

class FuelDb {
  static final FuelDb instance = FuelDb._internal();
  factory FuelDb() => instance;

  FuelDb._internal();

  String get dbname => dbName;
  int get dbversion => dbVersion;

  Future<Database> get db async => await DatabaseHelper.instance.database;

  Future<List<FuelEntryModel>> getFuel() async {
    final d = await db;
    final List<Map<String, dynamic>> maps = await d.rawQuery('''
      SELECT
        f.*,
        c.nome as fuel_name,
        v.nickname as vehicle_name,
        p.nome_posto as station_name,
        v.plate as vehicle_plate,
        v.city as vehicle_city,
        v.tank_capacity as vehicle_tank
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
    final d = await db;
    final List<Map<String, dynamic>> maps = await d.query(
      'gas_stations',
      orderBy: 'pk_station DESC',
    );

    return List.generate(maps.length, (i) {
      return GasStationModel.fromMap(maps[i]);
    });
  }

  Future<List<VehicleModel>> getNamesPerVehicles(String vehicleName) async {
    final d = await db;
    final List<Map<String, dynamic>> maps = await d.query(
      'vehicles',
      where: 'nickname = ?',
      whereArgs: [vehicleName],
    );

    return maps.map((map) => VehicleModel.fromMap(map)).toList();
  }

  Future<List<GasStationModel>> getPricesForStation(String stationName) async {
    final d = await db;
    final List<Map<String, dynamic>> maps = await d.query(
      'gas_stations',
      where: 'nome = ?',
      whereArgs: [stationName],
    );

    return maps.map((map) => GasStationModel.fromMap(map)).toList();
  }

  Future<double> getLastOdometer() async {
    final d = await db;
    final List<Map<String, dynamic>> maps = await d.rawQuery(
      'SELECT MAX(odometer_km) as last_km FROM fuel_entries',
    );

    if (maps.isNotEmpty && maps.first['last_km'] != null) {
      return (maps.first['last_km'] as num).toDouble();
    }
    return 0.0;
  }

  Future<List<FuelEntryModel>> getLastTwoEntries() async {
    final d = await db;
    final List<Map<String, dynamic>> maps = await d.query(
      'fuel_entries',
      orderBy: 'odometer_km DESC',
      limit: 2,
    );
    return maps.map((map) => FuelEntryModel.fromMap(map)).toList();
  }

  Future<void> insertFuel(Map<String, dynamic> data) async {
    final d = await db;
    if (data['pk_fuel'] == null) {
      await d.insert('fuel_entries', data);
    } else {
      await d.update('fuel_entries', data, where: 'pk_fuel = ?', whereArgs: [data['pk_fuel']]);
    }
  }

  Future<void> saveVehicle(Map<String, dynamic> data) async {
    final d = await db;
    if (data['pk_vehicle'] == null) {
      await d.insert('vehicles', data);
    } else {
      await d.update('vehicles', data, where: 'pk_vehicle = ?', whereArgs: [data['pk_vehicle']]);
    }
  }

  Future<bool> updateFuelEntrie(Map<String, dynamic> values) async {
    if (values['pk_fuel'] == null) return false;
    final d = await db;
    int rows = await d.update(
      'fuel_entries',
      values,
      where: 'pk_fuel = ?',
      whereArgs: [values['pk_fuel']],
    );
    return (rows != 0);
  }

  Future<bool> deleteFuelEntrie(int id) async {
    final d = await db;
    int rows = await d.delete('fuel_entries', where: 'pk_fuel = ?', whereArgs: [id]);
    return (rows != 0);
  }

  Future<int> deleteAll() async {
    final d = await db;
    return await d.delete('fuel_entries');
  }

  Future<int> insertMaintenance(MaintenanceEntry maintenance) async {
    final d = await db;
    return await d.insert(
      'manutencao',
      maintenance.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteMaintenance(int id) async {
    final d = await db;
    return await d.delete('manutencao', where: 'pk_manutencao = ?', whereArgs: [id]);
  }

  Future<List<GasStationModel>> getStations({String? query}) async {
    final d = await db;
    String? whereClause;
    List<dynamic>? whereArgs;

    if (query != null && query.isNotEmpty) {
      whereClause = 'nome_posto LIKE ? OR brand LIKE ?';
      whereArgs = ['%$query%', '%$query%'];
    }

    final result = await d.query(
      'gas_stations',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'nome_posto ASC',
    );

    return result.map((json) => GasStationModel.fromMap(json)).toList();
  }

  Future<int> insertStation(GasStationModel station) async {
    final d = await db;
    return await d.insert(
      'gas_stations',
      station.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteStation(int id) async {
    final d = await db;
    return await d.delete('gas_stations', where: 'pk_station = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllMaintenanceEntries() async {
    final d = await db;
    return await d.query('manutencao', orderBy: 'data_servico DESC, quilometragem DESC');
  }

  Future<List<VehicleModel>> getVehicles() async {
    final d = await db;
    final List<Map<String, dynamic>> maps = await d.rawQuery('''
      SELECT
        v.*,
        t.nome as fuel_name
      FROM vehicles v
      LEFT JOIN fuel_types t ON v.fk_type_fuel = t.pk_type_fuel
    ''');

    return List.generate(maps.length, (i) => VehicleModel.fromMap(maps[i]));
  }

  Future<int> deleteVehicle(int id) async {
    final d = await db;
    return await d.delete('vehicles', where: 'pk_vehicle = ?', whereArgs: [id]);
  }

  Future<List<TypeGasModel>> getGas() async {
    final d = await db;
    final List<Map<String, dynamic>> maps = await d.query('fuel_types', orderBy: 'abbr ASC');

    return List.generate(maps.length, (i) {
      return TypeGasModel.fromMap(maps[i]);
    });
  }

  Future<int> insertGas(TypeGasModel typeGas) async {
    final d = await db;
    return await d.insert(
      'fuel_types',
      typeGas.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteGas(int id) async {
    final d = await db;
    return await d.delete('fuel_types', where: 'pk_fuel = ?', whereArgs: [id]);
  }

  Future<List<TypeGasModel>> getNamesPerGas(String gasName) async {
    final d = await db;
    final List<Map<String, dynamic>> maps = await d.query(
      'fuel_types',
      where: 'nome = ?',
      whereArgs: [gasName],
    );

    return maps.map((map) => TypeGasModel.fromMap(map)).toList();
  }

  Future<List<ServicesTypeModel>> getServices() async {
    final d = await db;
    final List<Map<String, dynamic>> maps = await d.query('service_types', orderBy: 'abbr ASC');

    return List.generate(maps.length, (i) {
      return ServicesTypeModel.fromMap(maps[i]);
    });
  }

  Future<int> insertServices(ServicesTypeModel serviceType) async {
    final d = await db;
    return await d.insert(
      'service_types',
      serviceType.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteServices(int id) async {
    final d = await db;
    return await d.delete('service_types', where: 'pk_service = ?', whereArgs: [id]);
  }
}
