class MaintenanceEntry {
  final int? id;
  final String tipo;
  final DateTime dataServico;
  final double quilometragem;
  final double? custo;
  final String? observacoes;

  final double? lembreteKm;
  final DateTime? lembreteData;
  final bool lembreteAtivo;

  final int? veiculoId;

  MaintenanceEntry({
    this.id,
    required this.tipo,
    required this.dataServico,
    required this.quilometragem,
    this.custo,
    this.observacoes,
    this.lembreteKm,
    this.lembreteData,
    this.lembreteAtivo = false,
    this.veiculoId,
  });

  factory MaintenanceEntry.fromMap(Map<String, dynamic> map) {
    return MaintenanceEntry(
      id: map['pk_manutencao'],
      tipo: map['tipo'],
      dataServico: DateTime.parse(map['data_servico']),
      quilometragem: (map['quilometragem'] as num).toDouble(),
      custo: (map['custo'] as num).toDouble(),
      observacoes: map['observacoes'],
      lembreteKm: (map['lembrete_km'] as num?)?.toDouble(),
      lembreteData: map['lembrete_data'] != null ? DateTime.parse(map['lembrete_data']) : null,
      lembreteAtivo: map['lembrete_ativo'] == 1,
      veiculoId: map['veiculo_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pk_manutencao': id,
      'tipo': tipo,
      'data_servico': dataServico.toIso8601String().split('T').first,
      'quilometragem': quilometragem,
      'custo': custo,
      'observacoes': observacoes,
      'lembrete_km': lembreteKm,
      'lembrete_data': lembreteData?.toIso8601String().split('T').first,
      'lembrete_ativo': lembreteAtivo ? 1 : 0,
      'veiculo_id': veiculoId,
    };
  }

  List<dynamic> toCsvList() {
    final String lembreteAtivoText = lembreteAtivo == 1 ? 'Sim' : 'Não';
    return [
      '${dataServico.day.toString().padLeft(2, '0')}/${dataServico.month.toString().padLeft(2, '0')}/${dataServico.year} ${dataServico.hour.toString().padLeft(2, '0')}:${dataServico.minute.toString().padLeft(2, '0')}',
      '${lembreteData!.day.toString().padLeft(2, '0')}/${lembreteData!.month.toString().padLeft(2, '0')}/${lembreteData!.year} ${lembreteData!.hour.toString().padLeft(2, '0')}:${lembreteData!.minute.toString().padLeft(2, '0')}',
      tipo.toString(),
      quilometragem.toStringAsFixed(1),
      custo!.toStringAsFixed(3),
      observacoes!.toString(),
      lembreteKm!.toStringAsFixed(2),
      lembreteAtivoText,
      veiculoId,
    ];
  }
}

extension MaintenanceEntryCopWith on MaintenanceEntry {
  MaintenanceEntry copyWith({
    int? id,
    String? tipo,
    DateTime? dataServico,
    double? quilometragem,
    double? custo,
    String? observacoes,
    double? lembreteKm,
    DateTime? lembreteData,
    bool? lembreteAtivo,
    int? veiculoId,
  }) {
    return MaintenanceEntry(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      dataServico: dataServico ?? this.dataServico,
      quilometragem: quilometragem ?? this.quilometragem,
      custo: custo ?? this.custo,
      observacoes: observacoes ?? this.observacoes,
      lembreteKm: lembreteKm ?? this.lembreteKm,
      lembreteData: lembreteData ?? this.lembreteData,
      lembreteAtivo: lembreteAtivo ?? this.lembreteAtivo,
      veiculoId: veiculoId ?? this.veiculoId,
    );
  }
}
