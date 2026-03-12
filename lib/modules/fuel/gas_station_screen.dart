import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker_app/core/app_theme.dart';
import 'package:fuel_tracker_app/data/models/gas_station_model.dart';
import 'package:fuel_tracker_app/data/services/application.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/gasStation_controller.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class GasStationScreen extends GetView<GasStationController> {
  const GasStationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010101),
      appBar: AppBar(
        title: const Text('Gerenciar Postos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        final postos = controller.postosMap.values.toList();

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: postos.length,
          itemBuilder: (context, index) {
            final posto = postos[index];
            return Dismissible(
              key: Key(posto['pk_posto'].toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20.w),
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(RemixIcons.delete_bin_line, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                return await Get.dialog<bool>(
                  AlertDialog(
                    backgroundColor: AppTheme.cardDark,
                    title: const Text(
                      "Excluir Posto",
                      style: TextStyle(color: Colors.white),
                    ),
                    content: Text("Deseja realmente remover ${posto['nome']}?"),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text("Cancelar"),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        child: const Text(
                          "Excluir",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direction) {
                controller.deletePosto(posto['pk_posto']);
              },
              child: _buildPostoCard(posto),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryFuelColor,
        onPressed: () => _showEditDialog(context),
        child: Icon(RemixIcons.add_line, color: Colors.black),
      ),
    );
  }

  Widget _buildPostoCard(Map<String, dynamic> posto) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Icon(RemixIcons.gas_station_fill, color: Colors.blue),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      posto['nome'] ?? 'Sem nome',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      posto['brand'] ?? 'Bandeira não informada',
                      style: TextStyle(color: Colors.white60, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${doubleToCurrency(posto['preco'])}',
                    style: TextStyle(
                      color: AppTheme.primaryFuelColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(RemixIcons.edit_line, color: Colors.white54),
                    onPressed: () =>
                        _showEditDialog(Get.context!, posto: posto),
                  ),
                ],
              ),
            ],
          ),
          Divider(color: Colors.white10, height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      RemixIcons.map_pin_2_line,
                      size: 14.sp,
                      color: Colors.white30,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        posto['endereco'] ?? 'Endereco não disponível',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (posto['hasConvenientStore'] == true)
                    Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: Icon(
                        RemixIcons.shopping_basket_2_line,
                        size: 16.sp,
                        color: Colors.greenAccent,
                      ),
                    ),
                  if (posto['is24Hours'] == true)
                    Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: Icon(
                        RemixIcons.time_line,
                        size: 16.sp,
                        color: Colors.orangeAccent,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, {Map<String, dynamic>? posto}) {
    final nomeController = TextEditingController(text: posto?['nome']);
    final precoController = TextEditingController(
      text: posto?['preco']?.toString(),
    );
    final brandController = TextEditingController(text: posto?['brand']);
    final enderecoController = TextEditingController(text: posto?['endereco']);
    final latController = TextEditingController(
      text: posto?['latitude']?.toString(),
    );
    final lngController = TextEditingController(
      text: posto?['longitude']?.toString(),
    );

    final hasStore = (posto?['hasConvenientStore'] == true).obs;
    final is24h = (posto?['is24Hours'] == true).obs;

    final fuelListController = Get.find<FuelListController>();

    Get.bottomSheet(
      isScrollControlled: true,
      ignoreSafeArea: false,
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Editar Posto',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              _buildTextField(nomeController, 'Nome do Posto', RemixIcons.text),
              SizedBox(height: 12.h),
              _buildTextField(
                precoController,
                'Preço da Gasoline',
                RemixIcons.money_dollar_circle_line,
                isNumber: true,
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                brandController,
                'Bandeira (Ex: Shell, Ipiranga)',
                RemixIcons.flag_line,
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      latController,
                      'Latitude',
                      RemixIcons.compass_discover_line,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildTextField(
                      lngController,
                      'Longitude',
                      RemixIcons.compass_3_line,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              SizedBox(height: 12.h),
              _buildTextField(
                enderecoController,
                'Endereço Completo',
                RemixIcons.map_pin_line,
                isAddress: posto == null,
                onGPSClick: () async {
                  final loc = await controller.getCurrentAddress();
                  latController.text = loc['latitude'].toString();
                  lngController.text = loc['longitude'].toString();
                  enderecoController.text = loc['address'];
                },
              ),
              SizedBox(height: 12.h),
              Obx(
                () => Row(
                  children: [
                    _buildCustomSelectableCard(
                      label: 'Conveniência',
                      icon: RemixIcons.shopping_basket_2_line,
                      isSelected: hasStore.value,
                      onTap: () => hasStore.toggle(),
                    ),
                    SizedBox(width: 12.w),
                    _buildCustomSelectableCard(
                      label: '24 Horas',
                      icon: RemixIcons.time_line,
                      isSelected: is24h.value,
                      onTap: () => is24h.toggle(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryFuelColor,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                  ),
                  onPressed: () async {
                    final novoPosto = GasStationModel(
                      id:
                          int.tryParse(posto?['pk_posto']?.toString() ?? '0') ??
                          0,
                      nome: nomeController.text,
                      brand: brandController.text,
                      address: enderecoController.text,
                      latitude: double.tryParse(latController.text) ?? 0.0,
                      longitude: double.tryParse(lngController.text) ?? 0.0,
                      price: double.parse(precoController.text),
                      hasConvenientStore: hasStore.value,
                      is24Hours: is24h.value,
                    );

                    controller.saveOrUpdate(novoPosto);
                    Get.back();
                  },
                  child: Text(
                    posto == null ? "SALVAR" : "EDITAR",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    bool isAddress = false,
    VoidCallback? onGPSClick,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: AppTheme.primaryFuelColor),
        suffixIcon: isAddress
            ? IconButton(
                icon: Icon(
                  RemixIcons.focus_3_line,
                  color: AppTheme.primaryFuelColor,
                ),
                onPressed: onGPSClick,
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCustomSelectableCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryFuelColor.withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryFuelColor
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryFuelColor : Colors.white38,
                size: 22.sp,
              ),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white38,
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
