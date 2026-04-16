// ignore_for_file: unused_field

import 'dart:math' as math;
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fuel_tracker_app/data/models/gas_station_model.dart';
import 'package:fuel_tracker_app/modules/maps/controller/map_controller.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:remixicon/remixicon.dart';

class MapScreen extends GetView<MapNavigationController> {
  const MapScreen({super.key});

  static const Color accentColor = Color(0xFF448AFF);
  static const Color glassBase = Color(0xCC000000);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Obx(() {
      final center = controller.currentLocation.value ?? defaultCenter;
      final isNavigation = controller.destinationPoint.value != null;
      final bool loading =
          controller.isLoading.value || controller.isRouting.value;

      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: isDarkMode ? Color(0xFF0F1016) : Colors.grey[100],
        appBar: _buildModernAppBar(context, isNavigation, isDarkMode),
        floatingActionButton: _buildMordenFABs(isNavigation),
        body: Stack(
          children: [
            _buildMap(controller, isDarkMode, center),
            Align(
              alignment: Alignment.bottomCenter,
              child: IgnorePointer(
                child: Container(
                  height: 200,
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
              : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
          userAgentPackageName: 'br.com.fuel_tracker_app',
        ),
        if (navCtrl.routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: navCtrl.routePoints.toList(),
                strokeWidth: 6.0,
                color: accentColor,
                borderStrokeWidth: 2.0,
                borderColor: Colors.white24,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (navCtrl.currentLocation.value != null)
              _buildUserMarker(navCtrl),
            ...navCtrl.stationMarkers,
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
      child: Obx(() {
        double rotation =
            (navCtrl.isCompassMode.value || navCtrl.isNavigationMode.value)
            ? 0
            : (navCtrl.currentHeading.value * (math.pi / 180));

        return Transform.rotate(
          angle: rotation,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.2),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(
                  RemixIcons.navigation_fill,
                  color: accentColor,
                  size: 24,
                ),
              ),
            ],
          ),
        );
      }),
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
      titleSpacing: 20,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(isDark ? 0.9 : 0.4),
              Colors.transparent,
            ],
          ),
        ),
      ),
      title: Text(
        isNav ? 'NAVEGAÇÃO ATIVA' : 'nav_map'.tr,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      actions: [
        if (!isNav) ...[
          _CircleActionButton(
            icon: RemixIcons.search_2_line,
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
    final settings = Get.find<SettingController>();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: glassBase,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          RemixIcons.gas_station_fill,
                          color: accentColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              station.nome.toUpperCase(),
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              station.brand,
                              style: GoogleFonts.inter(
                                color: Colors.white60,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _CircleActionButton(
                        icon: RemixIcons.close_line,
                        onPressed: controller.clearNavigation,
                        size: 32,
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Divider(color: Colors.white10, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoDetail(
                        RemixIcons.pin_distance_line,
                        'Distância'.toUpperCase(),
                        controller.formatDistance(
                          controller.routeDistanceMeters.value,
                        ),
                      ),
                      _buildInfoDetail(
                        RemixIcons.time_line,
                        'Chegada'.toUpperCase(),
                        controller.calculateETA(
                          controller.routeDurationSeconds.value,
                        ),
                      ),
                      _buildInfoDetail(
                        RemixIcons.money_dollar_circle_line,
                        'Preço'.toUpperCase(),
                        settings.formatarCurrency(station.price),
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
      color: Colors.black54,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                controller.isRouting.value
                    ? 'TRAÇANDO ROTA...'
                    : 'BUSCANDO LOCALIZAÇÃO...',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  fontSize: 12,
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
      padding: EdgeInsets.only(bottom: isNavigation ? 220 : 20, right: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _MordenFAB(
            icon: controller.isCompassMode.value
                ? RemixIcons.compass_3_fill
                : RemixIcons.compass_3_line,
            onPressed: controller.toggleCompassMode,
            active: controller.isCompassMode.value,
          ),
          const SizedBox(height: 14),
          _MordenFAB(
            icon: RemixIcons.focus_3_line,
            onPressed: controller.determinePosition,
          ),
          const SizedBox(height: 12),
          if (isNavigation) ...[
            _MordenFAB(
              icon: controller.isNavigationMode.value
                  ? RemixIcons.lock_fill
                  : RemixIcons.lock_unlock_line,
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
        Icon(icon, color: accentColor, size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: Colors.white38,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  void _openSearch(BuildContext context) async {
    await showSearch<String>(
      context: context,
      delegate: _FuelSearchDelegate(context),
    );
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
    return FloatingActionButton.small(
      heroTag: null,
      onPressed: onPressed,
      backgroundColor: active ? (color ?? MapScreen.accentColor) : Colors.white,
      elevation: 6,
      child: Icon(
        icon,
        color: active ? Colors.white : Colors.black87,
        size: 20,
      ),
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
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF0F1016),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: GoogleFonts.inter(color: Colors.white38),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: Icon(RemixIcons.close_line), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: Icon(RemixIcons.arrow_left_line, color: Colors.white),
    onPressed: () => close(context, ''),
  );

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      color: Color(0xFF0F1016),
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('postos').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: MapScreen.accentColor),
            );
          }

          final results = snapshot.data!.docs.where((doc) {
            final nome = doc['nome'].toString().toLowerCase();
            return nome.contains(query.toLowerCase());
          }).toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final doc = results[i];
              final station = GasStationModel.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                tileColor: Colors.white.withOpacity(0.05),
                leading: Icon(
                  RemixIcons.gas_station_line,
                  color: MapScreen.accentColor,
                ),
                title: Text(
                  station.nome,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  station.brand,
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                ),
                trailing: Icon(
                  RemixIcons.arrow_right_s_line,
                  color: Colors.white24,
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
  final double size;
  const _CircleActionButton({
    required this.icon,
    required this.onPressed,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white10,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white10),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: size * 0.5),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
