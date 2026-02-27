import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/language_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/fuel_list_screen.dart';
import 'package:fuel_tracker_app/modules/fuel/postosList.dart';
import 'package:fuel_tracker_app/modules/fuel/map_screen.dart';
import 'package:fuel_tracker_app/modules/fuel/tools_screen.dart';
import 'package:fuel_tracker_app/core/app_theme.dart';
import 'package:fuel_tracker_app/core/app_localizations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:remixicon/remixicon.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  List<Widget> _pages = [
    FuelListScreen(),
    PostosList(),
    MapScreen(),
    ToolsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final LanguageController languageController = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      child: Obx(() {
        final TextDirection textDirection = languageController.textDirection;
        final LanguageController langController = languageController;

        return Directionality(
          textDirection: textDirection,
          child: Scaffold(
            key: _scaffoldKey,
            body: _pages[_selectedIndex],
            bottomNavigationBar: _buildBottomNav(langController),
          ),
        );
      }),
    );
  }

  Widget _buildBottomNav(LanguageController langController) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.2)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: GNav(
            gap: 8,
            iconSize: 24,
            curve: Curves.easeOutExpo,
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[200]!,
            haptic: true,
            tabBorderRadius: 28,

            activeColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            tabBackgroundColor: Colors.blue.withOpacity(0.7),
            textStyle: GoogleFonts.lato(color: Colors.white, fontSize: 14),
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTapped,
            backgroundColor: Colors.transparent,
            tabs: [
              GButton(
                icon: _selectedIndex == 0
                    ? RemixIcons.gas_station_fill
                    : RemixIcons.gas_station_line,
                text: langController.translate(
                  TranslationKeys.navigationFuelEntries,
                ),
              ),
              GButton(
                icon: _selectedIndex == 1
                    ? RemixIcons.search_fill
                    : RemixIcons.search_line,
                text: langController.translate(
                  TranslationKeys.navigationSearch,
                ),
              ),
              GButton(
                icon: _selectedIndex == 2
                    ? RemixIcons.map_2_fill
                    : RemixIcons.map_2_line,
                text: langController.translate(TranslationKeys.navigationMap),
              ),
              GButton(
                icon: _selectedIndex == 3
                    ? RemixIcons.settings_2_fill
                    : RemixIcons.settings_2_line,
                text: langController.translate(
                  TranslationKeys.navigationFuelTools,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
