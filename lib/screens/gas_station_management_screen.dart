import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/models/gas_station_model.dart';
import 'package:fuel_tracker_app/controllers/gas_station_controller.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:uuid/uuid.dart';

class GasStationManagementScreen extends GetView<GasStationController> {
  GasStationManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<GasStationController>()) {
      Get.put(GasStationController());
    }
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
      appBar: AppBar(
        title: Text(context.tr(TranslationKeys.gasStationScreenTitle).tr),
        backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
        elevation: theme.appBarTheme.elevation,
        centerTitle: theme.appBarTheme.centerTitle,
      ),
      body: Obx(() {
        final stations = controller.stations;

        if (stations.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(RemixIcons.gas_station_line, size: 64, color: AppTheme.textGrey),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum Posto cadastrado.'.tr,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium!.copyWith(color: AppTheme.textGrey),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: stations.length,
          itemBuilder: (context, index) {
            final gasStation = stations[index];
            return PostoCard(stations: gasStation);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'gas_station_tag',
        onPressed: () => _showGasForm(context),
        backgroundColor: AppTheme.primaryFuelColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

void _showGasForm(BuildContext context, [GasStationModel? stations]) {
  Get.dialog(StationForm(station: stations), useSafeArea: true, barrierDismissible: true);
}

class PostoCard extends StatelessWidget {
  final GasStationModel stations;

  const PostoCard({super.key, required this.stations});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: Icon(RemixIcons.gas_station_fill, color: AppTheme.primaryFuelColor, size: 32),
        title: Text(stations.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bandeira: ${stations.brand}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(RemixIcons.gas_station_fill, size: 16, color: AppTheme.primaryFuelColor),
                const SizedBox(width: 4),
                Flexible(child: Text('G: ${stations.priceGasolineComum}')),
                const SizedBox(width: 12),
                Icon(RemixIcons.flask_fill, size: 16, color: AppTheme.primaryFuelColor),
                const SizedBox(width: 4),
                Flexible(child: Text('E: ${stations.priceEthanol}')),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (String result) {
            if (result == 'edit') {
              _showGasForm(context, stations);
            } else if (result == 'delete') {
              _confirmDelete(context);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(value: 'edit', child: Text('Editar')),
            const PopupMenuItem<String>(value: 'delete', child: Text('Excluir')),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final controller = Get.find<GasStationController>();

    Get.defaultDialog(
      title: context.tr(TranslationKeys.gasStationButtonDelete),
      middleText: context.tr(TranslationKeys.gasStationButtonDeleteSubtitle),
      textConfirm: context.tr(TranslationKeys.gasStationButtonDeleteConfirm),
      textCancel: context.tr(TranslationKeys.gasStationButtonDeleteCancel),
      confirmTextColor: AppTheme.cardLight,
      onConfirm: () {
        controller.deleteGasStation(stations.id);
        Get.back();
      },
      onCancel: () => Get.back(),
      buttonColor: AppTheme.primaryFuelColor,
      cancelTextColor: AppTheme.primaryFuelAccent,
    );
  }
}

class StationForm extends StatefulWidget {
  final GasStationModel? station;
  const StationForm({super.key, this.station});

  @override
  State<StationForm> createState() => _StationFormState();
}

class _StationFormState extends State<StationForm> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController brandController;
  late MoneyMaskedTextController latitudeController;
  late MoneyMaskedTextController longitudeController;
  late MoneyMaskedTextController priceGasolineController;
  late MoneyMaskedTextController priceEthanolController;

  final GasStationController controller = Get.find<GasStationController>();
  bool hasConvenienceStore = false;
  bool is24Hours = false;
  bool isLocationLoading = false;

  bool get isEditing => widget.station != null;

  Future<void> getCurrentLocation(BuildContext context) async {
    isLocationLoading = true;

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Erro', 'Serviços de localização desabilitados.');
      isLocationLoading = false;
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Erro', 'Permissão de localização negada.');
        isLocationLoading = false;
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Erro',
        'Permissão negada permanentemente. Por favor, habilite nas configurações do app.',
        snackPosition: SnackPosition.BOTTOM,
      );
      isLocationLoading = false;
      return;
    }

    try {
      Get.snackbar('Aguarde', 'Obtendo sua localização...');

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String formattedAddress = "Endereço não encontrado.";
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        formattedAddress = [
          placemark.thoroughfare,
          placemark.subThoroughfare,
          placemark.subLocality,
          placemark.locality,
        ].where((element) => element != null && element.isNotEmpty).join(', ');
      }

      setState(() {
        latitudeController.updateValue(position.latitude);
        longitudeController.updateValue(position.longitude);
        addressController.text = formattedAddress;
      });

      Get.snackbar('Sucesso', 'Localização atualizada com sucesso!');
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível obter a localização: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    } finally {
      isLocationLoading = false;
    }
  }

  @override
  void initState() {
    super.initState();

    const int coordinatePrecision = 7;

    if (isEditing) {
      final s = widget.station!;
      nameController = TextEditingController(text: s.nome);
      addressController = TextEditingController(text: s.address ?? '');
      brandController = TextEditingController(text: s.brand);
      latitudeController = MoneyMaskedTextController(
        initialValue: s.latitude,
        decimalSeparator: '.',
        thousandSeparator: '',
        precision: coordinatePrecision,
        leftSymbol: '-',
      );
      longitudeController = MoneyMaskedTextController(
        initialValue: s.longitude,
        decimalSeparator: '.',
        thousandSeparator: '',
        precision: coordinatePrecision,
        leftSymbol: '-',
      );
      priceGasolineController = MoneyMaskedTextController(
        initialValue: s.priceGasolineComum,
        decimalSeparator: ',',
        thousandSeparator: '.',
      );
      priceEthanolController = MoneyMaskedTextController(
        initialValue: s.priceEthanol,
        decimalSeparator: ',',
        thousandSeparator: '.',
      );
      hasConvenienceStore = s.hasConvenientStore;
      is24Hours = s.is24Hours;
    } else {
      nameController = TextEditingController();
      addressController = TextEditingController();
      brandController = TextEditingController();
      latitudeController = MoneyMaskedTextController(
        decimalSeparator: '.',
        thousandSeparator: '',
        precision: coordinatePrecision,
        leftSymbol: '-',
      );
      longitudeController = MoneyMaskedTextController(
        decimalSeparator: '.',
        thousandSeparator: '',
        precision: coordinatePrecision,
        leftSymbol: '-',
      );
      priceGasolineController = MoneyMaskedTextController(
        leftSymbol: 'R\$ ',
        decimalSeparator: ',',
        thousandSeparator: '.',
      );
      priceEthanolController = MoneyMaskedTextController(
        leftSymbol: 'R\$ ',
        decimalSeparator: ',',
        thousandSeparator: '.',
      );
      hasConvenienceStore = false;
      is24Hours = false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    brandController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    priceGasolineController.dispose();
    priceEthanolController.dispose();
    super.dispose();
  }

  void _submit() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      final stationId = widget.station?.id ?? const Uuid().v4();

      final GasStationModel newStation = GasStationModel(
        id: stationId,
        nome: nameController.text.trim(),
        address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
        brand: brandController.text.trim(),
        latitude: latitudeController.numberValue,
        longitude: longitudeController.numberValue,
        priceGasolineComum: priceGasolineController.numberValue,
        priceGasolineAditivada: priceGasolineController.numberValue,
        priceGasolinePremium: priceGasolineController.numberValue,
        priceEthanol: priceEthanolController.numberValue,
        hasConvenientStore: hasConvenienceStore,
        is24Hours: is24Hours,
      );

      try {
        controller.saveStation(newStation);
        Get.back();
        Get.snackbar(
          'Sucesso',
          'Posto "${newStation.nome}" adicionado com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
        );

        
      } catch (e) {
        Get.back();
        Get.snackbar(
          'Erro',
          'Posto "${newStation.nome}" adicionado com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.station != null;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        context.tr(
          isEditing ? TranslationKeys.gasStationUpdateTitle : TranslationKeys.gasStationAddTitle,
        ),
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineSmall,
      ),
      content: SizedBox(
        width: Get.width * 0.9,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: context.tr(TranslationKeys.gasStationLabelName),
                    hintText: 'Ex: Posto Amarelo',
                  ),
                  validator: (value) => value!.isEmpty ? context.tr('Campo obrigatório') : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: context.tr(TranslationKeys.gasStationLabelAddress),
                    hintText: 'Ex: Av. Principal, 123',
                  ),
                  validator: (value) => value!.isEmpty ? context.tr('Campo obrigatório') : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: brandController,
                  decoration: InputDecoration(
                    labelText: context.tr(TranslationKeys.gasStationLabelBrand),
                    hintText: 'Ex: Ipiranga, Shell',
                  ),
                  validator: (value) => value!.isEmpty ? context.tr('Campo obrigatório') : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: latitudeController,
                  decoration: InputDecoration(
                    labelText: context.tr(TranslationKeys.gasStationLabelLatitude),
                    hintText: 'Ex: -23.6789',
                    suffixIcon: IconButton(
                      icon: isLocationLoading
                          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator())
                          : Icon(RemixIcons.user_location_line, size: 20),
                      onPressed: isLocationLoading ? null : () => getCurrentLocation(context),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? context.tr('Campo obrigatório') : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: longitudeController,
                  decoration: InputDecoration(
                    labelText: context.tr(TranslationKeys.gasStationLabelLongitude),
                    hintText: 'Ex: -46.12345',
                  ),
                  validator: (value) => value!.isEmpty ? context.tr('Campo obrigatório') : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceGasolineController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: context.tr(TranslationKeys.gasStationLabelPriceGasoline),
                    hintText: 'Ex: R\$ 5,99',
                  ),
                  validator: (value) => value!.isEmpty ? context.tr('Campo obrigatório') : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceEthanolController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: context.tr(TranslationKeys.gasStationLabelPriceEthanol),
                    hintText: 'Ex: R\$ 3,99',
                  ),
                  validator: (value) => value!.isEmpty ? context.tr('Campo obrigatório') : null,
                ),
                const SizedBox(height: 10),
                _buildSwitchTile(
                  context: context,
                  icon: RemixIcons.store_2_fill,
                  label: context.tr(TranslationKeys.gasStationLabelConvenienceStore),
                  value: hasConvenienceStore,
                  onChanged: (newValue) {
                    setState(() {
                      hasConvenienceStore = newValue;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildSwitchTile(
                  context: context,
                  icon: RemixIcons.time_fill,
                  label: context.tr(TranslationKeys.gasStationLabel24Hours),
                  value: is24Hours,
                  onChanged: (newValue) {
                    setState(() {
                      is24Hours = newValue;
                    });
                  },
                ),
                // const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(context.tr(TranslationKeys.gasStationButtonCancel)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryFuelColor,
            foregroundColor: AppTheme.cardLight,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(
            isEditing
                ? context.tr(TranslationKeys.gasStationUpdateTitle)
                : context.tr(TranslationKeys.gasStationAddTitle),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: value ? AppTheme.primaryFuelColor : Theme.of(context).colorScheme.onSurface,
              size: 28,
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  // fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: value
                      ? AppTheme.primaryFuelColor
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: value ? AppTheme.primaryFuelColor : Theme.of(context).colorScheme.onSurface,
        ),
      ],
    );
  }
}
