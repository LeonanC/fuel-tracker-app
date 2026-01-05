import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fuel_tracker_app/controllers/map_controller.dart';
import 'package:fuel_tracker_app/models/gas_station_model.dart';
import 'package:fuel_tracker_app/controllers/gas_station_controller.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class MapScreen extends GetView<MapNavigationController> {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MapNavigationController navCtrl = Get.put(MapNavigationController());
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Obx(() {
      final center = controller.currentLocation.value ?? defaultCenter;
      final isNavigation = controller.destinationPoint.value != null;
      final bool loading = controller.isLoading.value || controller.isRouting.value;

      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildTransparentAppBar(context, isNavigation, isDarkMode),
        floatingActionButton: _buildFABs(isNavigation),
        body: Stack(
          children: [
            FlutterMap(
              mapController: navCtrl.mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 15.0,
                interactionOptions: InteractionOptions(
                  flags: navCtrl.isNavigationMode.value
                      ? InteractiveFlag.none
                      : InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: isDarkMode
                      ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'br.com.fuel_tracker_app',
                ),
                if (navCtrl.routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: navCtrl.routePoints.toList(),
                        strokeWidth: 5.0,
                        color: Colors.blueAccent.withOpacity(0.8),
                        borderColor: Colors.blue.shade900,
                        borderStrokeWidth: 2.0,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (navCtrl.currentLocation.value != null)
                      Marker(
                        point: navCtrl.currentLocation.value!,
                        width: 60,
                        height: 60,
                        child: _buildUserMarker(),
                      ),
                    ...navCtrl.stationMarkers.toList(),
                  ],
                ),
              ],
            ),

            if (isNavigation) _buildModernNavigationCard(),
            if (loading) _buildBlurredLoading(),
          ],
        ),
      );
    });
  }

  PreferredSizeWidget _buildTransparentAppBar(BuildContext context, bool isNav, bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(isDark ? 0.7 : 0.3), Colors.transparent],
          ),
        ),
      ),
      title: Text(isNav ? 'Nevagação Ativa' : context.tr(TranslationKeys.navigationMap)),
      actions: [
        if (!isNav) ...[
          _CircleActionButton(
            icon: RemixIcons.user_location_line,
            onPressed: () => controller.determinePosition(),
          ),
          const SizedBox(width: 8),
          _CircleActionButton(icon: RemixIcons.search_line, onPressed: () => _openSearch(context)),
          const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _buildUserMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryFuelColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
        Transform.rotate(
          angle: controller.currentHeading.value * (math.pi / 180),
          child: Icon(RemixIcons.navigation_fill, color: AppTheme.primaryFuelColor, size: 35),
        ),
      ],
    );
  }

  Widget _buildModernNavigationCard() {
    final station = controller.currentDestinationStation.value;
    if (station == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 30),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryFuelColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(RemixIcons.gas_station_fill, color: AppTheme.primaryFuelColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          station.nome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoTile(
                        RemixIcons.pin_distance_line,
                        'Distância',
                        controller.formatDistance(controller.routeDistanceMeters.value),
                      ),
                      _buildInfoTile(
                        RemixIcons.time_line,
                        'Chegada',
                        controller.calculateETA(controller.routeDurationSeconds.value),
                      ),
                      _buildInfoTile(
                        RemixIcons.money_dollar_circle_line,
                        'Gasolina',
                        'R\$ ${station.priceGasolineComum.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlurredLoading() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Container(
        color: Colors.black26,
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(controller.isRouting.value ? 'Calculando Rota...' : 'Buscando Satélites...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFABs(bool isNavigation) {
    return Padding(
      padding: EdgeInsets.only(bottom: isNavigation ? 160 : 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isNavigation)
            FloatingActionButton.small(
              heroTag: 'lock',
              onPressed: controller.toggleNavigationMode,
              backgroundColor: controller.isNavigationMode.value ? Colors.blue : Colors.white,
              child: Icon(
                controller.isNavigationMode.value
                    ? RemixIcons.lock_fill
                    : RemixIcons.lock_unlock_line,
                color: controller.isNavigationMode.value ? Colors.white : Colors.black,
              ),
            ),
          const SizedBox(height: 12),
          if (isNavigation)
            FloatingActionButton(
              heroTag: 'stop',
              onPressed: controller.clearNavigation,
              backgroundColor: Colors.redAccent,
              child: const Icon(RemixIcons.stop_line, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Text(value, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  void _openSearch(BuildContext context) async {
    final result = await showSearch<String>(
      context: context,
      delegate: _FuelSearchDelegate(context),
    );
    if (result != null && result.isNotEmpty) {
      controller.loadStationsFromDB(query: result);
    }
  }
}

class _FuelSearchDelegate extends SearchDelegate<String> {
  final BuildContext _context;
  _FuelSearchDelegate(this._context);

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, ''));

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    final gasCtrl = Get.find<GasStationController>();

    return FutureBuilder<List<GasStationModel>>(
      future: gasCtrl.searchStations(query, returnData: true),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final results = snapshot.data!;

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, i) {
            final s = results[i];
            return ListTile(
              leading: Icon(RemixIcons.gas_station_line),
              title: Text(s.nome),
              subtitle: Text("${s.brand} - R\$ ${s.priceGasolineComum}"),
              onTap: () => close(context, s.nome),
            );
          },
        );
      },
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _CircleActionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}
