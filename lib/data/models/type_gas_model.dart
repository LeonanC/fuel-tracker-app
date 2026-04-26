class TypeGasModel {
  final String? id;
  final String nome;
  final String? abbr;
  final double octane;

  TypeGasModel({
    required this.id,
    required this.nome,
    this.abbr,
    required this.octane,
  });

  Map<String, dynamic> toMap() {
    return {'pk_tipo': id, 'nome': nome, 'abbr': abbr, 'octane_rating': octane};
  }

  factory TypeGasModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return TypeGasModel(
      id: (map['pk_tipo'] ?? docId)?.toString(),
      nome: map['nome']?.toString() ?? '',
      abbr: map['abbr']?.toString() ?? '',
      octane: (map['octane_rating'] as num?)?.toDouble() ?? 0,
    );
  }
}
