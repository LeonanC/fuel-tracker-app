import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/services/backup_service.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final List<Map<String, dynamic>> _tabelasConfig = [
    {
      'id': 'abastecimentos',
      'label': 'bk_scope_fuel_entries'.tr,
      'icon': RemixIcons.gas_station_line,
    },
    {
      'id': 'postos',
      'label': 'gs_titulo'.tr,
      'icon': RemixIcons.user_location_line,
    },
    {
      'id': 'service_type',
      'label': 'bk_scope_manutencao'.tr,
      'icon': RemixIcons.tools_line,
    },
    {
      'id': 'tipo_combustivel',
      'label': 'bk_scope_types'.tr,
      'icon': RemixIcons.oil_line,
    },
    {
      'id': 'veiculos',
      'label': 'bk_scope_vehicles'.tr,
      'icon': RemixIcons.car_line,
    },
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
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            expandedHeight: 100,
            title: Text(
              'bk_title'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(RemixIcons.question_line),
                onPressed: () => _showSnackbar(
                  "Ajuda",
                  "Selecione os dados que deseja exportar ou restaurar",
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _buildHeader(theme),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = _tabelasConfig[index];
                final String id = item['id'];
                final bool isSelected = colecoesSelecionadas[id] ?? false;
                return _buildTableItem(
                  theme: theme,
                  title: item['label'],
                  icon: item['icon'],
                  isSelected: isSelected,
                  onTap: () =>
                      setState(() => colecoesSelecionadas[id] = !isSelected),
                );
              }, childCount: _tabelasConfig.length),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
      bottomSheet: _buildActionButtons(context),
    );
  }

  Widget _buildTableItem({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.05)
                  : theme.colorScheme.surface,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onTap(),
                  activeColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasSelection = _getSelecaoFinal.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _actionButton(
              label: "bk_action_export_btn".tr.toUpperCase(),
              icon: RemixIcons.cloud_fill,
              color: Colors.blueAccent,
              onPressed: hasSelection ? () => _processarBackup(context) : null,
            ),
            const SizedBox(height: 12),
            _actionButton(
              label: "bk_btn_import".tr.toUpperCase(),
              icon: RemixIcons.refresh_line,
              color: Colors.green,
              onPressed: hasSelection
                  ? () => _processarRestauro(context)
                  : null,
            ),
            const SizedBox(height: 12),
            _actionButton(
              label: "DELETAR DADOS",
              icon: RemixIcons.delete_bin_line,
              color: theme.colorScheme.error,
              isOutlined: true,
              onPressed: hasSelection ? () => _processarDeletar(context) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    bool isOutlined = false,
  }) {
    final style = FilledButton.styleFrom(
      backgroundColor: isOutlined ? Colors.transparent : color,
      foregroundColor: isOutlined ? color : Colors.white,
      elevation: isOutlined ? 0 : 2,
      side: isOutlined ? BorderSide(color: color) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(vertical: 16),
    );

    return SizedBox(
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
              style: style,
            )
          : FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
              style: style,
            ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          Icon(RemixIcons.filter_3_line, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                Text(
                  "bk_scope_title".tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Excolha quais tabelas incluir na operação",
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _processarBackup(BuildContext context) async {
    await BackupService().exportarBackup();
    _showSnackbar(
      "Exportar",
      "Iniciando exportando das tabelas selecionadas...",
    );
  }

  void _processarRestauro(BuildContext context) async {
    await BackupService().importarBackup(context);
    _showSnackbar("Restaurar", "Iniciando processo de importação...");
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
      ),
    );
  }
}
