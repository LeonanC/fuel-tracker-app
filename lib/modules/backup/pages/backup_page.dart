import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/backup/controller/backup_controller.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class BackupRestoreScreen extends GetView<BackupController> {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('bk_title'.tr), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('bk_scope_title'.tr),
            const SizedBox(height: 12),
            _buildScopeSelector(),
            const SizedBox(height: 24),
            _buildActionCard(
              context,
              title: "bk_export_card_title".tr,
              description: "bk_action_export_desc".tr,
              buttonLabel: "bk_action_export_btn".tr,
              icon: Icons.cloud_upload_outlined,
              onPressed: controller.exportData,
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              title: "bk_action_import_title".tr,
              description: "bk_action_import_desc".tr,
              buttonLabel: "bk_btn_import",
              icon: Icons.settings_backup_restore_outlined,
              onPressed: controller.importData,
              isWarning: true,
            ),
            const SizedBox(height: 20),
            Obx(
              () => controller.statusMessage.value != null
                  ? _buildStatusBanner()
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeSelector() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildScopeItem(
            'fuel_entries',
            'bk_scope_fuel_entries'.tr,
            RemixIcons.gas_station_line,
          ),
          const Divider(height: 1),
          _buildScopeItem(
            'manutencao',
            'bk_scope_manutencao'.tr,
            RemixIcons.tools_line,
          ),
          const Divider(height: 1),
          _buildScopeItem(
            'vehicles',
            'bk_scope_vehicles'.tr,
            RemixIcons.car_line,
          ),
          const Divider(height: 1),
          _buildScopeItem(
            'lookups',
            'bk_scope_lookups'.tr,
            RemixIcons.table_line,
          ),
        ],
      ),
    );
  }

  Widget _buildScopeItem(String key, String labelKey, IconData icon) {
    return Obx(
      () => CheckboxListTile(
        secondary: Icon(icon),
        title: Text(labelKey),
        value: controller.selectedScopes[key],
        activeColor: Colors.grey,
        onChanged: (_) => controller.toggleScope(key),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String description,
    required String buttonLabel,
    required IconData icon,
    required VoidCallback onPressed,
    bool isWarning = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(icon, size: 40),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(description),
            ),
            const SizedBox(height: 12),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : onPressed,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(),
                        )
                      : Text(buttonLabel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
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
