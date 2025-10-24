class FuelEntry {
  final int? id;
  final String tipo;
  final DateTime dataAbastecimento;
  final String? posto;
  final double quilometragem;
  final double litros;
  final double? pricePerLiter;
  final double? totalPrice;
  final bool tanqueCheio;
  final String? comprovantePath;

  FuelEntry({
    this.id,
    required this.tipo,
    required this.dataAbastecimento,
    this.posto,
    required this.quilometragem,
    required this.litros,
    required this.pricePerLiter,
    required this.totalPrice,
    required this.tanqueCheio,
    this.comprovantePath,
  });

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'data_abastecimento': dataAbastecimento.toIso8601String(),
      'posto': posto,
      'tipo_combustivel': tipo,
      'quilometragem': quilometragem,
      'litros': litros,
      'valor_litro': pricePerLiter,
      'valor_total': totalPrice,
      'tanque_cheio': tanqueCheio,
      'comprovante_path': comprovantePath,
    };
  }

  factory FuelEntry.fromMap(Map<String, dynamic> map) {
    return FuelEntry(
      id: map['id'],
      dataAbastecimento: DateTime.parse(map['data_abastecimento']),
      posto: map['posto'],
      tipo: map['tipo_combustivel'],
      quilometragem:  (map['quilometragem'] as num).toDouble(),
      litros:  (map['litros'] as num).toDouble(),
      pricePerLiter: (map['valor_litro'] as num).toDouble(),
      totalPrice: (map['valor_total'] as num).toDouble(),
      tanqueCheio: map['tanque_cheio'] ==  1,
      comprovantePath: map['comprovante_path'],
    );
  }

  double calculateConsumption(FuelEntry previousEntry){
    final double distance = this.quilometragem - previousEntry.quilometragem;

    if(distance <= 0 || this.litros <= 0){
      return 0.0;
    }
    
    return distance / this.litros;
  }

  List<dynamic> toCsvList() {
    final String tanqueCheioText = tanqueCheio == 1 ? 'Sim' : 'Não';
    return [
      '${dataAbastecimento.day.toString().padLeft(2, '0')}/${dataAbastecimento.month.toString().padLeft(2, '0')}/${dataAbastecimento.year} ${dataAbastecimento.hour.toString().padLeft(2, '0')}:${dataAbastecimento.minute.toString().padLeft(2, '0')}',
      posto ?? '',
      tipo.toString(),
      quilometragem.toStringAsFixed(1),
      litros.toStringAsFixed(3),
      pricePerLiter!.toStringAsFixed(3),
      totalPrice!.toStringAsFixed(2),
      tanqueCheioText,
      comprovantePath ?? '',
    ];
  }

  
}