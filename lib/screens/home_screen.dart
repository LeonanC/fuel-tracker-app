import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/controllers/language_controller.dart';
import 'package:fuel_tracker_app/screens/fuel_list_screen.dart';
import 'package:fuel_tracker_app/screens/maintenance_list_screen.dart';
import 'package:fuel_tracker_app/screens/map_screen.dart';
import 'package:fuel_tracker_app/screens/tools_screen.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    FuelListScreen(),
    MaintenanceListScreen(),
    MapScreen(),
    ToolsScreen(),
  ];

  final LanguageController languageController = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final TextDirection textDirection = languageController.textDirection;
      final LanguageController langController = languageController;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          body: IndexedStack(index: _currentIndex, children: _screens),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryDark,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppTheme.primaryFuelColor,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 12,
              unselectedFontSize: 10,
              iconSize: 24,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(RemixIcons.gas_station_line),
                  label: langController.translate(TranslationKeys.navigationFuelEntries),
                ),
                BottomNavigationBarItem(
                  icon: Icon(RemixIcons.tools_line),
                  label: langController.translate(TranslationKeys.navigationMaintenance),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(RemixIcons.map_2_line),
                  label: langController.translate(TranslationKeys.navigationMap),
                ),
                BottomNavigationBarItem(
                  icon: Icon(RemixIcons.settings_2_fill),
                  label: langController.translate(TranslationKeys.navigationFuelTools),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
