import 'package:cloud_firestore/cloud_firestore.dart';

class FuelEntryModel {
  final String? id;
  final int vehicleId;
  final int fuelTypeId;
  final int gasStationId;
  final String entryDate;
  final double odometerKm;
  final double volumeLiters;
  final double pricePerLiter;
  final double totalCost;
  final double tankCapacity;
  final bool tankFull;
  final String? receiptPath;

  FuelEntryModel({
    this.id,
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
  });

  Map<String, dynamic> toMap() {
    return {
      'pk_fuel': id,
      'fk_veiculo': vehicleId,
      'fk_tipo': fuelTypeId,
      'fk_posto': gasStationId,
      'data': entryDate,
      'velocimetro': odometerKm,
      'litros_volume': volumeLiters,
      'preco_litro': pricePerLiter,
      'custo_total': totalCost,
      'tanque_cheio': tankFull,
      'tank_capacity': tankCapacity,
      'receipt_path': receiptPath,
    };
  }

  factory FuelEntryModel.fromFirestore(Map<String, dynamic> map, String id) {
    DateTime? dataDateTime;
    if (map['data'] is Timestamp) {
      dataDateTime = (map['data'] as Timestamp).toDate();
    }
    return FuelEntryModel(
      id: map['pk_fuel'] as String?,
      vehicleId: map['fk_veiculo'] as int,
      fuelTypeId: map['fk_tipo'] as int,
      gasStationId: map['fk_posto'] as int,
      entryDate: dataDateTime?.toIso8601String() ?? '',
      odometerKm: (map['velocimetro'] as num?)?.toDouble() ?? 0.0,
      volumeLiters: (map['litros_volume'] as num?)?.toDouble() ?? 0.0,
      pricePerLiter: (map['preco_litro'] as num?)?.toDouble() ?? 0.0,
      totalCost: (map['custo_total'] as num?)?.toDouble() ?? 0.0,
      tankCapacity: (map['tank_capacity'] as num?)?.toDouble() ?? 0.0,
      tankFull: map['tanque_cheio'] ?? false,
      receiptPath: map['receipt_path'] as String?,
    );
  }

  double calculateConsumption(FuelEntryModel previousEntry) {
    if (previousEntry.tankFull == false) {
      return 0.0;
    }

    final double distanceKM = this.odometerKm - previousEntry.odometerKm;

    if (this.volumeLiters <= 0 || distanceKM <= 0) {
      return 0.0;
    }

    final double consumption = distanceKM / this.volumeLiters;

    return double.parse(consumption.toStringAsFixed(2));
  }
}
