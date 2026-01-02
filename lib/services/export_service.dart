import 'dart:io';

import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fuel_tracker_app/models/fuelentry_model.dart';

class ExportService {
  Future<String?> exportAndShareEntries(List<FuelEntryModel> entries) async {
    try{
      if(entries.isEmpty){
        return 'Nenhum registro para exportar';
      }

      final List<List<dynamic>> csvData = [
        [
          'Veiculo',
          'Tipo Combustível',
          'Posto',
          'Data Abastecimento',        
          'Quilometragem',
          'Litros',
          'Valor Litro',
          'Valor Total',
          'Tanque Cheio',
          'Caminho Comprovante'
        ],
        ...entries.map((e) => e.toCsvList()),
      ];
      
      final String csv = const ListToCsvConverter(
        fieldDelimiter: ';',
        textDelimiter: '"',
      ).convert(csvData);

      const String BOM = '\uFEFF';

      final directory = await getTemporaryDirectory();
      final String fileName = 'relatorio_abastecimento_${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}.csv';
      final path = '${directory.path}/$fileName';
      final file = File(path);
      await file.writeAsString(BOM + csv);
      
      await Share.shareXFiles([XFile(file.path)], text: 'Segue seu relatório de abastecimentos.');

      return null;
    }catch(e){
      debugPrint('Erro ao exportar CSV: $e');
      return 'Erro ao exportar. Verique as permissões';
    }
  }
}