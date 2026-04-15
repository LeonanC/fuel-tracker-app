import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  final String? id;
  final String nickname;
  final String plate;
  final bool isMercosul;
  final String city;
  final String make; // Frabricante
  final String model;
  final String fuelType; // Tipo de combustível (ex: Gasolina, Flex, Diesel)
  final int year;
  final double initialOdometer;
  final double tankCapacity;
  final String? imageUrl;
  final DateTime createdAt;

  VehicleModel({
    this.id,
    required this.nickname,
    required this.plate,
    this.isMercosul = true,
    required this.city,
    required this.make,
    required this.model,
    required this.fuelType,
    required this.year,
    required this.initialOdometer,
    required this.tankCapacity,
    required this.createdAt,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'pk_vehicle': id,
      'nickname': nickname,
      'plate': plate,
      'is_mercosul': isMercosul ? true : false,
      'city': city,
      'make': make,
      'model': model,
      'fk_type_fuel': fuelType,
      'year': year,
      'initial_odometer': initialOdometer,
      'tank_capacity': tankCapacity,
      'imagem_url': imageUrl,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory VehicleModel.fromFirestore(Map<String, dynamic> map, String docId) {
    DateTime parsedData;
    if (map['created_at'] is Timestamp) {
      parsedData = (map['created_at'] as Timestamp).toDate();
    } else if (map['created_at'] is String) {
      parsedData = DateTime.tryParse(map['created_at']) ?? DateTime.now();
    } else {
      parsedData = DateTime.now();
    }

    return VehicleModel(
      id: docId,
      nickname: map['nickname'] as String,
      plate: map['plate'] as String? ?? '',
      isMercosul: map['is_mercosul'] == true,
      city: map['city'] as String,
      make: map['make'] as String,
      model: map['model'] as String,
      fuelType: map['fk_type_fuel'] ?? 0,
      year: map['year'] as int,
      initialOdometer: (map['initial_odometer'] as num?)?.toDouble() ?? 0.0,
      tankCapacity: (map['tank_capacity'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imagem_url'] as String? ?? '',
      createdAt: parsedData,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VehicleModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
