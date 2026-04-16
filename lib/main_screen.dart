import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker_app/modules/home/pages/home_page.dart';
import 'package:fuel_tracker_app/modules/maps/pages/map_screen.dart';
import 'package:fuel_tracker_app/modules/perfil/pages/perfil_pages.dart';
import 'package:fuel_tracker_app/modules/settings/pages/settings_page.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:remixicon/remixicon.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  List<Widget> pages = [HomePage(), MapScreen(), PerfilPage(), ToolsScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenUtilInit(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,
        body: pages[_selectedIndex],
        bottomNavigationBar: _buildBottomNav(theme),
      ),
    );
  }

  Widget _buildBottomNav(ThemeData theme) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: GNav(
            gap: screenWidth < 360 ? 4 : 8,
            iconSize: screenWidth < 360 ? 20 : 24,
            curve: Curves.easeOutExpo,
            rippleColor: theme.dividerColor.withOpacity(0.1),
            hoverColor: theme.dividerColor.withOpacity(0.05),
            haptic: true,
            tabBorderRadius: 28,
            activeColor: Colors.blueAccent,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth < 360 ? 10 : 20,
              vertical: 12,
            ),
            tabBackgroundColor: Colors.blueAccent.withOpacity(0.1),
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTapped,
            tabs: [
              GButton(
                icon: _selectedIndex == 0
                    ? RemixIcons.gas_station_fill
                    : RemixIcons.gas_station_line,
                text: 'nav_fuel_entries'.tr,
                textStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth < 360 ? 11.sp : 13.sp,
                ),
              ),
              GButton(
                icon: _selectedIndex == 1
                    ? RemixIcons.map_2_fill
                    : RemixIcons.map_2_line,
                text: 'nav_map'.tr,
                textStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth < 360 ? 11.sp : 13.sp,
                ),
              ),
              GButton(
                icon: _selectedIndex == 2
                    ? RemixIcons.user_2_fill
                    : RemixIcons.user_2_line,
                text: 'nav_perfil'.tr,
                textStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth < 360 ? 11.sp : 13.sp,
                ),
              ),
              GButton(
                icon: _selectedIndex == 3
                    ? RemixIcons.settings_2_fill
                    : RemixIcons.settings_2_line,
                text: 'nav_tools'.tr,
                textStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth < 360 ? 11.sp : 13.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
