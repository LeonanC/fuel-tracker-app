import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fuel_tracker_app/controllers/maintenance_controller.dart';
import 'package:fuel_tracker_app/controllers/map_controller.dart';
import 'package:fuel_tracker_app/models/gas_station_model.dart';
import 'package:fuel_tracker_app/models/route_step_model.dart';
import 'package:fuel_tracker_app/controllers/gas_station_controller.dart';
import 'package:fuel_tracker_app/services/voice_navigation_service.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:remixicon/remixicon.dart';

class MapScreen extends GetView<MapNavigationController> {
  const MapScreen({super.key});

  Widget _buildServiceIcon(IconData icon, String label, bool available) {
    return Column(
      children: [
        Icon(icon, color: available ? Colors.greenAccent : Colors.grey.shade600, size: 24),
        Text(
          label,
          style: TextStyle(color: available ? Colors.white : Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildInfoTile({required IconData icon, required String label, required String value}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryFuelColor, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<MapNavigationController>()) {
      Get.find<MapNavigationController>();
    } else {
      Get.put(MapNavigationController());
    }

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
                onPressed: () {
                  if (controller.currentLocation.value != null) {
                    controller.mapController.move(controller.currentLocation.value!, 15.0);
                  } else {
                    controller.determinePositionAndLoadMap();
                  }
                },
              ),
            if (!isNavigation)
              IconButton(
                icon: const Icon(RemixIcons.search_line, color: Colors.white),
                onPressed: () async {
                  final String? result = await showSearch<String>(
                    context: context,
                    delegate: _FuelSearchDelegate(context),
                  );
                  if (result != null && result.isNotEmpty) {
                    controller.loadStationsFromDB(query: result);
                  }
                },
              ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isNavigation)
              FloatingActionButton(
                heroTag: 'nav_mode_toggle',
                onPressed: controller.toggleNavigationMode,
                backgroundColor: controller.isNavigationMode.value
                    ? Colors.blueAccent
                    : AppTheme.primaryFuelColor,
                child: Icon(
                  controller.isNavigationMode.value
                      ? RemixIcons.compass_fill
                      : RemixIcons.compass_line,
                  color: Colors.white,
                ),
              ),
            const SizedBox(height: 10),
            if (isNavigation)
              FloatingActionButton.extended(
                heroTag: 'gas_station_cancel_tag',
                onPressed: controller.clearNavigation,
                label: const Text('Cancelar Navegação'),
                icon: const Icon(RemixIcons.close_line),
                backgroundColor: Colors.red.shade700,
              ),
          ],
        ),

        body: loading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryFuelColor),
                    const SizedBox(height: 10),
                    Text(
                      controller.isRouting.value
                          ? 'Calculando Rota...'
                          : context.tr(TranslationKeys.mapLoadingLocation),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  FlutterMap(
                    mapController: controller.mapController,
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 15.0,
                      minZoom: 3.0,
                      maxZoom: 18.0,
                      interactionOptions: controller.isNavigationMode.value
                          ? const InteractionOptions(flags: InteractiveFlag.none)
                          : const InteractionOptions(flags: InteractiveFlag.all),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'br.com.fuel_tracker_app',
                      ),
                      if (controller.routePoints.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: controller.routePoints.toList(),
                              strokeWidth: 7.0,
                              color: Colors.blue.shade700,
                              useStrokeWidthInMeter: false,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          if (controller.currentLocation.value != null)
                            Marker(
                              point: controller.currentLocation.value!,
                              width: 40,
                              height: 40,
                              child: Transform.rotate(
                                angle: controller.currentHeading.value * (math.pi / 180),
                                child: Icon(
                                  RemixIcons.car_fill,
                                  color: AppTheme.primaryFuelColor,
                                  size: 40,
                                ),
                              ),
                            ),
                          ...controller.stationMarkers.toList(),
                        ],
                      ),
                    ],
                  ),

                  if (isNavigation &&
                      controller.routeDistanceMeters.value > 0 &&
                      controller.currentDestinationStation.value != null)
                    Positioned(
                      bottom: 100,
                      left: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryDark.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: Colors.black54, blurRadius: 8, spreadRadius: 1),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.currentDestinationStation.value!.nome,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildInfoTile(
                                  icon: RemixIcons.road_map_line,
                                  label: 'Distância',
                                  value: controller.formatDistance(controller.routeDistanceMeters.value),
                                ),
                                _buildInfoTile(
                                  icon: RemixIcons.timer_line,
                                  label: 'Chegada',
                                  value: controller.calculateETA(controller.routeDurationSeconds.value),
                                ),
                                _buildInfoTile(
                                  icon: RemixIcons.gas_station_fill,
                                  label: 'Preço (Gas.)',
                                  value:
                                      'R\$ ${controller.currentDestinationStation.value!.priceGasolineComum.toStringAsFixed(2)}',
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white24, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildServiceIcon(
                                  RemixIcons.store_2_fill,
                                  'Loja',
                                  controller.currentDestinationStation.value!.hasConvenientStore,
                                ),
                                _buildServiceIcon(
                                  RemixIcons.time_fill,
                                  '24H',
                                  controller.currentDestinationStation.value!.is24Hours,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      );
    });
  }
}

