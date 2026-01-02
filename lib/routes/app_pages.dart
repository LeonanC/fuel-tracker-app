import 'package:fuel_tracker_app/bindings/gas_station_binding.dart';
import 'package:fuel_tracker_app/bindings/language_binding.dart';
import 'package:fuel_tracker_app/routes/app_routes.dart';
import 'package:fuel_tracker_app/routes/initial_binding.dart';
import 'package:fuel_tracker_app/screens/fuel_entry_screen.dart';
import 'package:fuel_tracker_app/screens/fuel_list_screen.dart';
import 'package:fuel_tracker_app/screens/gas_station_management_screen.dart';
import 'package:fuel_tracker_app/screens/language_settings_screen.dart';
import 'package:fuel_tracker_app/screens/home_screen.dart';
import 'package:fuel_tracker_app/screens/main_navigation_screen.dart';
import 'package:fuel_tracker_app/screens/maintenance_entry_screen.dart';
import 'package:fuel_tracker_app/screens/maintenance_list_screen.dart';
import 'package:fuel_tracker_app/screens/unit_settings_screen.dart';
import 'package:get/get.dart';

class AppPages {
  static const INITIAL = Routes.home_screen;

  static final routes = [
    GetPage(
      name: Routes.on_boarding,
      page: () => OnboardingScreen(),
    ),
    GetPage(
      name: Routes.home_screen,
      page: () => HomePage(),
    ),
    GetPage(
      name: Routes.fuel_list,
      page: () => FuelListScreen(),
    ),
    GetPage(
      name: Routes.fuel_entry,
      page: () => FuelEntryScreen(),
    ),
    GetPage(
      name: Routes.maintenance_list,
      page: () => MaintenanceListScreen(),
    ),
    GetPage(
      name: Routes.maintenance_entry,
      page: () => MaintenanceEntryScreen(),
    ),
    GetPage(
      name: Routes.gas_station,
      page: () => GasStationManagementScreen(),
      binding: GasStationBinding(),
    ),
    GetPage(
      name: Routes.language_settings,
      page: () => LanguageSettingsScreen(),
      binding: LanguageBinding(),
    ),
    GetPage(
      name: Routes.unit_settings,
      page: () => UnitSettingsScreen(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: Routes.currency_settings,
      page: () => LanguageSettingsScreen(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: Routes.notification_settings,
      page: () => LanguageSettingsScreen(),
      binding: LanguageBinding(),
    ),
    GetPage(
      name: Routes.statistics_settings,
      page: () => LanguageSettingsScreen(),
      binding: LanguageBinding(),
    ),
    GetPage(
      name: Routes.vehicles_settings,
      page: () => LanguageSettingsScreen(),
      binding: LanguageBinding(),
    ),
    GetPage(
      name: Routes.backup_settings,
      page: () => LanguageSettingsScreen(),
      binding: LanguageBinding(),
    ),
  ];
}