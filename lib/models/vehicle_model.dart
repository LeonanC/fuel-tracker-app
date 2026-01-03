class VehicleModel {
  final int? id;
  final String nickname;
  final String plate;
  final bool isMercosul;
  final String city;
  final String make; // Frabricante
  final String model;
  final int fuelType; // Tipo de combustível (ex: Gasolina, Flex, Diesel)
  final String? fuelTypeName;
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
    this.fuelTypeName,
    required this.year,
    required this.initialOdometer,
    required this.tankCapacity,
    this.imageUrl,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

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
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      id: map['pk_vehicle'] as int?,
      nickname: map['nickname'] as String,
      plate: map['plate'] as String? ?? '',
      isMercosul: (map['is_mercosul'] as int? ?? 1) == 1,
      city: map['city'] as String,
      make: map['make'] as String,
      model: map['model'] as String,
      fuelType: map['fk_type_fuel'] as int,
      fuelTypeName: map['fuel_name'] as String?,
      year: map['year'] as int,
      initialOdometer: (map['initial_odometer'] as num).toDouble(),
      tankCapacity: (map['tank_capacity'] as num? ?? 0.0).toDouble(),
      imageUrl: map['imagem_url'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

extension VehicleCopyWith on VehicleModel {
  VehicleModel copyWith({
    int? id,
    String? nickname,
    String? plate,
    bool? isMercosul,
    String? city,
    String? make,
    String? model,
    int? fuelType,
    int? year,
    double? initialOdometer,
    double? tankCapacity,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      plate: plate ?? this.plate,
      isMercosul: isMercosul ?? this.isMercosul,
      city: city ?? this.city,
      make: make ?? this.make,
      model: model ?? this.model,
      fuelType: fuelType ?? this.fuelType,
      year: year ?? this.year,
      initialOdometer: initialOdometer ?? this.initialOdometer,
      tankCapacity: tankCapacity ?? this.tankCapacity,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}