class _FuelSearchDelegate extends SearchDelegate<String> {
  final BuildContext _context;
  final GasStationController _controller = Get.find<GasStationController>();

  _FuelSearchDelegate(this._context)
    : super(searchFieldLabel: _context.tr(TranslationKeys.mapSearchAction));

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return theme.copyWith(
      scaffoldBackgroundColor: isDarkMode ? AppTheme.primaryDark : AppTheme.primaryFuelColor,
      iconTheme: const IconThemeData(color: Colors.white),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
        focusedBorder: InputBorder.none,
        border: InputBorder.none,
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      final List<String> commonQueries = [
        _context.tr(TranslationKeys.mapSearchAction),
        'Posto Shell',
        'Posto Ipiranga',
        _context.tr(TranslationKeys.mapSearchCheapestGasStation),
      ];
      return Container(
        color: AppTheme.primaryDark,
        child: ListView.builder(
          itemCount: commonQueries.length,
          itemBuilder: (context, index) {
            final suggestion = commonQueries[index];
            return ListTile(
              title: Text(suggestion, style: TextStyle(color: Colors.white)),
              leading: Icon(RemixIcons.gas_station_line, color: AppTheme.primaryFuelColor),
              onTap: () {
                query = suggestion;
                showResults(context);
              },
            );
          },
        ),
      );
    }
    return FutureBuilder<List<GasStationModel>>(
      future: _controller.searchStations(query, returnData: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: AppTheme.primaryFuelColor));
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              _context.tr(TranslationKeys.mapSearchError),
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final List<GasStationModel> results = snapshot.data ?? [];

        if (results.isEmpty) {
          return Center(
            child: Text(
              _context.tr(TranslationKeys.mapSearchNoResults),
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        return Container(
          color: AppTheme.primaryDark,
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final station = results[index];
              return ListTile(
                title: Text(station.nome, style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  'R\$ ${station.priceGasolineComum.toStringAsFixed(2)} | ${station.brand}',
                  style: const TextStyle(color: Colors.white70),
                ),
                leading: Icon(RemixIcons.gas_station_line, color: AppTheme.primaryFuelColor),
                onTap: () {
                  close(context, station.nome);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text('Pesquisando por "$query"...', style: TextStyle(color: Colors.white70)),
    );
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(RemixIcons.arrow_left_line),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(RemixIcons.close_line),
        onPressed: () {
          query = '';
        },
      ),
      IconButton(
        icon: const Icon(RemixIcons.search_line),
        onPressed: () {
          close(context, query);
        },
      ),
    ];
  }
}
