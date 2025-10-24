import 'package:fuel_tracker_app/services/application.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract class DatabaseHelper {
  static Database? _database;

  static Future<Database> init() async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    final path = join('$dbPath/$dbName');
    _database = await openDatabase(
      path,
      version: dbVersion,
      onCreate: (db, version) async {
        dbCreate.forEach((String sql) {
          db.execute(sql);
        });
      },
    );
    return _database!;
  }

  Future<Database> getDb() async {
    return await init();
  }

  Future<double?> getLastOdometer();
}
