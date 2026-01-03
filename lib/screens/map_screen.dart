import 'dart:math' as math;

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
        backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
        appBar: AppBar(
          backgroundColor: isDarkMode
              ? AppTheme.backgroundColorDark
              : AppTheme.backgroundColorLight,
          title: Text(isNavigation ? 'Em Navegação' : context.tr(TranslationKeys.navigationMap)),
          elevation: theme.appBarTheme.elevation,
          centerTitle: theme.appBarTheme.centerTitle,
          actions: [
            if (!isNavigation)
              IconButton(
                icon: const Icon(RemixIcons.user_location_line, color: Colors.white),
                onPressed: () => navCtrl.determinePositionAndLoadMap(),
              ),
            if (!isNavigation)
              IconButton(
                icon: const Icon(RemixIcons.search_line, color: Colors.white),
                onPressed: () => _openSearch(context),
              ),
          ],
        ),
        floatingActionButton: _buildFABs(isNavigation),

        body: loading
            ? _buildLoadingOverlay(context)
            : Stack(
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
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'br.com.fuel_tracker_app',
                      ),
                      if (navCtrl.routePoints.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: navCtrl.routePoints.toList(),
                              strokeWidth: 6.0,
                              color: Colors.blue.shade600,
                              useStrokeWidthInMeter: false,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          if (navCtrl.currentLocation.value != null)
                            Marker(
                              point: navCtrl.currentLocation.value!,
                              width: 45,
                              height: 45,
                              child: _buildUserMarker(),
                            ),
                          ...navCtrl.stationMarkers.toList(),
                        ],
                      ),
                    ],
                  ),

                  if (isNavigation) _buildNavigationOverlay(),
                ],
              ),
      );
    });
  }

  Widget _buildUserMarker() {
    return Transform.rotate(
      angle: controller.currentHeading.value * (math.pi / 180),
      child: Icon(RemixIcons.navigation_fill, color: AppTheme.primaryFuelColor, size: 35),
    );
  }

  Widget _buildNavigationOverlay() {
    final station = controller.currentDestinationStation.value;
    if (station == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 20,
      left: 15,
      right: 15,
      child: Card(
        color: AppTheme.primaryDark.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                station.nome,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoTile(
                    RemixIcons.map_pin_2_line,
                    'Distância',
                    controller.formatDistance(controller.routeDistanceMeters.value),
                  ),
                  _buildInfoTile(
                    RemixIcons.time_line,
                    'Tempo',
                    controller.calculateETA(controller.routeDurationSeconds.value),
                  ),
                  _buildInfoTile(
                    RemixIcons.money_dollar_circle_line,
                    'Preço',
                    'R\$ ${station.priceGasolineComum.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            controller.isRouting.value ? 'Traçando melhor rota...' : 'Localizando GPS...',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildFABs(bool isNavigation) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isNavigation)
          FloatingActionButton(
            heroTag: 'toggle_mode',
            onPressed: controller.toggleNavigationMode,
            backgroundColor: controller.isNavigationMode.value
                ? Colors.blue
                : AppTheme.primaryFuelColor,
            child: Icon(
              controller.isNavigationMode.value
                  ? RemixIcons.lock_fill
                  : RemixIcons.lock_unlock_fill,
            ),
          ),
        const SizedBox(height: 12),
        if (isNavigation)
          FloatingActionButton.extended(
            heroTag: 'cancel_nav',
            onPressed: controller.clearNavigation,
            label: const Text('Parar'),
            icon: const Icon(RemixIcons.stop_circle_line),
            backgroundColor: Colors.redAccent,
          ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryFuelColor, size: 20),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
