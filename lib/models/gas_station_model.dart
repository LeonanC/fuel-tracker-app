class GasStationModel {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  final String brand;
  final double priceGasoline;
  final double priceEthanol;
  final bool hasConvenientStore;
  final bool is24Hours;

  GasStationModel({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.brand,
    required this.priceGasoline,
    required this.priceEthanol,
    required this.hasConvenientStore,
    required this.is24Hours,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'brand': brand,
      'priceGasoline': priceGasoline,
      'priceEthanol': priceEthanol,
      'hasConvenientStore': hasConvenientStore ? 1 : 0,
      'is24Hours': is24Hours ? 1 : 0,
    };
  }

  factory GasStationModel.fromMap(Map<String, dynamic> map) {
    return GasStationModel(
      id: map['id'] as int?,
      name: map['nome'] as String,
      latitude: map['latitude'] is int
          ? (map['latitude'] as int).toDouble()
          : map['latitude'] as double,
      longitude: map['longitude'] is int
          ? (map['longitude'] as int).toDouble()
          : map['longitude'] as double,
      address: map['address'] as String?,

      brand: map['brand'] as String,
      priceGasoline: map['priceGasoline'] as double,
      priceEthanol: map['priceEthanol'] as double,
      hasConvenientStore: (map['hasConvenientStore'] as int) == 1,
      is24Hours: (map['is24Hours'] as int) == 1,
    );
  }
}
