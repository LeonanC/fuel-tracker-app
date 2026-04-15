import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/services/backup_service.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class BackupRestoreScreen extends StatelessWidget {
  final List<String> colecoes = [
    'fuels',
    'manutencao',
    'postos',
    'service_type',
    'tipo_combustivel',
    'veiculos',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('bk_title'.tr), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: isDark ? Colors.grey[900] : Colors.blue[50],
              child: ListTile(
                leading: Icon(Icons.cloud_download, color: Colors.blue),
                title: Text("Exportar Banco de Dados"),
                subtitle: Text("Gere um arquivo JSON com todas as coleções"),
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: colecoes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.table_chart_outlined),
                  title: Text(colecoes[index]),
                  trailing: Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: Colors.green,
                  ),
                  onTap: () {},
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: Icon(Icons.storage),
                label: Text('INICIAR BACKUP TOTAL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  _executarBackup(context);
                  await BackupService().exportarBackup();
                  Get.back();
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: Icon(Icons.storage),
                label: Text('RESTAURAR BACKUP (JSON)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  _executarBackup(context);
                  await BackupService().importarBackup(context);
                  Get.back();
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: Icon(Icons.delete_outline),
                label: Text('LIMPAR OS DADOS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  _executarDelete(context);
                  await BackupService().deletarDados(context);
                  Get.back();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _executarDelete(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deletando os dados das ${colecoes.length} coleções...'),
      ),
    );
  }

  void _executarBackup(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Iniciando processamento das ${colecoes.length} coleções...',
        ),
      ),
    );
  }
}
