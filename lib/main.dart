import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fuel_tracker_app/provider/currency_provider.dart';
import 'package:fuel_tracker_app/provider/fuel_entry_provider.dart';
import 'package:fuel_tracker_app/provider/language_provider.dart';
import 'package:fuel_tracker_app/provider/maintenance_provider.dart';
import 'package:fuel_tracker_app/provider/reminder_provider.dart';
import 'package:fuel_tracker_app/provider/theme_provider.dart';
import 'package:fuel_tracker_app/provider/unit_provider.dart';
import 'package:fuel_tracker_app/screens/main_navigation_screen.dart';
import 'package:fuel_tracker_app/services/notification_service.dart';
import 'package:fuel_tracker_app/services/update_service.dart';
import 'package:provider/provider.dart';

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
  final UpdateService _updateService = UpdateService();

  Future<void> _checkForUpdates(BuildContext context) async {
    await _updateService.checkAppUpdate(context);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.languageProvider),
        ChangeNotifierProvider(create: (context) => FuelEntryProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UnitProvider()),
        ChangeNotifierProvider(create: (context) => CurrencyProvider()),
        ChangeNotifierProvider(create: (context) => ReminderProvider()),
        ChangeNotifierProvider(create: (context) => MaintenanceProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              return MediaQuery(
                data: mediaQuery.copyWith(textScaleFactor: themeProvider.fontScale),
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Controle de Combustível',
                  themeMode: themeProvider.themeMode,
                  theme: ThemeData.light(),
                  darkTheme: ThemeData.dark(),
                  locale: languageProvider.locale,
                  localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
                  supportedLocales: const [Locale('pt'), Locale('en'), Locale('es'), Locale('fr')],
                  home: Builder(
                    builder: (innerContext) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _checkForUpdates(innerContext);
                      });
                      return const MainNavigationScreen();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
