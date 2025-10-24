import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/models/app_update.dart';

class UpdateService {
  static const String updateUrl = 'https://raw.githubusercontent.com/SeuNomeDeUsuario/fuel-tracker-app/main/config/update.json';

  Future<AppUpdate?> checkForUpdates() async {

  }

  void showUpdateDialog(BuildContext context, AppUpdate update){
    
  }
}