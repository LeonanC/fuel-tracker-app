import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/provider/theme_provider.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:provider/provider.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() => _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final themeProvider = Provider.of<ThemeProvider>(context);
    final selectedThemeMode = themeProvider.themeMode;
    
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
        title: Text(context.tr(TranslationKeys.appearanceSettingsTitle)),
        elevation: theme.appBarTheme.elevation,
        centerTitle: theme.appBarTheme.centerTitle,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsSection(
            context,
            title: context.tr(TranslationKeys.themeSectionTitle),
            children: [
              ListTile(
                title: Text(context.tr(TranslationKeys.themeOptionSystem)),
                selectedColor: AppTheme.primaryRadioColor,
                trailing: Radio<ThemeMode>(
                  activeColor: AppTheme.efficiencyGreen,
                  value: ThemeMode.system,
                  groupValue: selectedThemeMode,
                  onChanged: (ThemeMode? value){
                    if(value != null){
                      themeProvider.setThemeMode(value);
                    }
                  },
                ),
              ),
              ListTile(
                title: Text(context.tr(TranslationKeys.themeOptionLight)),
                selectedColor: AppTheme.primaryRadioColor,
                trailing: Radio<ThemeMode>(
                  activeColor: AppTheme.efficiencyGreen,
                  value: ThemeMode.light,
                  groupValue: selectedThemeMode,
                  onChanged: (ThemeMode? value){
                    if(value != null){
                      themeProvider.setThemeMode(value);
                    }
                  },
                ),
              ),
              ListTile(
                title: Text(context.tr(TranslationKeys.themeOptionDark)),
                trailing: Radio<ThemeMode>(
                  activeColor: AppTheme.efficiencyGreen,
                  value: ThemeMode.dark,
                  groupValue: selectedThemeMode,
                  onChanged: (ThemeMode? value){
                    if(value != null){
                      themeProvider.setThemeMode(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          _buildSettingsSection(
            context,
            title: context.tr(TranslationKeys.fontSizeSectionTitle),
            children: [
              Slider(
                inactiveColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.primaryFuelColor : AppTheme.primaryFuelAccent,
                activeColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.primaryFuelColor : AppTheme.primaryFuelAccent,
                value: themeProvider.fontScale,
                min: 0.8,
                max: 1.2,
                divisions: 4,
                label: '${themeProvider.fontScale.toStringAsFixed(2)}x',
                onChanged: (double value){
                  themeProvider.setFontScale(value);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Exemplo de texto. Este texto mudará de tamanho com o controle deslizante.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textScaleFactor: themeProvider.fontScale,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, {required String title, required List<Widget> children}){
    final headlineColor = Theme.of(context).textTheme.titleMedium?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: headlineColor,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}