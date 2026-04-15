import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuel_tracker_app/data/models/maintenance_entry_model.dart';
import 'package:fuel_tracker_app/modules/registro/controller/maintenance_entry_controller.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class MaintenanceEntryScreen extends StatelessWidget {
  final double? lastOdometer;
  final MaintenanceModel? entry;
  MaintenanceEntryScreen({super.key, this.lastOdometer, this.entry}) {
    Get.put(MaintenanceEntryController()).initializar(entry, lastOdometer);
  }

  @override
  Widget build(BuildContext context) {
    final m = Get.find<MaintenanceEntryController>();
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: true,
        elevation: 0,
        title: Text(m.editingEntry != null ? 'mt_edit'.tr : 'mt_new'.tr),
        actions: [
          IconButton(
            icon: m.editingEntry != null
                ? Icon(RemixIcons.edit_line)
                : Icon(RemixIcons.save_line),
            onPressed: m.submit,
            tooltip: m.editingEntry != null
                ? 'me_btn_edit'.tr
                : 'me_btn_save'.tr,
          ),
        ],
      ),
      body: Obx(
        () => m.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: m.formKey,
                  child: Column(
                    children: [
                      _buildCard(theme, [
                        _buildDatePickerTile(m, theme),
                        _buildInputField(
                          m.kmController,
                          'cl_odometer'.tr,
                          RemixIcons.speed_up_line,
                          isText: true,
                          theme,
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _buildDropdown(m, theme),
                      const SizedBox(height: 20),
                      _buildCard(theme, [
                        _buildInputField(
                          m.custoController,
                          'mt_custo'.tr,
                          RemixIcons.money_dollar_circle_line,
                          isText: true,
                          theme,
                        ),
                        _buildNotesField(
                          m.observacoesController,
                          'mt_observacao'.tr,
                          RemixIcons.money_cny_box_line,
                          maxLength: true,
                          theme,
                        ),
                      ]),
                      _buildReminderSection(m, theme),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCard(ThemeData theme, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDropdown(MaintenanceEntryController m, ThemeData theme) {
    return _buildCard(theme, [
      _dropdown(
        m.selectedService,
        m.lookupController.servicosDrop
            .map((v) => DropdownMenuItem(value: v.id, child: Text(v.nome)))
            .toList(),
        "Serviços",
      ),
      _dropdown(
        m.selectedVehicle,
        m.lookupController.veiculosDrop
            .map((v) => DropdownMenuItem(value: v.id, child: Text(v.nickname)))
            .toList(),
        "Veículos",
      ),
    ]);
  }

  Widget _dropdown(
    RxnString val,
    List<DropdownMenuItem<String>> items,
    String label,
  ) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: val.value,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
        items: items,
        onChanged: (v) => val.value = v,
      ),
    );
  }

  Widget _buildDatePickerTile(MaintenanceEntryController m, ThemeData theme) {
    return ListTile(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      leading: const Icon(RemixIcons.calendar_event_line),
      title: const Text('Data do Serviço'),
      subtitle: Text(DateFormat('dd/MM/yyyy').format(DateTime.now())),
      onTap: () => m.selecionarData(Get.context!),
    );
  }

  Widget _buildInputField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    ThemeData theme, {
    bool isText = true,
    bool isBold = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isText ? TextInputType.text : TextInputType.number,
      style: TextStyle(
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: theme.colorScheme.primary),
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildNotesField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    ThemeData theme, {
    bool isText = true,
    bool isBold = false,
    bool maxLength = false,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLength: 50,
      keyboardType: isText ? TextInputType.text : TextInputType.number,
      style: TextStyle(
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: theme.colorScheme.primary),
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildReminderSection(MaintenanceEntryController m, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(RemixIcons.notification_4_line, size: 20),
            const SizedBox(width: 8),
            Text(
              'mt_reminder'.tr,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Obx(
          () => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ativar alerta de manutenção'),
            value: m.lembreteAtivo.value,
            onChanged: (v) => m.lembreteAtivo.value = v,
          ),
        ),
        if (m.lembreteAtivo.value) ...[
          const SizedBox(height: 10),
          _buildCard(theme, [
            _buildInputField(
              m.lembreteKmController,
              'Lembrar com (km)',
              RemixIcons.speed_up_line,
              theme,
            ),
            _buildLembreteDate(m, theme),
          ]),
        ],
      ],
    );
  }

  Widget _buildLembreteDate(MaintenanceEntryController m, ThemeData theme) {
    return ListTile(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      leading: const Icon(RemixIcons.calendar_event_line),
      title: const Text('Lembrete por KM'),
      subtitle: Text(DateFormat('dd/MM/yyyy').format(DateTime.now())),
      onTap: () => m.selecionarLembrete(Get.context!),
    );
  }
}
