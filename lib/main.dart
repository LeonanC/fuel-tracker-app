import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker_app/data/services/app_translations.dart';
import 'package:fuel_tracker_app/main_screen.dart';
import 'package:fuel_tracker_app/modules/auth/completar_perfil.dart';
import 'package:fuel_tracker_app/modules/auth/login_binding.dart';
import 'package:fuel_tracker_app/modules/auth/login_page.dart';
import 'package:fuel_tracker_app/modules/backup/pages/backup_page.dart';
import 'package:fuel_tracker_app/modules/gas/pages/gas_station_screen.dart';
import 'package:fuel_tracker_app/modules/home/binding/home_bindings.dart';
import 'package:fuel_tracker_app/modules/home/pages/home_page.dart';
import 'package:fuel_tracker_app/modules/perfil/pages/perfil_pages.dart';
import 'package:fuel_tracker_app/modules/registro/pages/home_entry_page.dart';
import 'package:fuel_tracker_app/modules/maintenance/pages/maintenance_entry_screen.dart';
import 'package:fuel_tracker_app/modules/remider/pages/reminders_screen.dart';
import 'package:fuel_tracker_app/modules/vehicle/pages/vehicle_screen.dart';
import 'package:fuel_tracker_app/data/services/notification_service.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

final NotificationService notificationService = NotificationService();

Future<void> main() async {
  await initializeDateFormatting('pt_BR', null);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init();
  await NotificationService.requestPermissions();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  User? usuarioLogado = FirebaseAuth.instance.currentUser;
  String rotaInitial = usuarioLogado == null ? '/login' : '/main';

  runApp(MyApp(rotaInitial: rotaInitial));
}

class MyApp extends StatelessWidget {
  final String rotaInitial;
  const MyApp({super.key, required this.rotaInitial});

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
          initialRoute: rotaInitial,
          translations: AppTranslations(),
          locale: Get.deviceLocale,
          fallbackLocale: Locale('pt_BR', 'BR'),
          themeMode: ThemeMode.system,
          getPages: [
            GetPage(
              name: '/main',
              page: () => MainPage(),
              binding: HomeBindings(),
            ),
            GetPage(
              name: '/login',
              page: () => LoginPage(),
              binding: HomeBindings(),
            ),
            GetPage(
              name: '/completar-perfil',
              page: () => CompletarPerfilPage(),
              binding: HomeBindings(),
            ),
            GetPage(
              name: '/perfil',
              page: () => PerfilPage(),
              binding: HomeBindings(),
            ),
            GetPage(
              name: '/home',
              page: () => HomePage(),
              binding: HomeBindings(),
            ),
            GetPage(
              name: '/fuel_entry',
              page: () => HomeEntryPage(),
              binding: HomeBindings(),
              transition: Transition.rightToLeftWithFade,
            ),
            GetPage(
              name: '/postos_pages',
              page: () => HomePage(),
              binding: HomeBindings(),
            ),
            GetPage(
              name: '/maintenance_entry',
              page: () => MaintenanceEntryScreen(),
              binding: HomeBindings(),
            ),
            GetPage(
              name: '/notification_pages',
              page: () => RemindersPages(),
              binding: HomeBindings(),
            ),
            GetPage(
              name: '/gas_station',
              page: () => GasStationScreen(),
              binding: HomeBindings(),
            ),
            GetPage(
              name: '/vehicles_pages',
              page: () => VehicleScreen(),
              binding: HomeBindings(),
            ),
            GetPage(
              name: '/backup_pages',
              page: () => BackupRestoreScreen(),
              binding: HomeBindings(),
            ),
          ],
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
}
