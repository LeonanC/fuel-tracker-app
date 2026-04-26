import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/data/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/data/controllers/lookup_controller.dart';
import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remixicon/remixicon.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeEntryController extends GetxController {
  final controller = Get.find<HomeController>();
  final settingsController = Get.find<SettingController>();
  final lookupController = Get.find<LookupController>();
  final currencyController = Get.find<CurrencyController>();
  final _supabase = Supabase.instance.client;

  final formKey = GlobalKey<FormState>();

  var selectedGas = RxnString();
  var selectedVeiculos = RxnString();
  var selectedStations = RxnString();
  var selectedDate = DateTime.now().obs;
  var isTankFull = false.obs;
  var comprovantePath = ''.obs;
  var isLoading = false.obs;

  FuelEntryModel? editingEntry;

  late MoneyMaskedTextController pricePerLiterController;
  late MoneyMaskedTextController totalPriceController;
  late MoneyMaskedTextController litrosController;
  late TextEditingController kmController;

  void inicializar(FuelEntryModel? entry, double? lastOdometer) {
    editingEntry = entry;

    pricePerLiterController = MoneyMaskedTextController(
      initialValue: entry?.pricePerLiter ?? 0.0,
      leftSymbol: 'R\$',
    );

    totalPriceController = MoneyMaskedTextController(
      initialValue: entry?.totalCost ?? 0.0,
      leftSymbol: 'R\$',
    );

    kmController = TextEditingController(
      text: entry != null
          ? entry.odometerKm.toString()
          : (lastOdometer?.toString() ?? ''),
    );

    litrosController = MoneyMaskedTextController(
      initialValue: entry?.volumeLiters ?? 0.0,
      leftSymbol: '',
      precision: 1,
    );

    if (entry != null) {
      selectedGas.value = entry.fuelTypeId;
      selectedVeiculos.value = entry.vehicleId;
      selectedStations.value = entry.gasStationId;
      isTankFull.value = entry.tankFull;
      selectedDate.value = entry.entryDate!;
      comprovantePath.value = entry.receiptPath ?? '';
    }

    litrosController.addListener(() => _calcularLitros(from: 'litros'));
    pricePerLiterController.addListener(() => _calcularLitros(from: 'preco'));
    totalPriceController.addListener(() => _calcularLitros(from: 'total'));
  }

  void _calcularLitros({required String from}) {
    final double l = litrosController.numberValue;
    final double p = pricePerLiterController.numberValue;
    final double t = totalPriceController.numberValue;

    if (from == 'litros' || from == 'preco') {
      if (l > 0 && p > 0) {
        totalPriceController.updateValue(l * p);
      }
    } else if (from == 'total') {
      if (t > 0 && l > 0) {
        pricePerLiterController.updateValue(t / l);
      }
    }
  }

  Future<void> selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'SELECIONE A DATA DO ABASTECIMENTO',
      cancelText: 'CANCELAR',
      confirmText: 'PRÓXIMO',
    );

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate.value),
        helpText: 'HORA DO ABASTECIMENTO',
        cancelText: 'CANCELAR',
        confirmText: 'OK',
      );

      if (pickedTime != null) {
        selectedDate.value = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }

    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
    }
  }

  void atualizarHodometroPorVeiculo(String? vehicleId) {
    if (vehicleId == null) return;
    final v = controller.vehicles.firstWhereOrNull(
      (element) => element.id == vehicleId,
    );
    if (v != null && editingEntry == null) {
      kmController.text = v.initialOdometer.toString();
    }
  }

  Future<void> pickComprovante() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      comprovantePath.value = pickedFile.path;

      _showSnackbar(
        'Comprovante Selecionado',
        'he_snackbar_receipt_selected_prefix'.tr,
      );
    }
  }

  Future<String?> _processarUpload() async {
    if (comprovantePath.value.isEmpty ||
        comprovantePath.value.startsWith('http')) {
      return comprovantePath.value;
    }

    try {
      final file = File(comprovantePath.value);
      final fileName = 'recibo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'recibos/$fileName';

      await _supabase.storage
          .from('fotos_perfil')
          .upload(
            path,
            file,
            fileOptions: FileOptions(contentType: 'image/jpeg', upsert: true),
          );

      return _supabase.storage.from('fotos_perfil').getPublicUrl(path);
    } catch (e) {
      debugPrint("Erro upload: $e");
      return null;
    }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw "Sessão expirada";

      String? remoteUrl = await _processarUpload();

      final fuelData = {
        'fk_usuario': userId,
        'fk_veiculo': selectedVeiculos.value,
        'fk_tipo': selectedGas.value,
        'fk_posto': selectedStations.value,
        'data': selectedDate.value.toIso8601String(),
        'velocimetro': double.tryParse(kmController.text) ?? 0.0,
        'litros_volume': litrosController.numberValue,
        'preco_litro': pricePerLiterController.numberValue,
        'custo_total': totalPriceController.numberValue,
        'tanque_cheio': isTankFull.value,
        'receipt_path': remoteUrl,
      };

      if (editingEntry != null) {
        final updatedModel = FuelEntryModel.fromMap(
          fuelData,
          editingEntry!.id!,
        );
        await controller.updateFuel(updatedModel);
        await controller.updateVehicleOdometer(
          selectedVeiculos.value!,
          double.tryParse(kmController.text) ?? 0.0,
        );
      } else {
        await controller.saveFuel(fuelData);
        await controller.updateVehicleOdometer(
          selectedVeiculos.value!,
          double.tryParse(kmController.text) ?? 0.0,
        );
      }

      Get.back(result: true);
    } catch (e) {
      Get.back();
      _showSnackbar('Erro', e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
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

  @override
  void onClose() {
    kmController.dispose();
    litrosController.dispose();
    pricePerLiterController.dispose();
    totalPriceController.dispose();
    super.onClose();
  }
}
