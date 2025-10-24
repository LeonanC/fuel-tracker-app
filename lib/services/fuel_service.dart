// import 'package:flutter/material.dart';
// import 'package:fuel_tracker_app/data/database_helper.dart';
// import 'package:fuel_tracker_app/data/fuelentry_db.dart';
// import 'package:intl/intl.dart';

// class FuelService extends ChangeNotifier {
//   final DatabaseHelper _dbHelper = DatabaseHelper();
//   List<FuelEntry> _entries = [];
//   bool _isLoading = false;

//   List<FuelEntry> get entries => List.unmodifiable(_entries);
//   bool get isLoading => _isLoading;

//   FuelService(){
//     _loadEntries();
//   }

//   Future<void> _loadEntries() async {
//     _isLoading = true;
//     notifyListeners();

//     _entries = await _dbHelper.getFuelEntries();

//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<void> addEntry(FuelEntry entry) async {
//     await _dbHelper.insertFuelEntry(entry);
//     await _loadEntries();
//   }

//   Future<void> removeEntry(FuelEntry entry) async{
//     if(entry.id != null){
//       await _dbHelper.deleteFuelEntry(entry.id!);
//       await _loadEntries();
//     }
//   }

//   Future<double?> getLastOdometer() async {
//     await _loadEntries();
//     if(_entries.isNotEmpty){
//       return _entries.last.odometer;
//     }
//     return null;
//   }

  // double calculateOverallAverageConsumption(){
  //   if(_entries.length < 2) return 0.0;

  //   double totalDistance = 0.0;
  //   double totalLiters = 0.0;

  //   final sortedEntries = List<FuelEntry>.from(_entries);
  //   sortedEntries.sort((a, b){
  //     int dateComparison = a.date.compareTo(b.date);
  //     if(dateComparison != 0) return dateComparison;
  //     return a.odometer.compareTo(b.odometer);
  //   });

  //   for(int i = 1; i < sortedEntries.length; i++){
  //     totalDistance += sortedEntries[i].odometer - sortedEntries[i-1].odometer;
  //     totalLiters += sortedEntries[i].liters;
  //   }
  //   if(totalLiters <= 0) return 0.0;
  //   return totalDistance / totalLiters;
  // }

  // Future<String> backupEntries() async {
  //   await _loadEntries();
  //   if(_entries.isEmpty){
  //     return 'Nenhum registro para backup.';
  //   }

  //   final StringBuffer sb = StringBuffer('Data,Hôdometro,Litros,Preço por Litro,Preço Total\n');

  //   for(final entry in _entries){
  //     sb.writeln('''
  //       =======================
  //       Data: ${DateFormat('yyyy-MM-dd').format(entry.date)}
  //       Hodômetro: ${entry.odometer.toStringAsFixed(2)}
  //       Litros: ${entry.liters.toStringAsFixed(2)}
  //       Preço por Litros: ${entry.pricePerLiter.toStringAsFixed(2)}
  //       Preço Total: ${entry.totalPrice.toStringAsFixed(2)}
  //       =======================
  //       ''');
  //   }
  //   return sb.toString();
  // }
// }