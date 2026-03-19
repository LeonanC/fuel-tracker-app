import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/data/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/data/controllers/lookup_controller.dart';
import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class HomeEntryController extends GetxController {
  final controller = Get.find<HomeController>();
  final settingsController = Get.find<SettingController>();
  final lookupController = Get.find<LookupController>();
  final currencyController = Get.find<CurrencyController>();

  final formKey = GlobalKey<FormState>();

  var selectedGas = RxnInt();
  var selectedVeiculos = RxnInt();
  var selectedStations = RxnInt();
  var selectedDate = DateTime.now().obs;
  var isTankFull = false.obs;
  var comprovantePath = ''.obs;
  var isLoading = false.obs;

  late TextEditingController kmController;
  late MoneyMaskedTextController litrosController;
  late MoneyMaskedTextController pricePerLiterController;
  late MoneyMaskedTextController totalPriceController;

  FuelEntryModel? editingEntry;

  void inicializar(FuelEntryModel? entry, double? lastOdometer) {
    editingEntry = entry;
    final isEditing = entry != null;

    kmController = TextEditingController(
      text: isEditing
          ? entry.odometerKm.toString()
          : (lastOdometer?.toStringAsFixed(0) ?? ''),
    );

    litrosController = MoneyMaskedTextController(
      initialValue: isEditing ? entry.volumeLiters : 0,
      // leftSymbol: settingsController.formatarVolume(entry!.volumeLiters),
      decimalSeparator: ',',
      thousandSeparator: '.',
      precision: 2,
    );
    pricePerLiterController = MoneyMaskedTextController(
      initialValue: isEditing ? entry.pricePerLiter : 0,
      // leftSymbol: settingsController.formatarCurrency(entry.pricePerLiter),
      decimalSeparator: ',',
      thousandSeparator: '.',
      precision: 2,
    );
    totalPriceController = MoneyMaskedTextController(
      initialValue: isEditing ? entry.totalCost : 0,
      // leftSymbol: settingsController.formatarCurrency(entry.totalCost),
      decimalSeparator: ',',
      thousandSeparator: '.',
      precision: 2,
    );

    if (isEditing) {
      selectedGas.value = entry.fuelTypeId;
      selectedVeiculos.value = entry.vehicleId;
      selectedStations.value = entry.gasStationId;
      isTankFull.value = entry.tankFull;
      selectedDate.value = entry.entryDate;
      comprovantePath.value = entry.receiptPath ?? '';
    } else {
      selectedStations.value = 1;
      selectedGas.value = 1;
      selectedVeiculos.value = 1;
    }

    litrosController.addListener(() => _calculatePrice(from: 'litros'));
    pricePerLiterController.addListener(() => _calculatePrice(from: 'preco'));
    totalPriceController.addListener(() => _calculatePrice(from: 'total'));
  }

  void _calculatePrice({required String from}) {
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

  void atualizarHodometroPorVeiculo(int? vehicleId) {
    if (vehicleId == null) return;
    double ultimoKm = controller.getLatestOdometerForVehicle(vehicleId);
    kmController.text = ultimoKm.toStringAsFixed(0);
  }

  Future<void> pickComprovante() async {
    final source = await Get.dialog<ImageSource>(
      SimpleDialog(
        title: Text('he_dialog_receipt_title'.tr),
        children: [
          SimpleDialogOption(
            onPressed: () => Get.back(result: ImageSource.camera),
            child: Text('he_dialog_receipt_option_camera'.tr),
          ),
          SimpleDialogOption(
            onPressed: () => Get.back(result: ImageSource.gallery),
            child: Text('he_dialog_receipt_option_gallery'.tr),
          ),
        ],
      ),
    );

    if (source != null) {
      try {
        final XFile? pickedFile = await ImagePicker().pickImage(source: source);
        if (pickedFile != null) {
          comprovantePath.value = pickedFile.path;

          Get.snackbar(
            'Comprovante Selecionado',
            'he_snackbar_receipt_selected_prefix'.tr,
          );
        }
      } catch (e) {
        Get.snackbar('Erro', 'he_snackbar_receipt_error_prefix'.tr);
      }
    }
  }

  Future<void> selecionarData(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) selectedDate.value = date;
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final double vehicleTankCapacity =
          (controller.veiculosMap[selectedVeiculos.value]?['tank_capacity']
              as double?) ??
          0.0;

      final Map<String, dynamic> fuelData = {
        'fk_veiculo': selectedVeiculos.value,
        'fk_tipo': selectedGas.value,
        'fk_posto': selectedStations.value,
        'data': selectedDate.value,
        'velocimetro': double.tryParse(kmController.text) ?? 0.0,
        'litros_volume': litrosController.numberValue,
        'preco_litro': pricePerLiterController.numberValue,
        'custo_total': totalPriceController.numberValue,
        'tanque_cheio': isTankFull.value,
        'tank_capacity': vehicleTankCapacity,
        'receipt_path': comprovantePath.value,
      };

      if (editingEntry != null) {
        final updatedModel = FuelEntryModel.fromFirestore(
          fuelData,
          editingEntry!.id!,
        );
        await controller.updateFuel(updatedModel);
      } else {
        await controller.saveFuel(fuelData);
      }

      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao salvar o abastecimento: $e',
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
    litrosController.dispose();
    pricePerLiterController.dispose();
    totalPriceController.dispose();
    super.onClose();
  }
}
