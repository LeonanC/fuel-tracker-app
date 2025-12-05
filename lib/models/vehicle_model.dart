class VehicleModel {
  final String id;
  final String nickname;
  final String make; // Frabricante
  final String model;
  final String fuelType; // Tipo de combustível (ex: Gasolina, Flex, Diesel)
  final int year;
  final double initialOdometer;
  final String? imageUrl;
  final DateTime createdAt;

  VehicleModel({
    required this.id,
    required this.nickname,
    required this.make,
    required this.model,
    required this.fuelType,
    required this.year,
    required this.initialOdometer,
    this.imageUrl,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'make': make,
      'model': model,
      'fuel_type': fuelType,
      'year': year,
      'initial_odometer': initialOdometer,
      'imagem_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      id: map['id'] as String,
      nickname: map['nickname'] as String,
      make: map['make'] as String,
      model: map['model'] as String,
      fuelType: map['fuel_type'] as String,
      year: map['year'] as int,
      initialOdometer: (map['initial_odometer'] as num).toDouble(),
      imageUrl: map['imagem_url'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
