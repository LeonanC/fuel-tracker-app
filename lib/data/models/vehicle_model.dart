import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  final int? id;
  final String nickname;
  final String plate;
  final bool isMercosul;
  final String city;
  final String make; // Frabricante
  final String model;
  final int fuelType; // Tipo de combustível (ex: Gasolina, Flex, Diesel)
  final int year;
  final double initialOdometer;
  final double tankCapacity;
  final String? imageUrl;
  final String createdAt;

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
      'is_mercosul': isMercosul ? 1 : 0,
      'city': city,
      'make': make,
      'model': model,
      'fk_type_fuel': fuelType,
      'year': year,
      'initial_odometer': initialOdometer,
      'tank_capacity': tankCapacity,
      'imagem_url': imageUrl,
      'created_at': createdAt,
    };
  }

  factory VehicleModel.fromFirestore(Map<String, dynamic> map, String id) {
    DateTime? dataDateTime;
    if (map['created_at'] is Timestamp) {
      dataDateTime = (map['created_at'] as Timestamp).toDate();
    }
    return VehicleModel(
      id: int.tryParse(id) ?? 0,
      nickname: map['nickname'] as String,
      plate: map['plate'] as String? ?? '',
      isMercosul: map['is_mercosul'] as bool,
      city: map['city'] as String,
      make: map['make'] as String,
      model: map['model'] as String,
      fuelType: map['fk_type_fuel'] as int,
      year: map['year'] as int,
      initialOdometer: (map['initial_odometer'] as num).toDouble(),
      tankCapacity: (map['tank_capacity'] as num? ?? 0.0).toDouble(),
      imageUrl: map['imagem_url'] as String? ?? '',
      createdAt: dataDateTime?.toIso8601String() ?? '',
    );
  }
}
