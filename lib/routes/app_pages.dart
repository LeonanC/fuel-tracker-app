import 'package:fuel_tracker_app/modules/fuel/bindings/fuel_bindings.dart';
import 'package:fuel_tracker_app/routes/app_routes.dart';
import 'package:fuel_tracker_app/routes/initial_binding.dart';
import 'package:fuel_tracker_app/modules/fuel/widgets/fuel_entry_screen.dart';
import 'package:fuel_tracker_app/modules/fuel/fuel_list_screen.dart';
import 'package:fuel_tracker_app/modules/fuel/language_settings_screen.dart';
import 'package:fuel_tracker_app/home_screen.dart';
import 'package:fuel_tracker_app/modules/fuel/main_navigation_screen.dart';
import 'package:fuel_tracker_app/modules/fuel/widgets/maintenance_entry_screen.dart';
import 'package:fuel_tracker_app/modules/fuel/postosList.dart';
import 'package:fuel_tracker_app/modules/fuel/unit_settings_screen.dart';
import 'package:get/get.dart';

class AppPages {
  static const INITIAL = Routes.home_screen;

  static final routes = [
    GetPage(name: Routes.on_boarding, page: () => OnboardingScreen()),
    GetPage(name: Routes.home_screen, page: () => HomePage()),
    GetPage(name: Routes.fuel_list, page: () => FuelListScreen()),
    GetPage(name: Routes.fuel_entry, page: () => FuelEntryScreen()),
    GetPage(name: Routes.postos_list, page: () => PostosList()),
    GetPage(
      name: Routes.maintenance_entry,
      page: () => MaintenanceEntryScreen(),
    ),
    GetPage(
      name: Routes.language_settings,
      page: () => LanguageSettingsScreen(),
      binding: FuelBindings(),
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
      binding: FuelBindings(),
    ),
    GetPage(
      name: Routes.statistics_settings,
      page: () => LanguageSettingsScreen(),
      binding: FuelBindings(),
    ),
    GetPage(
      name: Routes.vehicles_settings,
      page: () => LanguageSettingsScreen(),
      binding: FuelBindings(),
    ),
    GetPage(
      name: Routes.backup_settings,
      page: () => LanguageSettingsScreen(),
      binding: FuelBindings(),
    ),
  ];
}
