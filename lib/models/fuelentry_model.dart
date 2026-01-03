class FuelEntryModel {
  final int? id;
  final int vehicleId;
  final int? fuelTypeId;
  final int? gasStationId;

  final String? fuelTypeName;
  final String? vehicleName;
  final String? stationName;
  final String? vehiclePlate;
  final String? vehicleCity;
  final double? vehicleTank;

  final DateTime entryDate;
  final double odometerKm;
  final double volumeLiters;
  final double pricePerLiter;
  final double totalCost;

  final int tankFull;
  final String? receiptPath;

  FuelEntryModel({
    this.id,
    required this.vehicleId,
    this.fuelTypeId,
    this.gasStationId,
    this.fuelTypeName,
    this.vehicleName,
    this.stationName,
    this.vehiclePlate,
    this.vehicleCity,
    this.vehicleTank,
    required this.entryDate,
    required this.odometerKm,
    required this.volumeLiters,
    required this.pricePerLiter,
    required this.totalCost,
    this.tankFull = 0,
    this.receiptPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'pk_fuel': id,
      'fk_vehicle': vehicleId,
      'fk_type_fuel': fuelTypeId,
      'fk_station': gasStationId,
      'entry_date': entryDate.toIso8601String(),
      'odometer_km': odometerKm,
      'volume_liters': volumeLiters,
      'price_per_liter': pricePerLiter,
      'total_cost': totalCost,
      'tank_full': tankFull,
      'receipt_path': receiptPath,
    };
  }

  factory FuelEntryModel.fromMap(Map<String, dynamic> map) {
    return FuelEntryModel(
      id: map['pk_fuel'] as int?,
      vehicleId: map['fk_vehicle'] ?? 0,
      fuelTypeId: map['fk_type_fuel'] as int?,
      gasStationId: map['fk_station'] as int?,

      fuelTypeName: map['fuel_name'] as String?,
      vehicleName: map['vehicle_name'] as String?,
      stationName: map['station_name'] as String?,
      vehiclePlate: map['vehicle_plate'] as String?,
      vehicleCity: map['vehicle_city'] as String?,
      vehicleTank: (map['vehicle_tank'] as num?)?.toDouble() ?? 0.0,

      entryDate: map['entry_date'] is String
          ? DateTime.parse(map['entry_date'])
          : DateTime.now(),

      odometerKm: (map['odometer_km'] as num?)?.toDouble() ?? 0.0,

      volumeLiters: double.tryParse(map['volume_liters']?.toString() ?? '0') ?? 0.0,

      pricePerLiter: (map['price_per_liter'] as num?)?.toDouble() ?? 0.0,
      totalCost: (map['total_cost'] as num?)?.toDouble() ?? 0.0,
      
      tankFull: map['tank_full'] ?? 0,
      receiptPath: map['receipt_path'] as String?,
    );
  }

  

  FuelEntryModel copyWith({
    int? id,
    int? vehicleId,
    int? fuelTypeId,
    int? gasStationId,
    DateTime? entryDate,
    double? odometerKm,
    double? volumeLiters,
    double? pricePerLiter,
    double? totalCost,
    int? tankFull,
    String? receiptPath,
  }) {
    return FuelEntryModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      fuelTypeId: fuelTypeId ?? this.fuelTypeId,
      gasStationId: gasStationId ?? this.gasStationId,
      entryDate: entryDate ?? this.entryDate,
      odometerKm: odometerKm ?? this.odometerKm,
      volumeLiters: volumeLiters ?? this.volumeLiters,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      totalCost: totalCost ?? this.totalCost,
      tankFull: tankFull ?? this.tankFull,
      receiptPath: receiptPath ?? this.receiptPath,
    );
  }

  List<dynamic> toCsvList() {
    final DateTime dateTime = entryDate;
    final String tankFullText = tankFull == 1 ? 'Sim' : 'Não';
    final String formattedDate =
        '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return [
      formattedDate,
      vehicleId,
      gasStationId ?? 'N/A',
      fuelTypeId ?? 'N/A',
      odometerKm,
      volumeLiters,
      pricePerLiter.toStringAsFixed(3),
      totalCost.toStringAsFixed(2),
      tankFullText,
      receiptPath ?? '',
    ];
  }

  double calculateConsumption(FuelEntryModel previousEntry) {
    if (previousEntry.tankFull != 1) {
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
