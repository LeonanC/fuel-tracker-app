import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeModeKey = 'theme_mode_key';
  static const String _fontScaleKey = 'font_scale_key';

  ThemeMode _themeMode = ThemeMode.system;
  double _fontScale = 1.0;

  ThemeMode get themeMode => _themeMode;
  double get fontScale => _fontScale;
  
  ThemeProvider(){
    _loadPreferences();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[savedThemeIndex];
    _fontScale = prefs.getDouble(_fontScaleKey) ?? 1.0;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) async {
    if(_themeMode != mode){
      _themeMode = mode;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
    }
  }

  void setFontScale(double scale) async {
    final clampedScale = scale.clamp(0.8, 1.2);

    if(_fontScale != clampedScale){
      _fontScale = clampedScale;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_fontScaleKey, clampedScale);
    }
  }

}