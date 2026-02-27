import 'package:fuel_tracker_app/data/database_helper.dart';
import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/data/models/gas_station_model.dart';
import 'package:fuel_tracker_app/data/models/maintenance_entry_model.dart';
import 'package:fuel_tracker_app/data/models/services_type_model.dart';
import 'package:fuel_tracker_app/data/models/type_gas_model.dart';
import 'package:fuel_tracker_app/data/models/vehicle_model.dart';
import 'package:fuel_tracker_app/data/services/application.dart';
import 'package:sqflite/sqflite.dart';

class FuelDb {
  static final FuelDb instance = FuelDb._internal();
  factory FuelDb() => instance;

  FuelDb._internal();

  String get dbname => dbName;
  int get dbversion => dbVersion;

  Future<Database> get db async => await DatabaseHelper.instance.database;

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

  Future<void> insertFuel(Map<String, dynamic> data) async {
    final d = await db;
    if (data['pk_fuel'] == null) {
      await d.insert('fuel_entries', data);
    } else {
      await d.update(
        'fuel_entries',
        data,
        where: 'pk_fuel = ?',
        whereArgs: [data['pk_fuel']],
      );
    }
  }

  Future<void> saveVehicle(Map<String, dynamic> data) async {
    final d = await db;
    if (data['pk_vehicle'] == null) {
      await d.insert('vehicles', data);
    } else {
      await d.update(
        'vehicles',
        data,
        where: 'pk_vehicle = ?',
        whereArgs: [data['pk_vehicle']],
      );
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
    int rows = await d.delete(
      'fuel_entries',
      where: 'pk_fuel = ?',
      whereArgs: [id],
    );
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
    return await d.delete(
      'manutencao',
      where: 'pk_manutencao = ?',
      whereArgs: [id],
    );
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
    return await d.delete(
      'gas_stations',
      where: 'pk_station = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllMaintenanceEntries() async {
    final d = await db;
    return await d.query(
      'manutencao',
      orderBy: 'data_servico DESC, quilometragem DESC',
    );
  }

  Future<int> deleteVehicle(int id) async {
    final d = await db;
    return await d.delete('vehicles', where: 'pk_vehicle = ?', whereArgs: [id]);
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
    return await d.delete(
      'service_types',
      where: 'pk_service = ?',
      whereArgs: [id],
    );
  }
}
