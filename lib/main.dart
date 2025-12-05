import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fuel_tracker_app/controllers/language_controller.dart';
import 'package:fuel_tracker_app/controllers/theme_controller.dart';
import 'package:fuel_tracker_app/routes/app_pages.dart';
import 'package:fuel_tracker_app/routes/initial_binding.dart';
import 'package:fuel_tracker_app/services/notification_service.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:get/get.dart';

final NotificationService notificationService = NotificationService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await notificationService.initialize();

  final languageProvider = Get.put(LanguageController());
  await languageProvider.initialize();  

  Get.put(ThemeController());

  runApp(MyApp(languageProvider: languageProvider));
}

class MyApp extends StatefulWidget {
  final LanguageController languageProvider;
  const MyApp({super.key, required this.languageProvider});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final LanguageController languageController = Get.find<LanguageController>();

    return Obx(() {
      final mediaQuery = MediaQuery.of(context);

      return MediaQuery(
        data: mediaQuery.copyWith(textScaleFactor: themeController.fontScale.value),
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Controle de Combustível',
          locale: languageController.locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('pt'),
            Locale('es'),
            Locale('fr'),
            Locale('de'),
            Locale('it'),
            Locale('ru'),
          ],
          themeMode: themeController.themeMode.value,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          initialBinding: InitialBinding(),
        ),
      );
    });
  }
}
