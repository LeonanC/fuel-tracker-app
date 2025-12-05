import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  
  var themeMode = ThemeMode.system.obs;
  var fontScale = 1.0.obs;

  @override
  void onInit() {
    themeMode.value = ThemeMode.system;
    fontScale.value = 1.0;
    super.onInit();
  }

  void setThemeMode(ThemeMode? mode) async {
    if(mode != null){
      themeMode.value = mode;
      Get.changeThemeMode(mode);
    }
  }

  void setFontScale(double scale) async {
    final clampedScale = scale.clamp(0.8, 1.2);

    if(fontScale.value != clampedScale){
      fontScale.value = clampedScale;
      
      //final prefs = await SharedPreferences.getInstance();
      //await prefs.setDouble(_fontScaleKey, clampedScale);
    }
  }

}