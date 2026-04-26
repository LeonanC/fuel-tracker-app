class GasStationModel {
  final String? id;
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
      'has_convenient_store': hasConvenientStore ? true : false,
      'is_24_hours': is24Hours ? true : false,
    };
  }

   factory GasStationModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return GasStationModel(
      id: (map['pk_posto'] ?? docId)?.toString(),
      nome: map['nome'] as String,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      address: map['endereco'] as String?,
      brand: map['brand'] as String,
      price: (map['preco'] as num?)?.toDouble() ?? 0.0,
      hasConvenientStore: map['has_convenient_store'] == true || map['hasConvenientStore'] == true,
      is24Hours: map['is_24_hours'] == true || map['is24Hours'] == true,
    );
  }
}
