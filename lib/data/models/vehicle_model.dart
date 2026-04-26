class VehicleModel {
  final String? id;
  final String nickname;
  final String plate;
  final String city;
  final String make;
  final String model;
  final String fuelType;
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
    required this.year,
    required this.initialOdometer,
    required this.tankCapacity,
  });

  Map<String, dynamic> toMap() {
    return {
      if(id != null) 'id': id,
      'nickname': nickname,
      'plate': plate,
      'city': city,
      'make': make,
      'model': model,
      'fk_type_fuel': fuelType,
      'year': year,
      'initial_odometer': initialOdometer,
      'tank_capacity': tankCapacity,
    };
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
      year: map['year'] as int,
      initialOdometer: (map['initial_odometer'] as num).toDouble(),
      tankCapacity: (map['tank_capacity'] as num).toDouble(),
    );
  }
}
