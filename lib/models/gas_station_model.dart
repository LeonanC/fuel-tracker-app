class GasStationModel {
  final int? id;
  final String nome;
  final String? address;
  final String brand;
  final double latitude;
  final double longitude;
  final double priceGasolineComum;
  final double priceGasolineAditivada;
  final double priceGasolinePremium;
  final double priceEthanol;
  final bool hasConvenientStore;
  final bool is24Hours;

  GasStationModel({
    this.id,
    required this.nome,
    this.address,
    required this.brand,
    required this.latitude,
    required this.longitude,
    required this.priceGasolineComum,
    required this.priceGasolineAditivada,
    required this.priceGasolinePremium,
    required this.priceEthanol,
    required this.hasConvenientStore,
    required this.is24Hours,
  });

  GasStationModel copyWith({
    int? id,
    String? nome,
    double? latitude,
    double? longitude,
    String? address,
    String? brand,
    double? priceGasolineComum,
    double? priceGasolineAditivada,
    double? priceGasolinePremium,
    double? priceEthanol,
    bool? hasConvenientStore,
    bool? is24Hours,
  }) {
    return GasStationModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      brand: brand ?? this.brand,
      priceGasolineComum: priceGasolineComum ?? this.priceGasolineComum,
      priceGasolineAditivada: priceGasolineAditivada ?? this.priceGasolineAditivada,
      priceGasolinePremium: priceGasolinePremium ?? this.priceGasolinePremium,
      priceEthanol: priceEthanol ?? this.priceEthanol,
      hasConvenientStore: hasConvenientStore ?? this.hasConvenientStore,
      is24Hours: is24Hours ?? this.is24Hours,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pk_station': id,
      'nome_posto': nome,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'brand': brand,
      'priceGasolineComum': priceGasolineComum,
      'priceGasolineAditivada': priceGasolineAditivada,
      'priceGasolinePremium': priceGasolinePremium,
      'priceEthanol': priceEthanol,
      'hasConvenientStore': hasConvenientStore ? 1 : 0,
      'is24Hours': is24Hours ? 1 : 0,
    };
  }

  factory GasStationModel.fromMap(Map<String, dynamic> map) {
    return GasStationModel(
      id: map['pk_station'] as int?,
      nome: map['nome_posto'] as String,
      latitude: map['latitude'] is int
          ? (map['latitude'] as int).toDouble()
          : map['latitude'] as double,
      longitude: map['longitude'] is int
          ? (map['longitude'] as int).toDouble()
          : map['longitude'] as double,
      address: map['address'] as String?,
      brand: map['brand'] as String,
      priceGasolineComum: map['priceGasolineComum'] as double,
      priceGasolineAditivada: map['priceGasolineAditivada'] as double,
      priceGasolinePremium: map['priceGasolinePremium'] as double,
      priceEthanol: map['priceEthanol'] as double,
      hasConvenientStore: (map['hasConvenientStore'] as int) == 1,
      is24Hours: (map['is24Hours'] as int) == 1,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GasStationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
