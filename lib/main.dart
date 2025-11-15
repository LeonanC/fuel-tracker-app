import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fuel_tracker_app/provider/currency_provider.dart';
import 'package:fuel_tracker_app/provider/fuel_entry_provider.dart';
import 'package:fuel_tracker_app/provider/gas_station_provider.dart';
import 'package:fuel_tracker_app/provider/language_provider.dart';
import 'package:fuel_tracker_app/provider/maintenance_provider.dart';
import 'package:fuel_tracker_app/provider/reminder_provider.dart';
import 'package:fuel_tracker_app/provider/theme_provider.dart';
import 'package:fuel_tracker_app/provider/unit_provider.dart';
import 'package:fuel_tracker_app/provider/vehicle_provider.dart';
import 'package:fuel_tracker_app/screens/main_navigation_screen.dart';
import 'package:fuel_tracker_app/screens/onboarding_screen.dart';
import 'package:fuel_tracker_app/services/notification_service.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

final NotificationService notificationService = NotificationService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await notificationService.initialize();

  final languageProvider = LanguageProvider();
  await languageProvider.initialize();

  runApp(MyApp(languageProvider: languageProvider));
}

class MyApp extends StatefulWidget {
  final LanguageProvider languageProvider;
  const MyApp({super.key, required this.languageProvider});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.languageProvider),
        ChangeNotifierProvider(create: (context) => FuelEntryProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UnitProvider()),
        ChangeNotifierProvider(create: (context) => CurrencyProvider()),
        ChangeNotifierProvider(create: (context) => ReminderProvider()),
        ChangeNotifierProvider(create: (context) => MaintenanceProvider()),
        ChangeNotifierProvider(create: (context) => VehicleProvider()),
        ChangeNotifierProvider(create: (context) => GasStationProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(textScaleFactor: themeProvider.fontScale),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Controle de Combustível',
              themeMode: themeProvider.themeMode,
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              locale: languageProvider.locale,
              localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
              supportedLocales: const [Locale('en'), Locale('pt'), Locale('es'), Locale('fr'), Locale('de'), Locale('it'), Locale('ru')],
              home: const OnboardingScreen(),
            ),
          );
        },
      ),
    );
  }
}
