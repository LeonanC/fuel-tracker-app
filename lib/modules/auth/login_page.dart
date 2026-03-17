import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/auth/login_controller.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class LoginPage extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<LoginController>();
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      RemixIcons.car_fill,
                      size: 80,
                      color: Colors.blueAccent,
                    ),
                    Icon(
                      RemixIcons.gas_station_fill,
                      size: 80,
                      color: Colors.orangeAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'ab_title'.tr,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 40),
                Obx(
                  () => Column(
                    children: [
                      if (!controller.isLogin.value) ...[
                        _buildTextField(
                          label: 'lg_nome_completo'.tr,
                          icon: RemixIcons.user_3_line,
                          controller: controller.nomeController,
                        ),
                        _buildTextField(
                          label: 'lg_telefone'.tr,
                          icon: RemixIcons.cellphone_line,
                          controller: controller.telefoneController,
                        ),
                        _buildDropdown(c, theme),
                      ],
                      _buildTextField(
                        label: 'lg_email'.tr,
                        icon: RemixIcons.mail_line,
                        controller: controller.emailController,
                      ),
                      _buildTextField(
                        label: 'lg_senha'.tr,
                        icon: RemixIcons.lock_password_line,
                        controller: controller.senhaController,
                        isPassword: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.realizarAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            controller.isLogin.value
                                ? "lg_entrar".tr
                                : "lg_cadastrar".tr,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: controller.toggleAuthMode,
                  child: Obx(
                    () => Text(
                      controller.isLogin.value
                          ? "lg_nao_tem_conta".tr
                          : "lg_ja_tem_conta".tr,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(LoginController c, ThemeData theme) {
    return _dropdown(
      c.selectedVeiculos,
      c.lookupController.veiculosDrop
          .map((v) => DropdownMenuItem(value: v.id, child: Text(v.nickname)))
          .toList(),
      "Veículo",
    );
  }

  Widget _dropdown(
    RxnInt val,
    List<DropdownMenuItem<int>> items,
    String label,
  ) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: DropdownButtonFormField<int>(
          value: val.value,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white54),
            prefixIcon: Icon(
              RemixIcons.car_line,
              color: Colors.blueAccent,
              size: 20,
            ),
            filled: true,
            fillColor: const Color(0xFF1E293B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
          items: items,
          onChanged: (v) => val.value = v,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    VoidCallback? onTap,
  }) {
    final loginController = Get.find<LoginController>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? loginController.obscureText.value : false,
        keyboardType: keyboardType,
        readOnly: readOnly,
        style: const TextStyle(color: Colors.white),
        validator: (value) => value!.isEmpty ? "lg_erro_campo".tr : null,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.blueAccent, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    loginController.obscureText.value
                        ? RemixIcons.eye_off_line
                        : RemixIcons.eye_line,
                    color: Colors.white30,
                  ),
                  onPressed: loginController.toggleObscure,
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF1E293B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
