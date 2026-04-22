import 'package:cloud_firestore/cloud_firestore.dart';

class FuelEntryModel {
  final String? id;
  final String user;
  final String vehicleId;
  final String fuelTypeId;
  final String gasStationId;
  final DateTime entryDate;
  final double odometerKm;
  final double volumeLiters;
  final double pricePerLiter;
  final double totalCost;
  final double tankCapacity;
  final bool tankFull;
  final String? receiptPath;
  final List<String> sharedWith;

  FuelEntryModel({
    this.id,
    required this.user,
    required this.vehicleId,
    required this.fuelTypeId,
    required this.gasStationId,
    required this.entryDate,
    required this.odometerKm,
    required this.volumeLiters,
    required this.pricePerLiter,
    required this.totalCost,
    required this.tankCapacity,
    this.tankFull = false,
    this.receiptPath,
    this.sharedWith = const [],
  });

  double calculateConsumption(FuelEntryModel previousEntry) {
    if (odometerKm <= previousEntry.odometerKm || volumeLiters <= 0) return 0.0;

    final double distanceTraveled = odometerKm - previousEntry.odometerKm;

    return distanceTraveled / volumeLiters;
  }

  Map<String, dynamic> toMap() {
    return {
      'pk_fuel': id,
      'fk_usuario': user,
      'fk_veiculo': vehicleId,
      'fk_tipo': fuelTypeId,
      'fk_posto': gasStationId,
      'data': Timestamp.fromDate(entryDate),
      'velocimetro': odometerKm,
      'litros_volume': volumeLiters,
      'preco_litro': pricePerLiter,
      'custo_total': totalCost,
      'tanque_cheio': tankFull,
      'tank_capacity': tankCapacity,
      'receipt_path': receiptPath,
      'sharedWith': sharedWith,
    };
  }

  factory FuelEntryModel.fromFirestore(Map<String, dynamic> map, String docId) {
    DateTime parsedDate;

    if (map['data'] is Timestamp) {
      parsedDate = (map['data'] as Timestamp).toDate();
    } else if (map['data'] is DateTime) {
      parsedDate = map['data'];
    } else if (map['data'] is String) {
      parsedDate = DateTime.tryParse(map['data']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return FuelEntryModel(
      id: docId,
      user: map['fk_usuario']?.toString() ?? '',
      vehicleId: map['fk_veiculo']?.toString() ?? '',
      fuelTypeId: map['fk_tipo']?.toString() ?? '',
      gasStationId: map['fk_posto']?.toString() ?? '',
      entryDate: parsedDate,
      odometerKm: _toDouble(map['velocimetro']),
      volumeLiters: _toDouble(map['litros_volume']),
      pricePerLiter: _toDouble(map['preco_litro']),
      totalCost: _toDouble(map['custo_total']),
      tankCapacity: _toDouble(map['tank_capacity']),
      tankFull: map['tanque_cheio'] ?? false,
      receiptPath: map['receipt_path'] as String?,
      sharedWith: map['sharedWith'] != null
      ? List<String>.from(map['sharedWith'])
      : []
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
