import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceModel {
  final String? id;
  final String tipoId;
  final DateTime dataServico;
  final double quilometragem;
  final double custo;
  final String observacoes;

  final double lembreteKm;
  final DateTime lembreteData;
  final bool lembreteAtivo;

  final int? veiculoId;

  MaintenanceModel({
    this.id,
    required this.tipoId,
    required this.dataServico,
    required this.quilometragem,
    required this.custo,
    required this.observacoes,
    required this.lembreteKm,
    required this.lembreteData,
    this.lembreteAtivo = false,
    this.veiculoId,
  });

  factory MaintenanceModel.fromFirestore(
    Map<String, dynamic> map,
    String docId,
  ) {
    DateTime parsedData;
    if (map['data_servico'] is Timestamp) {
      parsedData = (map['data_servico'] as Timestamp).toDate();
    } else if (map['data_servico'] is String) {
      parsedData = DateTime.tryParse(map['data_servico']) ?? DateTime.now();
    } else {
      parsedData = DateTime.now();
    }
    DateTime lembreteData;
    if (map['lembrete_data'] is Timestamp) {
      lembreteData = (map['lembrete_data'] as Timestamp).toDate();
    } else if (map['lembrete_data'] is String) {
      lembreteData = DateTime.tryParse(map['lembrete_data']) ?? DateTime.now();
    } else {
      lembreteData = DateTime.now();
    }

    return MaintenanceModel(
      id: docId,
      tipoId: map['fk_tipo'] ?? 0,
      dataServico: parsedData,
      quilometragem: (map['quilometragem'] as num?)?.toDouble() ?? 0.0,
      custo: (map['custo'] as num?)?.toDouble() ?? 0.0,
      observacoes: map['observacoes'],
      lembreteKm: (map['lembrete_km'] as num?)?.toDouble() ?? 0.0,
      lembreteData: lembreteData,
      lembreteAtivo: map['lembrete_ativo'] == 1,
      veiculoId: map['fk_vehicle'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pk_manutencao': id,
      'fk_tipo': tipoId,
      'data_servico': Timestamp.fromDate(dataServico),
      'quilometragem': quilometragem,
      'custo': custo,
      'observacoes': observacoes,
      'lembrete_km': lembreteKm,
      'lembrete_data': Timestamp.fromDate(lembreteData),
      'lembrete_ativo': lembreteAtivo ? 1 : 0,
      'fk_vehicle': veiculoId,
    };
  }

  List<dynamic> toCsvList() {
    final String lembreteAtivoText = lembreteAtivo == 1 ? 'Sim' : 'Não';
    return [
      '${dataServico.day.toString().padLeft(2, '0')}/${dataServico.month.toString().padLeft(2, '0')}/${dataServico.year} ${dataServico.hour.toString().padLeft(2, '0')}:${dataServico.minute.toString().padLeft(2, '0')}',
      '${lembreteData.day.toString().padLeft(2, '0')}/${lembreteData.month.toString().padLeft(2, '0')}/${lembreteData.year} ${lembreteData.hour.toString().padLeft(2, '0')}:${lembreteData.minute.toString().padLeft(2, '0')}',
      tipoId,
      quilometragem.toStringAsFixed(1),
      custo.toStringAsFixed(2),
      observacoes.toString(),
      lembreteKm.toStringAsFixed(2),
      lembreteAtivoText,
      veiculoId,
    ];
  }
}
