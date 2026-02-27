class TypeGasModel {
  final int? id;
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

  factory TypeGasModel.fromFirestore(Map<String, dynamic> map, String id) {
    return TypeGasModel(
      id: int.tryParse(id) ?? 0,
      nome: map['nome']?.toString() ?? '',
      abbr: map['abbr']?.toString() ?? '',
      octane: (map['octane_rating'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TypeGasModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
