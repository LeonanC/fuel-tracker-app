class GasStationModel {
  final int? id;
  final String nome;
  final String? address;
  final String brand;
  final double latitude;
  final double longitude;
  final double price;
  final bool hasConvenientStore;
  final bool is24Hours;

  GasStationModel({
    this.id,
    required this.nome,
    this.address,
    required this.brand,
    required this.latitude,
    required this.longitude,
    required this.price,
    required this.hasConvenientStore,
    required this.is24Hours,
  });

  Map<String, dynamic> toMap() {
    return {
      'pk_posto': id,
      'nome': nome,
      'latitude': latitude,
      'longitude': longitude,
      'endereco': address,
      'brand': brand,
      'preco': price,
      'hasConvenientStore': hasConvenientStore ? 1 : 0,
      'is24Hours': is24Hours ? 1 : 0,
    };
  }

  factory GasStationModel.fromFirestore(Map<String, dynamic> map, String id) {
    return GasStationModel(
      id: int.tryParse(id) ?? 0,
      nome: map['nome'] as String,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      address: map['endereco'] as String?,
      brand: map['brand'] as String,
      price: (map['preco'] as num?)?.toDouble() ?? 0.0,
      hasConvenientStore: map['hasConvenientStore'] as bool,
      is24Hours: map['is24Hours'] as bool,
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
