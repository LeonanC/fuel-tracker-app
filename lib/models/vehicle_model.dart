class Vehicle {
  final String id;
  final String nickname;
  final String make; // Frabricante
  final String model;
  final String fuelType; // Tipo de combustível (ex: Gasolina, Flex, Diesel)
  final int year;
  final double initialOdometer;
  final String? imageUrl;

  Vehicle({
    required this.id,
    required this.nickname,
    required this.make,
    required this.model,
    required this.fuelType,
    required this.year,
    required this.initialOdometer,
    this.imageUrl,
  });

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'nickname': nickname,
      'make': make,
      'model': model,
      'fuelType': fuelType,
      'year': year,
      'initialOdometer': initialOdometer,
      'imageUrl': imageUrl,
    };
  }
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] ?? '',
      nickname: map['nickname'] ?? '',
      make: map['make'] ?? '',
      model: map['model'] ?? '',
      fuelType: map['fuelType'] ?? '',
      year: map['year'] ?? 0,
      initialOdometer: (map['initialOdometer'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'],
    );
  }
}