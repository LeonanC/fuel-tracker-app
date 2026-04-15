class ServicesTypeModel {
  final String id;
  final String nome;
  final String? abbr;
  final int frequency;

  ServicesTypeModel({
    required this.id,
    required this.nome,
    this.abbr,
    required this.frequency,
  });

  Map<String, dynamic> toMap() {
    return {
      'pk_service': id,
      'nome': nome,
      'abbr': abbr,
      'default_frequency_km': frequency,
    };
  }

  factory ServicesTypeModel.fromFirestore(
    Map<String, dynamic> map,
    String docId,
  ) {
    return ServicesTypeModel(
      id: docId,
      nome: map['nome'] as String,
      abbr: map['abbr'] as String,
      frequency: map['default_frequency_km'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ServicesTypeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
