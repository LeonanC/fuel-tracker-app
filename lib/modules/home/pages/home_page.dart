import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/global/fuel_alert_card.dart';
import 'package:fuel_tracker_app/data/global/fuel_list_filter_menu.dart';
import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/modules/about/pages/about_screen.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          _buildHeader(),
          FuelAlertCard(),
          _buildSearchBar(theme),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.setupFuelStream(),
              color: theme.colorScheme.primary,
              backgroundColor: theme.cardColor,
              child: _buildListaFuels(theme),
            ),
          ),
        ],
      ),

      floatingActionButton: _buildFAB(context, theme),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              ),
              child: TextField(
                onChanged: (value) => controller.searchText.value = value,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: "hp_buscar_hint".tr,
                  hintStyle: TextStyle(
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.4),
                  ),
                  prefixIcon: Icon(
                    RemixIcons.search_2_line,
                    color: Colors.blueAccent,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context, ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () => controller.navigateToAddEntry(context),
      backgroundColor: Colors.blueAccent,
      icon: Icon(RemixIcons.gas_station_line),
      label: Text(
        'Novo registro',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Map<String, List<FuelEntryModel>> _agruparFuelPorData(
    List<FuelEntryModel> fuels,
  ) {
    Map<String, List<FuelEntryModel>> grupos = {};

    for (var fuel in fuels) {
      String dataFormatada;
      DateTime hoje = DateTime.now();
      DateTime dataFuel = fuel.entryDate;

      if (DateFormat('yyyy-MM-dd').format(dataFuel) ==
          DateFormat('yyyy-MM-dd').format(hoje)) {
        dataFormatada = "Hoje";
      } else if (DateFormat('yyyy-MM-dd').format(dataFuel) ==
          DateFormat(
            'yyyy-MM-dd',
          ).format(hoje.subtract(const Duration(days: 1)))) {
        dataFormatada = "Ontem";
      } else {
        dataFormatada = DateFormat('dd MMMM', 'pt_BR').format(dataFuel);
      }

      if (grupos[dataFormatada] == null) grupos[dataFormatada] = [];
      grupos[dataFormatada]!.add(fuel);
    }
    return grupos;
  }

  Widget _buildListaFuels(ThemeData theme) {
    return Obx(() {
      if (controller.isLoading.value) return _buildShimmerList(theme);

      final entries = controller.filteredFuelEntries;
      if (entries.isEmpty) return _buildEmptyState(theme);

      final fuelAgrupadas = _agruparFuelPorData(entries);
      final categorias = fuelAgrupadas.keys.toList();

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          final fuelsDaCategoria = fuelAgrupadas[categoria]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(theme, categoria),
              ...fuelsDaCategoria.map((fuel) {
                double consumption = 0.0;
                if (fuel.tankFull == true &&
                    index + 1 < fuelsDaCategoria.length) {
                  FuelEntryModel previousEntry = fuelsDaCategoria[index + 1];

                  consumption = fuel.calculateConsumption(previousEntry);
                }
                return _buildFuelCard(context, theme, fuel, consumption);
              }),
            ],
          );
        },
      );
    });
  }

  Widget _buildDateHeader(ThemeData theme, String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8, left: 4),
      child: Text(
        titulo.toUpperCase(),
        style: TextStyle(
          color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildShimmerList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: theme.cardColor,
        highlightColor: theme.highlightColor,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(),
    );
  }

  Widget _buildHeader() {
    return Obx(() {
      final avgCons = controller.gastoPorKmReal;
      final avgCost = controller.averageCostPerKm;

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildStatRow(
              icon: RemixIcons.calculator_line,
              iconColor: Colors.blueAccent,
              label: "Consumo",
              value: controller.settingsController.formatarConsumo(avgCons),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.white10, height: 1),
            ),

            _buildStatRow(
              icon: RemixIcons.gas_station_line,
              iconColor: Colors.orangeAccent,
              label: "Custo por KM",
              value: controller.settingsController.formatarCurrency(
                avgCost / 100,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: iconColor.withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.firaCode(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'hp_titulo'.tr,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w900,
          letterSpacing: 3,
          color: theme.textTheme.titleLarge?.color,
          fontSize: 22,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(RemixIcons.refresh_line),
          tooltip: 'hp_refresh'.tr,
          onPressed: () async {
            Get.snackbar(
              'hp_refreshing'.tr,
              'hp_refreshing_sub'.tr,
              duration: const Duration(seconds: 2),
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            // controller.setupFuelStream();
          },
        ),
        FuelListFilterMenu(),
        IconButton(
          icon: Icon(Icons.info_outline),
          tooltip: 'ab_about'.tr,
          onPressed: () => Get.to(() => AboutScreen()),
        ),
      ],
    );
  }

  Padding _buildVehicleProgress(
    ThemeData theme,
    HomeController controller,
    FuelEntryModel? lastEntry,
  ) {
    String vehicleName = "hp_all_vehicles".tr;
    if (controller.selectedVehicleID.value != null) {
      vehicleName =
          controller.veiculosMap[controller
              .selectedVehicleID
              .value]?['nickname'] ??
          "---";
    } else if (lastEntry != null) {
      vehicleName =
          controller.veiculosMap[lastEntry.vehicleId]?['nickname'] ?? "---";
    }

    final double fuelLevel = lastEntry?.tankCapacity ?? 0.0;
    final double progressValue = (fuelLevel / 100).clamp(0.0, 1.0);
    final bool isLastTankFull = lastEntry?.tankFull ?? false;
    final bool isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'hp_vehicle_label'.tr} $vehicleName',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: isDark
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                '${fuelLevel.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: theme.textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (rect) {
              Color colorEnd;
              if (progressValue < 0.2) {
                colorEnd = Colors.redAccent;
              } else if (progressValue < 0.6) {
                colorEnd = Colors.orangeAccent;
              } else {
                colorEnd = isLastTankFull ? Colors.greenAccent : Colors.orange;
              }
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.redAccent,
                  progressValue > 0.5 ? Colors.orangeAccent : Colors.redAccent,
                  colorEnd,
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(rect);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 10,
                backgroundColor: isDark
                    ? Colors.white10
                    : Colors.black.withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelCard(
    BuildContext context,
    ThemeData theme,
    FuelEntryModel fuel,
    double consumption,
  ) {
    final tipoData = controller.tiposMap[fuel.fuelTypeId];
    final postoData = controller.postosMap[fuel.gasStationId];
    final vehicleData = controller.veiculosMap[fuel.vehicleId];
    final String nomeTipo = tipoData?['nome'] ?? "---";
    final String nomePosto = postoData?['nome'] ?? "---";
    final String nickname = vehicleData?['nickname'] ?? "---";
    final String plate = vehicleData?['plate'] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => controller.navigateToEditEntry(context, fuel),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        nickname,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                    ),
                    Text(
                      'hp_plate_label'.tr,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    if (plate.isNotEmpty)
                      _buildPlateTag(
                        plate,
                        vehicleData?['is_mercosul'] ?? false,
                      ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white10, height: 1),
                ),

                // INFO DE lOCALIZAÇÃO E COMBUSTÍVEL
                Row(
                  children: [
                    Icon(
                      RemixIcons.map_pin_2_fill,
                      size: 16,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        nomePosto,
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildFuelTypeBadge(nomeTipo),
                  ],
                ),

                const SizedBox(height: 16),

                // GRID DE DADOS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      theme,
                      RemixIcons.dashboard_3_line,
                      "hp_odometro".tr,
                      controller.settingsController.formatarDistancia(
                        fuel.odometerKm,
                      ),
                    ),
                    _buildStatItem(
                      theme,
                      RemixIcons.drop_line,
                      "hp_volume".tr,
                      controller.settingsController.formatarVolume(
                        fuel.volumeLiters,
                      ),
                    ),
                    if (consumption > 0)
                      _buildConsumptionIndicator(consumption)
                    else if (fuel.tankFull == true)
                      _buildStatItem(
                        theme,
                        RemixIcons.gas_station_fill,
                        'hp_tanque_cheio'.tr,
                        'hp_tanque_cheio'.tr,
                        color: Colors.orange,
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "hp_preco_litro".tr,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: theme.textTheme.bodyLarge?.color,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            controller.settingsController.formatarCurrency(
                              fuel.pricePerLiter,
                            ),
                            style: GoogleFonts.firaCode(
                              color: theme.textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'hp_custo_total'.tr,
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            controller.settingsController.formatarCurrency(
                              fuel.totalCost,
                            ),
                            style: GoogleFonts.inter(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlateTag(String plate, bool isMercosul) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMercosul)
            Container(
              width: 12,
              height: 8,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: Colors.blue[900],
                borderRadius: BorderRadius.circular(1),
              ),
              child: Center(
                child: Icon(Icons.public, size: 6, color: Colors.white),
              ),
            ),
          Text(
            plate.toUpperCase(),
            style: GoogleFonts.robotoMono(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelTypeBadge(String text) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color ?? Colors.blueGrey),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            color: theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildConsumptionIndicator(double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Text(
        controller.settingsController.formatarConsumo(value),
        style: GoogleFonts.inter(
          color: Colors.greenAccent,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
