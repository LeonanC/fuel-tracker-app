import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/services/backup_service.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class BackupRestoreScreen extends StatefulWidget {
  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final Map<String, bool> colecoesSelecionadas = {
    'fuels': true,
    'manutencao': true,
    'postos': true,
    'service_type': true,
    'tipo_combustivel': true,
    'veiculos': true,
  };

  List<String> get _getSelecaoFinal => colecoesSelecionadas.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('bk_title'.tr), centerTitle: true),
      body: Column(
        children: [
          _buildHeader(isDark),
          Divider(),
          Expanded(
            child: ListView(
              children: colecoesSelecionadas.keys.map((String key) {
                return CheckboxListTile(
                  title: Text(key),
                  secondary: Icon(Icons.table_chart_outlined),
                  value: colecoesSelecionadas[key],
                  activeColor: Colors.blueAccent,
                  onChanged: (bool? value) {
                    setState(() {
                      colecoesSelecionadas[key] = value ?? false;
                    });
                  },
                );
              }).toList(),
            ),
          ),

          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
    child: Column(
      children: [
        _customButton(
          label: "EXECUTAR BACKUP SELECIONADO",
          icon: Icons.cloud_upload,
          color: Colors.blueAccent,
          onPressed: _getSelecaoFinal.isEmpty
              ? null
              : () async {
                  _executarBackup(context);
                  await BackupService().exportarBackup(
                    colecoes: _getSelecaoFinal,
                  );
                  Get.back();
                },
        ),
        const SizedBox(height: 12),
        _customButton(
          label: "RESTAURAR BACKUP SELECIONADO",
          icon: Icons.settings_backup_restore,
          color: Colors.greenAccent,
          onPressed: _getSelecaoFinal.isEmpty
              ? null
              : () async {
                  _executarBackup(context);
                  await BackupService().importarBackup(context);
                  Get.back();
                },
        ),
        const SizedBox(height: 12),
        _customButton(
          label: "DELETAR DADOS SELECIONADO",
          icon: RemixIcons.delete_bin_2_line,
          color: Colors.redAccent,
          onPressed: _getSelecaoFinal.isEmpty
              ? null
              : () async {
                  _executarBackup(context);
                  await BackupService().deletarDados(
                    context,
                    colecoes: _getSelecaoFinal,
                  );
                  Get.back();
                },
        ),
      ],
    ),
  );

  Widget _customButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Padding _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: isDark ? Colors.grey[900] : Colors.blue[50],
        child: ListTile(
          leading: Icon(RemixIcons.filter_line, color: Colors.blue),
          title: Text("Seleção de Dados"),
          subtitle: Text("Excolha quais tabelas incluir na operação"),
        ),
      ),
    );
  }

  void _executarDelete(BuildContext context) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('Deletando os dados das ${colecoes.length} coleções...'),
    //   ),
    // );
  }

  void _executarBackup(BuildContext context) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(
    //       'Iniciando processamento das ${colecoes.length} coleções...',
    //     ),
    //   ),
    // );
  }
}
