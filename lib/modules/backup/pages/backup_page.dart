import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/backup/controller/backup_controller.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class BackupRestoreScreen extends GetView<BackupController> {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('bk_title'.tr), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader(
              'bk_scope_title'.tr,
              RemixIcons.cloud_line,
              colorScheme.primary,
            ),
            const SizedBox(height: 12),
            _buildScopeSelector(theme),
            const SizedBox(height: 24),
            _buildActionCard(
              theme,
              title: "bk_export_card_title".tr,
              description: "bk_action_export_desc".tr,
              buttonLabel: "bk_action_export_btn".tr,
              icon: RemixIcons.cloud_line,
              color: colorScheme.primary,
              onPressed: controller.syncData,
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              theme,
              title: "bk_action_import_title".tr,
              description: "bk_action_import_desc".tr,
              buttonLabel: "bk_action_import_btn".tr,
              icon: RemixIcons.download_cloud_line,
              color: Colors.orangeAccent,
              onPressed: controller.clearCloudData,
              isWarning: true,
            ),
            const SizedBox(height: 20),
            Obx(
              () => controller.statusMessage.value != null
                  ? _buildStatusBanner(colorScheme)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color primary) {
    return Row(
      children: [
        Icon(icon, size: 18, color: primary),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildScopeSelector(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildScopeItem(
            'fuel_entries',
            'bk_scope_fuel_entries'.tr,
            RemixIcons.gas_station_line,
            theme,
          ),
          _divider(theme),
          _buildScopeItem(
            'manutencao',
            'bk_scope_manutencao'.tr,
            RemixIcons.tools_line,
            theme,
          ),
          _divider(theme),
          _buildScopeItem(
            'vehicles',
            'bk_scope_vehicles'.tr,
            RemixIcons.car_line,
            theme,
          ),
          _divider(theme),
          _buildScopeItem(
            'lookups',
            'bk_scope_lookups'.tr,
            RemixIcons.table_line,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _divider(ThemeData theme) => Divider(
    height: 1,
    color: theme.colorScheme.onSurface.withOpacity(0.05),
    indent: 60,
  );

  Widget _buildScopeItem(
    String key,
    String labelKey,
    IconData icon,
    ThemeData theme,
  ) {
    return Obx(
      () => CheckboxListTile(
        secondary: Icon(
          icon,
          color: theme.colorScheme.primary.withOpacity(0.7),
        ),
        title: Text(
          labelKey,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
        ),
        activeColor: theme.colorScheme.primary,
        checkColor: Colors.white,
        value: controller.selectedScopes[key],
        onChanged: (_) => controller.toggleScope(key),
        controlAffinity: ListTileControlAffinity.trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildActionCard(
    ThemeData theme, {
    required String title,
    required String description,
    required String buttonLabel,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: LinearProgressIndicator(color: Colors.white),
                      )
                    : Text(
                        buttonLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Text(
        controller.statusMessage.value!,
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}
