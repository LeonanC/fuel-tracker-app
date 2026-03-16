import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/data/controllers/lookup_controller.dart';
import 'package:fuel_tracker_app/data/models/vehicle_model.dart';
import 'package:fuel_tracker_app/modules/vehicle/controller/vehicle_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class VehicleEntryController extends GetxController {
  final controller = Get.find<VehicleController>();
  final lookupController = Get.find<LookupController>();
  final formKey = GlobalKey<FormState>();

  late TextEditingController nicknameController;
  late TextEditingController makeController;
  late TextEditingController modelController;
  late TextEditingController plateController;
  late TextEditingController yearController;
  late MoneyMaskedTextController tankCapacityController;
  late MoneyMaskedTextController odometerController;
  late TextEditingController cityController;

  var selectedImageUrl = ''.obs;
  var isLoading = false.obs;
  var isMercosul = false.obs;
  var selectedTipo = RxnInt();

  VehicleModel? editingEntry;

  void inicializer(VehicleModel? entry) {
    editingEntry = entry;
    final isEditing = entry != null;

    nicknameController = TextEditingController(
      text: isEditing ? entry.nickname.toString() : '',
    );
    makeController = TextEditingController(
      text: isEditing ? entry.make.toString() : '',
    );
    modelController = TextEditingController(
      text: isEditing ? entry.model.toString() : '',
    );
    yearController = TextEditingController(
      text: isEditing ? entry.year.toString() : '',
    );
    plateController = TextEditingController(
      text: isEditing ? entry.plate.toString() : '',
    );

    plateController.addListener(() => update());

    tankCapacityController = MoneyMaskedTextController(
      initialValue: isEditing ? entry.tankCapacity : 0,
      decimalSeparator: ',',
      thousandSeparator: '',
      precision: 1,
    );
    odometerController = MoneyMaskedTextController(
      initialValue: isEditing ? entry.initialOdometer : 0,
      decimalSeparator: ',',
      thousandSeparator: '',
      precision: 1,
    );
    cityController = TextEditingController(text: isEditing ? entry.city : '');

    if (isEditing) {
      selectedTipo.value = entry.fuelType;
      selectedImageUrl.value = entry.imageUrl.toString();
      isMercosul.value = entry.isMercosul;
    } else {
      selectedTipo.value = 1;
      selectedImageUrl.value = '';
      isMercosul.value = false;
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        selectedImageUrl.value = pickedFile.path;
        Get.snackbar('Imagem Selecionada', 'Imagem Selecionada com sucesso');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao selecionar imagem: $e');
    }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final DateTime dataCriacao = editingEntry?.createdAt ?? DateTime.now();

      final Map<String, dynamic> vehicleData = {
        'pk_vehicle': editingEntry?.id,
        'nickname': nicknameController.text,
        'make': makeController.text,
        'model': modelController.text,
        'year': int.tryParse(yearController.text) ?? dataCriacao.year,
        'plate': plateController.text.toUpperCase(),
        'tank_capacity': tankCapacityController.numberValue,
        'initial_odometer': odometerController.numberValue,
        'imagem_url': selectedImageUrl.value,
        'is_mercosul': isMercosul.value,
        'city': cityController.text,
        'fk_type_fuel': selectedTipo.value,
        'created_at': dataCriacao,
      };

      if (editingEntry != null) {
        final updatedModel = VehicleModel.fromFirestore(
          vehicleData,
          editingEntry!.id!,
        );
        await controller.updateVeiculo(updatedModel);
      } else {
        await controller.saveVeiculo(vehicleData);
      }

      Get.back();
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Erro',
        'Falha ao salvar o veículo: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
