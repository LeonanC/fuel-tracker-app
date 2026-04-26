import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/services/backup_service.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final List<Map<String, dynamic>> _tabelasConfig = [
    {
      'id': 'abastecimentos',
      'label': 'Histórico de Abastecimentos',
      'icon': RemixIcons.gas_station_line,
    },
    {
      'id': 'postos',
      'label': 'Postos de Gasolina',
      'icon': RemixIcons.user_location_line,
    },
    {
      'id': 'service_type',
      'label': 'Tipos de Manutenção',
      'icon': RemixIcons.building_line,
    },
    {
      'id': 'tipo_combustivel',
      'label': 'Tipos de Combustível',
      'icon': RemixIcons.oil_line,
    },
    {'id': 'veiculos', 'label': 'Meus Veículos', 'icon': RemixIcons.car_line},
  ];
  final Map<String, bool> colecoesSelecionadas = {
    'abastecimentos': true,
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
            child: ListView.builder(
              itemCount: _tabelasConfig.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final item = _tabelasConfig[index];
                final String id = item['id'];
                final bool isSelected = colecoesSelecionadas[id] ?? false;
                return _buildTableItem(
                  title: item['label'],
                  icon: item['icon'],
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      colecoesSelecionadas[id] = !isSelected;
                    });
                  },
                );
              },
            ),
          ),

          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    decoration: BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, -5),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      bottom: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _customButton(
            label: "EXECUTAR BACKUP",
            icon: RemixIcons.cloud_fill,
            color: Colors.blueAccent,
            onPressed: _getSelecaoFinal.isEmpty
                ? null
                : () => _processarBackup(context),
          ),
          const SizedBox(height: 12),
          _customButton(
            label: "RESTAURAR BACKUP",
            icon: RemixIcons.refresh_line,
            color: Colors.greenAccent,
            onPressed: _getSelecaoFinal.isEmpty
                ? null
                : () => _processarRestauro(context),
          ),
          const SizedBox(height: 12),
          _customButton(
            label: "DELETAR DADOS",
            icon: RemixIcons.delete_bin_5_line,
            color: Colors.redAccent,
            onPressed: _getSelecaoFinal.isEmpty
                ? null
                : () => _processarDeletar(context),
          ),
        ],
      ),
    ),
  );

  Widget _buildTableItem({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? Colors.blueAccent.withOpacity(0.15) : Colors.blue[50])
            : (isDark ? Colors.grey[900] : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? Colors.blueAccent
              : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blueAccent
                : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? (isDark ? Colors.blue[200] : Colors.blue[900])
                : null,
          ),
        ),
        trailing: Checkbox(
          value: isSelected,
          activeColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (_) => onTap(),
        ),
      ),
    );
  }

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

  void _processarBackup(BuildContext context) async {
    await BackupService().exportarBackup();
    _showSnackbar("Iniciando", "Exportando as tabelas...");
  }

  void _processarRestauro(BuildContext context) async {
    await BackupService().importarBackup(context);
    _showSnackbar("Iniciando", "Restaurando as tabelas...");
  }

  void _processarDeletar(BuildContext context) async {
    await BackupService().deletarDados(context, colecoes: _getSelecaoFinal);
    _showSnackbar("Iniciando", "Deletando todas as tabelas...");
  }

  void _showSnackbar(String title, String messagem, {bool isError = false}) {
    Get.snackbar(
      title,
      messagem,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError
          ? Colors.redAccent.withOpacity(0.8)
          : Colors.greenAccent.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      borderRadius: 15,
      icon: Icon(
        isError ? RemixIcons.error_warning_line : RemixIcons.check_line,
        color: Colors.white,
      )
    );
  }
}
