import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                      color: theme.colorScheme.primary,
                    ),
                    Icon(
                      RemixIcons.gas_station_fill,
                      size: 80,
                      color: theme.colorScheme.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'ab_title'.tr,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontFamily: 'Montserrat',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 40),
                Obx(
                  () => Column(
                    children: [
                      if (!controller.isLogin.value) ...[
                        _buildTextField(
                          context,
                          label: 'lg_nome_completo'.tr,
                          icon: RemixIcons.user_3_line,
                          controller: controller.nomeController,
                        ),
                        _buildTextField(
                          context,
                          label: 'lg_telefone'.tr,
                          icon: RemixIcons.cellphone_line,
                          controller: controller.telefoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [controller.maskTelefone],
                        ),
                        _buildDropdown(context, c),
                      ],
                      _buildTextField(
                        context,
                        label: 'lg_email'.tr,
                        icon: RemixIcons.mail_line,
                        controller: controller.emailController,
                      ),
                      _buildTextField(
                        context,
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
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                      style: TextStyle(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: theme.colorScheme.onBackground.withOpacity(0.2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        "OU",
                        style: TextStyle(
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.5,
                          ),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: theme.colorScheme.onBackground.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () => controller.loginWithGoogle(),
                  icon: Icon(RemixIcons.google_fill, color: Colors.redAccent),
                  label: Text(
                    controller.isLogin.value
                        ? "lg_entrar_google".tr
                        : "lg_cadastrar_google".tr,
                    style: TextStyle(color: theme.colorScheme.onBackground),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    side: BorderSide(
                      color: theme.colorScheme.onBackground.withOpacity(0.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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

  Widget _buildDropdown(BuildContext context, LoginController c) {
    return _dropdown(
      context,
      c.selectedVeiculos,
      c.lookupController.veiculosDrop
          .map((v) => DropdownMenuItem(value: v.id, child: Text(v.nickname)))
          .toList(),
      "Veículo",
    );
  }

  Widget _dropdown(
    BuildContext context,
    RxnString val,
    List<DropdownMenuItem<String>> items,
    String label,
  ) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: DropdownButtonFormField<String>(
          value: val.value,
          decoration: _inputDecoration(context, "Veículo", RemixIcons.car_line),
          dropdownColor: Theme.of(context).cardColor,
          items: items,
          onChanged: (v) => val.value = v,
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final loginController = Get.find<LoginController>();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? loginController.obscureText.value : false,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        readOnly: readOnly,
        style: const TextStyle(color: Colors.white),
        validator: (value) => value!.isEmpty ? "lg_erro_campo".tr : null,
        onTap: onTap,
        decoration: _inputDecoration(
          context,
          label,
          icon,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    loginController.obscureText.value
                        ? RemixIcons.eye_off_line
                        : RemixIcons.eye_line,
                  ),
                  onPressed: loginController.toggleObscure,
                )
              : null,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context,
    String label,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1),
      ),
    );
  }
}
