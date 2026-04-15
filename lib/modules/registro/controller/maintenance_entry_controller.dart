import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/data/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/data/controllers/lookup_controller.dart';
import 'package:fuel_tracker_app/data/models/maintenance_entry_model.dart';
import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:fuel_tracker_app/modules/maintenance/controler/maintenance_controller.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:get/get.dart';

class MaintenanceEntryController extends GetxController {
  final homeController = Get.find<HomeController>();
  final controller = Get.find<MaintenanceController>();
  final settings = Get.find<SettingController>();
  final lookupController = Get.find<LookupController>();
  final currencyController = Get.find<CurrencyController>();

  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  var selectedService = RxnString();
  var selectedVehicle = RxnString();
  var lastOdometer = Rxn<double>();

  var selectedDate = DateTime.now().obs;
  var selectedLembrete = DateTime.now().obs;
  var lembreteAtivo = false.obs;

  late TextEditingController kmController;
  late MoneyMaskedTextController custoController;
  late TextEditingController observacoesController;
  late TextEditingController lembreteKmController;

  MaintenanceModel? editingEntry;

  void initializar(MaintenanceModel? entry, double? lastOdometer) {
    editingEntry = entry;
    final isEditing = entry != null;

    kmController = TextEditingController(
      text: isEditing
          ? entry.quilometragem.toString()
          : (lastOdometer?.toStringAsFixed(0) ?? ''),
    );

    custoController = MoneyMaskedTextController(
      initialValue: isEditing ? entry.custo : 0,
      decimalSeparator: ',',
      thousandSeparator: '.',
    );

    observacoesController = TextEditingController(
      text: isEditing ? entry.observacoes : '',
    );

    lembreteKmController = TextEditingController(
      text: isEditing ? entry.lembreteKm.toString() : '',
    );

    if (isEditing) {
      selectedService.value = entry.tipoId;
      selectedDate.value = entry.dataServico;
      selectedLembrete.value = entry.lembreteData;
      lembreteAtivo.value = entry.lembreteAtivo;
    } else {
      selectedService.value = '1';
      selectedDate.value = DateTime.now();
      selectedLembrete.value = DateTime.now();
      lembreteAtivo.value = false;
    }
  }

  Future<void> selecionarData(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null) selectedDate.value = date;
  }

  Future<void> selecionarLembrete(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null) selectedDate.value = date;
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final Map<String, dynamic> entryData = {
        'fk_tipo': selectedService.value,
        'data_servico': selectedDate.value,
        'quilometragem': double.tryParse(kmController.text),
        'custo': custoController.numberValue,
        'observacoes': observacoesController.text.trim(),
        'lembrete_ativo': lembreteAtivo.value,
        'lembrete_km': double.tryParse(lembreteKmController.text),
        'lembrete_data': selectedLembrete.value,
        'fk_vehicle': selectedVehicle.value,
      };

      if (editingEntry != null) {
        final updatedModel = MaintenanceModel.fromFirestore(
          entryData,
          editingEntry!.id!,
        );
        await controller.updateMaintenance(updatedModel);
      } else {
        await controller.saveMaintenance(entryData);
      }
      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao salvar manutenção: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    kmController.dispose();
    custoController.dispose();
    observacoesController.dispose();
    lembreteKmController.dispose();

    super.onClose();
  }
}
