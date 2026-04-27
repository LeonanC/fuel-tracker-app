import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class AppController extends GetxController {
  final String versionUrl =
      "https://raw.githubusercontent.com/LeonanC/fuel-tracker-app/blob/main/config/update.json";

  @override
  void onInit() {
    super.onInit();
    veificarVersao();
  }

  Future<void> veificarVersao() async {
    try {
      final response = await http.get(Uri.parse(versionUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String versaoRemota = data['version'];
        String urlDownload = data['url'];
        String mensagem = data['message'];

        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String versaoAtual = packageInfo.version;

        if (_precisaAtualizar(versaoAtual, versaoRemota)) {
          print("Versão Local: $versaoAtual");
          print("Versão Remota: $versaoRemota");
          print("Status da Requisição: ${response.statusCode}");
          _exibirDialogAtualizacao(urlDownload, mensagem);
        }
      }
    } catch (e) {
      _showSnackbar("Erro", "Erro ao verificar atualização: $e", isError: true);
    }
  }

  bool _precisaAtualizar(String atual, String remota) {
    List<int> vAtu = atual.split('.').map(int.parse).toList();
    List<int> vRem = remota.split('.').map(int.parse).toList();
    for (var i = 0; i < vAtu.length; i++) {
      if (vRem[i] > vAtu[i]) return true;
      if (vRem[i] < vAtu[i]) return false;
    }
    return false;
  }

  void _exibirDialogAtualizacao(String url, String msg) async {
    Get.defaultDialog(
      title: "up_update_available".tr,
      middleText: msg,
      barrierDismissible: false,
      textConfirm: "up_download".tr,
      confirmTextColor: Colors.white,
      onConfirm: () async {
        const url = '';
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
      },
    );
  }

  void _showSnackbar(String title, String mensagem, {bool isError = false}) {
    Get.snackbar(
      title,
      mensagem,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError
          ? Colors.redAccent.withOpacity(0.8)
          : Colors.greenAccent.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      borderRadius: 15,
      icon: Icon(
        isError ? RemixIcons.error_warning_line : RemixIcons.check_line,
        color: Colors.white,
      ),
    );
  }
}
