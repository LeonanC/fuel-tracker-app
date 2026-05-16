import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker_app/modules/registro/pages/station_entry_screen.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Importações de dados e serviços
import 'package:fuel_tracker_app/data/bindings/app_bindings.dart';
import 'package:fuel_tracker_app/data/controllers/app_controller.dart';
import 'package:fuel_tracker_app/data/services/app_translations.dart';
import 'package:fuel_tracker_app/data/services/notification_service.dart';

// Importações de Telas e Bindings
import 'package:fuel_tracker_app/main_screen.dart';
import 'package:fuel_tracker_app/modules/about/pages/about_screen.dart';
import 'package:fuel_tracker_app/modules/login/pages/completar_perfil.dart';
import 'package:fuel_tracker_app/modules/login/pages/login_page.dart';
import 'package:fuel_tracker_app/modules/registro/pages/vehicle_entry_screen.dart';
import 'package:fuel_tracker_app/modules/settings/pages/settings_page.dart';
import 'package:fuel_tracker_app/modules/welcome/loading_page.dart';
import 'package:fuel_tracker_app/modules/backup/pages/backup_page.dart';
import 'package:fuel_tracker_app/modules/gas/pages/station_screen.dart';
import 'package:fuel_tracker_app/modules/home/pages/home_page.dart';
import 'package:fuel_tracker_app/modules/perfil/pages/perfil_pages.dart';
import 'package:fuel_tracker_app/modules/registro/pages/home_entry_page.dart';
import 'package:fuel_tracker_app/modules/remider/pages/reminders_screen.dart';
import 'package:fuel_tracker_app/modules/vehicle/pages/vehicle_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://feucepbyhclaumteibkd.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZldWNlcGJ5aGNsYXVtdGVpYmtkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY4MDQyOTMsImV4cCI6MjA5MjM4MDI5M30.Z5xbnS3swuDBGai3Z4Hv1oJhr0QfcEEfq8v9s-x6ypA',
    authOptions: FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
  );

  Get.put(AppController());
  await initializeDateFormatting('pt_BR', null);
  await NotificationService.init();
  await NotificationService.requestPermissions();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Controle de Combustível',

          translations: AppTranslations(),
          locale: Get.deviceLocale,
          fallbackLocale: Locale('pt_BR', 'BR'),

          initialRoute: '/loading',
          initialBinding: AppBinding(),
          getPages: _appPages,

          themeMode: ThemeMode.system,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: Colors.blueAccent,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.blueAccent,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
          ),
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(0.9)),
              child: widget!,
            );
          },
        );
      },
    );
  }

  List<GetPage> get _appPages => [
    GetPage(name: '/loading', page: () => LoadingPage()),
    GetPage(name: '/main', page: () => MainPage()),
    GetPage(name: '/login', page: () => LoginPage()),
    GetPage(name: '/perfil', page: () => PerfilPage()),
    GetPage(name: '/settings', page: () => SettingScreen()),
    GetPage(name: '/about', page: () => AboutScreen()),
    GetPage(name: '/completar-perfil', page: () => CompletarPerfilPage()),
    GetPage(name: '/home', page: () => HomePage()),
    GetPage(name: '/fuel_entry', page: () => HomeEntryPage()),
    GetPage(name: '/notification_pages', page: () => RemindersPages()),
    GetPage(name: '/vehicles_pages', page: () => VehicleScreen()),
    GetPage(name: '/vehicles_entry', page: () => VehicleEntryScreen()),
    GetPage(name: '/station_pages', page: () => StationScreen()),
    GetPage(name: '/station_entry', page: () => StationEntryScreen()),
    GetPage(name: '/backup_pages', page: () => BackupScreen()),
  ];
}
