import 'package:fuel_tracker_app/data/database_helper.dart';
import 'package:fuel_tracker_app/services/application.dart';

class FuelEntryDb extends DatabaseHelper {
  static FuelEntryDb? _this;
  factory FuelEntryDb() {
    if (_this == null) {
      _this = FuelEntryDb.instanceHome();
    }
    return _this!;
  }

  FuelEntryDb.instanceHome() : super();

  String get dbname => dbName;
  int get dbversion => dbVersion;

  Future<List<Map<String, dynamic>>> getAllFuelEntries() async {
    final db = await getDb();
    return await db.query(
      'fuel_entries', 
      orderBy: 'quilometragem DESC, data_abastecimento DESC');
  }

  @override
  Future<Map> getItem(dynamic where) async {
    final db = await getDb();
    List<Map> items = await db.query('fuel_entries', where: 'id = ?', whereArgs: [where], limit: 1);
    Map result = Map();
    if (items.isNotEmpty) {
      return items.first;
    }
    return result;
  }

  @override
  Future<double?> getLastOdometer() async {
    final db = await getDb();
    List<Map<String, dynamic>> items = await db.query('fuel_entries', columns: ['quilometragem'], orderBy: 'data_abastecimento DESC', limit: 1);
    if (items.isNotEmpty && items.first['quilometragem'] != null) {
      return (items.first['quilometragem'] as num).toDouble();
    }
    return null;
  }

  Future<int> insertFuelEntrie(Map<String, dynamic> values) async {
    final db = await getDb();
    values.remove('id');
    int newId = await db.insert('fuel_entries', values);
    return newId;
  }

  Future<bool> updateFuelEntrie(Map<String, dynamic> values) async {
    if(values['id'] == null) return false;
    final db = await getDb();
    int rows = await db.update(
      'fuel_entries', 
      values, 
      where: 'id = ?', 
      whereArgs: [values['id']],
    );
    return (rows != 0);
  }

  Future<bool> deleteFuelEntrie(int id) async {
    final db = await getDb();
    int rows = await db.delete(
      'fuel_entries', 
      where: 'id = ?', 
      whereArgs: [id]);
    return (rows != 0);
  }

  Future<int> deleteAll() async {
    final db = await getDb();
    return await db.delete('fuel_entries');
  }

  Future<int> insertMaintenance(Map<String, dynamic> values) async {
    final db = await getDb();
    values.remove('id');
    int newId = await db.insert('manutencao', values);
    return newId;
  }

  Future<bool> updateMaintenance(Map<String, dynamic> values) async {
    if(values['id'] == null) return false;
    final db = await getDb();
    int rows = await db.update(
      'manutencao', 
      values,
      where: 'id = ?',
      whereArgs: [values['id']],
    );
    return (rows != 0);
  }

  Future<bool> deleteMaintenance(int id) async {
    final db = await getDb();
    int rows = await db.delete(
      'manutencao',
      where: 'id = ?',
      whereArgs: [id],
    );
    return (rows != 0);
  }

  Future<List<Map<String, dynamic>>> getAllMaintenanceEntries() async {
    final db = await getDb();
    return await db.query(
      'manutencao',
      orderBy: 'data_servico DESC, quilometragem DESC'
    );
  }
}