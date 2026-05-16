import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/data/models/station_model.dart';
import 'package:fuel_tracker_app/modules/gas/controller/station_controller.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class StationEntryController extends GetxController {
  final controller = Get.find<StationController>();
  final formKey = GlobalKey<FormState>();

  StationModel? editingEntry;

  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController brandController;
  late MoneyMaskedTextController priceGAController;
  late MoneyMaskedTextController priceETAController;
  late MoneyMaskedTextController priceDIEController;
  late MoneyMaskedTextController priceGNController;
  late MoneyMaskedTextController latitudeController;
  late MoneyMaskedTextController longitudeController;

  var hasConvenienceStore = false.obs;
  var is24Hours = false.obs;
  var isLocationLoading = false.obs;
  var isLoading = false.obs;

  @override
  void onInit(){
    super.onInit();
    final StationModel? argEntry = Get.arguments;
    inicializer(argEntry);
  }

  void inicializer(StationModel? entry) {
    const int coordPrecision = 7;
    editingEntry = entry;
    final isEditing = entry != null;

    nameController = TextEditingController(
      text: isEditing ? entry.nome.toString() : '',
    );
    addressController = TextEditingController(
      text: isEditing ? entry.address.toString() : '',
    );
    brandController = TextEditingController(
      text: isEditing ? entry.brand.toString() : '',
    );

    priceGAController = MoneyMaskedTextController(
      initialValue: isEditing ? entry.precoGasolina : 0,
      decimalSeparator: '.',
      thousandSeparator: '',
      precision: 2,
    );
    priceETAController = MoneyMaskedTextController(
      initialValue: isEditing ? entry.precoEtanol : 0,
      decimalSeparator: '.',
      thousandSeparator: '',
      precision: 2,
    );
    priceDIEController = MoneyMaskedTextController(
      initialValue: isEditing ? entry.precoDiesel : 0,
      decimalSeparator: '.',
      thousandSeparator: '',
      precision: 2,
    );
    priceGNController = MoneyMaskedTextController(
      initialValue: isEditing ? entry.precoGnv : 0,
      decimalSeparator: '.',
      thousandSeparator: '',
      precision: 2,
    );
    latitudeController = MoneyMaskedTextController(
      initialValue: isEditing ? entry.latitude : 0,
      decimalSeparator: '.',
      thousandSeparator: '',
      precision: coordPrecision,
      leftSymbol: '-',
    );
    longitudeController = MoneyMaskedTextController(
      initialValue: isEditing ? entry.longitude : 0,
      decimalSeparator: '.',
      thousandSeparator: '',
      precision: coordPrecision,
      leftSymbol: '-',
    );

    if (isEditing) {
      hasConvenienceStore.value = entry.hasConvenientStore;
      is24Hours.value = entry.is24Hours;
    } else {
      hasConvenienceStore.value = false;
      is24Hours.value = false;
    }
  }

  Future<void> fetchLocation() async {
    isLocationLoading.value = true;
    final result = await controller.getCurrentAddress();
    if (result.containsValue('error')) {
      _showSnackbar("Erro", result['error'], isError: true);
    } else {
      addressController.text = result['address'];
      latitudeController.text = result['latitude'].toString();
      longitudeController.text = result['longitude'].toString();
    }
    isLocationLoading.value = false;
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final stationData = {
        'nome': nameController.text.trim(),
        'endereco': addressController.text.trim(),
        'brand': brandController.text.trim(),
        'latitude': latitudeController.numberValue,
        'longitude': longitudeController.numberValue,
        'preco_gasolina': priceGAController.numberValue,
        'preco_etanol': priceETAController.numberValue,
        'preco_diesel': priceDIEController.numberValue,
        'preco_gnv': priceGNController.numberValue,
        'has_convenient_store': hasConvenienceStore.value,
        'is_24_hours': is24Hours.value,
      };

      if (editingEntry != null) {
        final updatedModel = StationModel.fromMap(stationData, editingEntry!.id!);
        await controller.updatePosto(updatedModel);
      } else {
        await controller.savePosto(stationData);
      }

      Get.back(result: true);
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Erro',
        'Posto adicionado com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
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
