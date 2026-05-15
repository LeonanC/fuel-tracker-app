class VehicleModel {
  final String? id;
  final String nickname;
  final String plate;
  final String city;
  final String make;
  final String model;
  final String fuelType;
  final String imagem;
  final int year;
  final double initialOdometer;
  final double tankCapacity;

  VehicleModel({
    this.id,
    required this.nickname,
    required this.plate,
    required this.city,
    required this.make,
    required this.model,
    required this.fuelType,
    required this.imagem,
    required this.year,
    required this.initialOdometer,
    required this.tankCapacity,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'nickname': nickname,
      'plate': plate,
      'city': city,
      'make': make,
      'model': model,
      'fk_type_fuel': fuelType,
      'imagem': imagem,
      'year': year,
      'initial_odometer': initialOdometer,
      'tank_capacity': tankCapacity,
    };
    if(id != null){
      data['id'] = id;
    }
    return data;
  }

  factory VehicleModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return VehicleModel(
      id: (map['id'] ?? docId)?.toString(),
      nickname: map['nickname'],
      plate: map['plate'] ?? '',
      city: map['city'],
      make: map['make'],
      model: map['model'],
      fuelType: map['fk_type_fuel'] ?? '',
      imagem: map['imagem'] ?? '',
      year: map['year'] as int,
      initialOdometer: (map['initial_odometer'] as num).toDouble(),
      tankCapacity: (map['tank_capacity'] as num).toDouble(),
    );
  }

  VehicleModel copyWith({
    String? id,
    String? nickname,
    String? plate,
    String? city,
    String? make,
    String? model,
    String? fuelType,
    String? imagem,
    int? year,
    double? initialOdometer,
    double? tankCapacity,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      plate: plate ?? this.plate,
      city: city ?? this.city,
      make: make ?? this.make,
      model: model ?? this.model,
      fuelType: fuelType ?? this.fuelType,
      imagem: imagem ?? this.imagem,
      year: year ?? this.year,
      initialOdometer: initialOdometer ?? this.initialOdometer,
      tankCapacity: tankCapacity ?? this.tankCapacity,
    );
  }
}
