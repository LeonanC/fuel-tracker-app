import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/data/models/gas_station_model.dart';
import 'package:fuel_tracker_app/modules/gas/controller/gasStation_controller.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class GasEntryController extends GetxController {
  final controller = Get.find<GasStationController>();
  final formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController brandController;
  late MoneyMaskedTextController priceController;
  late MoneyMaskedTextController latitudeController;
  late MoneyMaskedTextController longitudeController;

  var hasConvenienceStore = false.obs;
  var is24Hours = false.obs;
  var isLocationLoading = false.obs;
  var isLoading = false.obs;

  GasStationModel? editingEntry;

  void inicializer(GasStationModel? entry) {
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

    priceController = MoneyMaskedTextController(
      initialValue: isEditing ? entry.price : 0,
      decimalSeparator: '.',
      thousandSeparator: '',
      precision: 3,
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

    isLoading.value = true;

    try {
      final stationData = GasStationModel(
        id: editingEntry?.id,
        nome: nameController.text.trim(),
        address: addressController.text.trim(),
        brand: brandController.text.trim(),
        latitude: latitudeController.numberValue,
        longitude: longitudeController.numberValue,
        price: priceController.numberValue,
        hasConvenientStore: hasConvenienceStore.value,
        is24Hours: is24Hours.value,
      );

      if (editingEntry != null) {
        await controller.updatePosto(stationData);
      } else {
        await controller.savePosto(stationData.toMap());
      }
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
