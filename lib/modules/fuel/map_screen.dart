import 'dart:math' as math;
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fuel_tracker_app/data/models/gas_station_model.dart';
import 'package:fuel_tracker_app/data/services/application.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/map_controller.dart';
import 'package:fuel_tracker_app/core/app_theme.dart';
import 'package:fuel_tracker_app/core/app_localizations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:remixicon/remixicon.dart';

class MapScreen extends GetView<MapNavigationController> {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Obx(() {
      final center =
          controller.currentLocation.value ??
          const LatLng(-23.55052, -46.63330);
      final isNavigation = controller.destinationPoint.value != null;
      final bool loading =
          controller.isLoading.value || controller.isRouting.value;

      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
        appBar: _buildModernAppBar(context, isNavigation, isDarkMode),
        floatingActionButton: _buildMordenFABs(isNavigation),
        body: Stack(
          children: [
            _buildMap(controller, isDarkMode, center),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 300,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (isNavigation) _buildGlassNavigationCard(),
            if (loading) _buildRefinedLoading(),
          ],
        ),
      );
    });
  }

  Widget _buildMap(
    MapNavigationController navCtrl,
    bool isDark,
    LatLng center,
  ) {
    return FlutterMap(
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
          urlTemplate: isDark
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
                color: Colors.blueAccent,
                gradientColors: [Colors.blue, Colors.lightBlueAccent],
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (navCtrl.currentLocation.value != null)
              _buildUserMarker(navCtrl),
            ...navCtrl.stationMarkers.toList(),
          ],
        ),
      ],
    );
  }

  Marker _buildUserMarker(MapNavigationController navCtrl) {
    return Marker(
      point: navCtrl.currentLocation.value!,
      width: 80,
      height: 80,
      child: Obx(
        () => Transform.rotate(
          angle: (navCtrl.isCompassMode.value || navCtrl.isNavigationMode.value)
              ? 0
              : (navCtrl.currentHeading.value * (math.pi / 180)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.navigation,
                  color: Colors.blueAccent,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(
    BuildContext context,
    bool isNav,
    bool isDark,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(isDark ? 0.8 : 0.4),
              Colors.transparent,
            ],
          ),
        ),
      ),
      title: Text(
        isNav ? 'Nevagação' : context.tr(TranslationKeys.navigationMap),
      ),
      actions: [
        if (!isNav) ...[
          _CircleActionButton(
            icon: RemixIcons.search_line,
            onPressed: () => _openSearch(context),
          ),
          const SizedBox(width: 16),
        ],
      ],
    );
  }

  Widget _buildGlassNavigationCard() {
    final station = controller.currentDestinationStation.value;
    if (station == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.indigo,
                        child: const Icon(
                          RemixIcons.gas_station_fill,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              station.nome,
                              style: GoogleFonts.lato(
                                color: Colors.indigoAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Posto de Combustível',
                              style: GoogleFonts.lato(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: controller.clearNavigation,
                        icon: const Icon(Icons.close, color: Colors.white54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoDetail(
                        RemixIcons.pin_distance_line,
                        'Distância',
                        controller.formatDistance(
                          controller.routeDistanceMeters.value,
                        ),
                      ),
                      _buildInfoDetail(
                        RemixIcons.time_line,
                        'Chegada',
                        controller.calculateETA(
                          controller.routeDurationSeconds.value,
                        ),
                      ),
                      _buildInfoDetail(
                        RemixIcons.money_dollar_circle_line,
                        'Preço',
                        'R\$ ${station.price.toStringAsFixed(2)}',
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

  Widget _buildRefinedLoading() {
    return Container(
      color: Colors.black45,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              Text(
                controller.isRouting.value
                    ? 'Calculando melhor rota...'
                    : 'Localizando satélites...',
                style: GoogleFonts.lato(
                  color: Colors.indigoAccent,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMordenFABs(bool isNavigation) {
    return Padding(
      padding: EdgeInsets.only(bottom: isNavigation ? 180 : 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _MordenFAB(
            icon: controller.isCompassMode.value
                ? Icons.explore
                : Icons.explore_outlined,
            onPressed: controller.toggleCompassMode,
            active: controller.isCompassMode.value,
          ),
          const SizedBox(height: 12),
          _MordenFAB(
            icon: RemixIcons.user_location_line,
            onPressed: controller.determinePosition,
          ),
          const SizedBox(height: 12),
          if (isNavigation) ...[
            _MordenFAB(
              icon: controller.isNavigationMode.value
                  ? RemixIcons.lock_fill
                  : RemixIcons.lock_unlock_fill,
              onPressed: controller.toggleNavigationMode,
              active: controller.isNavigationMode.value,
              color: Colors.orangeAccent,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.lato(color: Colors.white54, fontSize: 16),
        ),
        Text(
          label,
          style: GoogleFonts.lato(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  void _openSearch(BuildContext context) async {
    final result = await showSearch<String>(
      context: context,
      delegate: _FuelSearchDelegate(context),
    );
    if (result != null && result.isNotEmpty) {}
  }
}

class _MordenFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool active;
  final Color? color;
  const _MordenFAB({
    required this.icon,
    required this.onPressed,
    this.active = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: null,
      onPressed: onPressed,
      backgroundColor: active ? (color ?? Colors.blueAccent) : Colors.white,
      elevation: 4,
      child: Icon(icon, color: active ? Colors.white : Colors.black87),
    );
  }
}

class _FuelSearchDelegate extends SearchDelegate<String> {
  final BuildContext _context;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  _FuelSearchDelegate(this._context);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: GoogleFonts.lato(color: Colors.white54),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, ''),
  );

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      color: Colors.black,
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('postos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error ao carregar postos',
                style: GoogleFonts.lato(color: Colors.white),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final results = snapshot.data!.docs.where((doc) {
            final nome = doc['nome'].toString().toLowerCase();
            return nome.contains(query.toLowerCase());
          }).toList();

          if (results.isEmpty) {
            return Center(
              child: Text(
                "Nenhum posto encontrado.",
                style: GoogleFonts.lato(color: Colors.white54),
              ),
            );
          }

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, i) {
              final doc = results[i];
              final data = doc.data() as Map<String, dynamic>;
              final station = GasStationModel.fromFirestore(data, doc.id);
              return ListTile(
                leading: Icon(
                  RemixIcons.gas_station_line,
                  color: Colors.blueAccent,
                ),
                title: Text(
                  station.nome,
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${station.brand} - ${doubleToCurrency(station.price)}',
                  style: GoogleFonts.lato(color: Colors.white70),
                ),
                onTap: () {
                  close(context, doc.id);
                  Get.find<MapNavigationController>().setupNavigation(station);
                },
              );
            },
          );
        },
      ),
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
