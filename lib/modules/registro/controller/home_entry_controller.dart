import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
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
  final lookup = Get.find<LookupController>();
  final settings = Get.find<SettingController>();
  final _supabase = Supabase.instance.client;

  final formKey = GlobalKey<FormState>();

  var selectedGas = RxnString();
  var selectedVeiculos = RxnString();
  var selectedStations = RxnString();
  var selectedDate = DateTime.now().obs;
  var isTankFull = false.obs;
  var comprovantePath = ''.obs;
  var isLoading = false.obs;
  var precoAtual = 0.0.obs;

  FuelEntryModel? editingEntry;
  bool _isCalculating = false;

  late MoneyMaskedTextController pricePerLiterController;
  late MoneyMaskedTextController totalPriceController;
  late MoneyMaskedTextController litrosController;
  late TextEditingController kmController;

  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic>? args = Get.arguments;
    final FuelEntryModel? entry = args?['entry'];
    final double? lastOdometer = args?['lastOdometer'];

    inicializar(entry, lastOdometer);

    ever(selectedStations, (_) => atualizarPrecoCombustivel());
    ever(selectedGas, (_) => atualizarPrecoCombustivel());
  }

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
          : (lastOdometer != null && lastOdometer > 0
                ? lastOdometer.toString()
                : ''),
    );

    litrosController = MoneyMaskedTextController(
      initialValue: entry?.volumeLiters ?? 0.0,
      leftSymbol: '',
      precision: 2,
    );

    if (entry != null) {
      selectedGas.value = entry.fuelTypeId;
      selectedVeiculos.value = entry.vehicleId;
      selectedStations.value = entry.gasStationId;
      selectedDate.value = entry.entryDate!;
    }

    litrosController.addListener(() => _calcularLitros(from: 'litros'));
    pricePerLiterController.addListener(() => _calcularLitros(from: 'preco'));
    totalPriceController.addListener(() => _calcularLitros(from: 'total'));

    pricePerLiterController.addListener(() {
      precoAtual.value = pricePerLiterController.numberValue;
    });
  }

  void _calcularLitros({required String from}) {
    if (_isCalculating) return;
    _isCalculating = true;

    try {
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
    } finally {
      _isCalculating = false;
    }
  }

  Future<void> selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
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
      } else {
        selectedDate.value = picked;
      }
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

  void atualizarPrecoCombustivel() {
    final postoId = selectedStations.value;
    final tipoCombustivelId = selectedGas.value;

    if (postoId == null || tipoCombustivelId == null || editingEntry != null)
      return;

    try {
      final posto = controller.postos.firstWhereOrNull((p) => p.id == postoId);
      final tipoCombustivel = controller.tipos.firstWhereOrNull(
        (p) => p.id == tipoCombustivelId,
      );

      if (posto != null && tipoCombustivel != null) {
        double? precoEncontrado = 0.0;
        final nomeCombustivel = tipoCombustivel.nome.toLowerCase();
        if (nomeCombustivel.contains('gasolina')) {
          precoEncontrado =
              double.tryParse(posto.precoGasolina.toString()) ?? 0.0;
        } else if (nomeCombustivel.contains('etanol') ||
            nomeCombustivel.contains('álcool')) {
          precoEncontrado =
              double.tryParse(posto.precoEtanol.toString()) ?? 0.0;
        } else if (nomeCombustivel.contains('diesel')) {
          precoEncontrado =
              double.tryParse(posto.precoDiesel.toString()) ?? 0.0;
        } else if (nomeCombustivel.contains('gnv')) {
          precoEncontrado = double.tryParse(posto.precoGnv.toString()) ?? 0.0;
        }

        if (precoEncontrado > 0) {
          pricePerLiterController.updateValue(precoEncontrado);
        }
      }
    } catch (e) {
      debugPrint("Erro ao buscar preço do combustível: $e");
    }
  }

  Future<void> submit() async {
    if (selectedVeiculos.value == null ||
        selectedGas.value == null ||
        selectedStations.value == null) {
      _showSnackbar(
        'Campos incompletos',
        'Selecione o veículo, posto e tipo de combustível.',
        isError: true,
      );
      return;
    }
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw "Sessão expirada";

      final String? finalReceiptPath = await _processarUpload();

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
        'receipt_path': finalReceiptPath ?? comprovantePath.value,
      };

      if (editingEntry != null) {
        final updatedModel = FuelEntryModel.fromMap(
          fuelData,
          editingEntry!.id!,
        );
        await controller.updateFuel(updatedModel);
      } else {
        await controller.saveFuel(fuelData);
      }

      await controller.updateVehicleOdometer(
        selectedVeiculos.value!,
        double.tryParse(kmController.text) ?? 0.0,
      );

      Get.back(result: true);
    } catch (e) {
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
