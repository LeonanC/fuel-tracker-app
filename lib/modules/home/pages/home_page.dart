import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/home/pages/widget/fuel_alert_card.dart';
import 'package:fuel_tracker_app/modules/home/pages/widget/fuel_list_filter_menu.dart';
import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:fuel_tracker_app/modules/home/pages/widget/fuel_card.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class HomePage extends GetView<HomeController> {
  HomePage({super.key});

  final settings = Get.find<SettingController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: _buildFAB(context, theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: RefreshIndicator(
        onRefresh: () => controller.fetchData(),
        edgeOffset: 100,
        color: Colors.blueAccent,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(theme),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildHeroStats(),
                  FuelAlertCard(),
                  _buildSearchBar(theme),
                ],
              ),
            ),
            _buildMainList(theme),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 100.0,
      floating: true,
      pinned: true,
      elevation: 0,
      stretch: true,
      centerTitle: false,
      backgroundColor: theme.scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 16),
        centerTitle: false,
        title: Text(
          'hp_titulo'.tr,
          style: GoogleFonts.montserrat(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
      ),
      actions: [
        FuelListFilterMenu(),
        IconButton(
          icon: Icon(RemixIcons.information_line, size: 20),
          onPressed: () => Get.toNamed('/about'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFAB(BuildContext context, ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () => controller.navigateToAddEntry(context),
      elevation: 4,
      highlightElevation: 8,
      backgroundColor: Colors.blueAccent,
      icon: Icon(RemixIcons.add_line, color: Colors.white),
      label: Text(
        'hp_new_registry'.tr,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: 1,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMainList(ThemeData theme) {
    return Obx(() {
      final entries = controller.filteredFuelEntries;

      if (entries.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyState(theme),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return FuelCard(entry: entries[index], controller: controller);
          },
          childCount: entries.length,
        ),
      );
    });
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            RemixIcons.gas_station_fill,
            size: 64,
            color: theme.disabledColor.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            "hp_no_vehicle_found".tr,
            style: TextStyle(
              color: theme.disabledColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStats() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2D3238), Color(0xFF161A1D)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.15),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _statTile(
                RemixIcons.dashboard_3_line,
                Colors.blueAccent,
                "hp_general_media".tr,
                settings.formatarConsumo(controller.consumoMediaGeral),
              ),
              VerticalDivider(
                color: Colors.white.withOpacity(0.1),
                thickness: 1,
                indent: 5,
                endIndent: 5,
              ),
              _statTile(
                RemixIcons.coins_line,
                Color(0xFF007268),
                "hp_average_cost".tr,
                settings.formatarDistancia(controller.kmRodadoTotal),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statTile(IconData icon, Color color, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.firaCode(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        onChanged: (v) => controller.searchText.value = v,
        style: TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: "hp_buscar_hint".tr,
          prefixIcon: Icon(RemixIcons.search_line, size: 18),
          filled: true,
          fillColor: theme.cardColor.withOpacity(0.5),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
