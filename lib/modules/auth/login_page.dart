import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuel_tracker_app/data/models/vehicle_model.dart';
import 'package:fuel_tracker_app/modules/auth/login_controller.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                        Obx(
                          () => CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage:
                                controller.fotoUrl.value != null &&
                                    controller.fotoUrl.value!.isNotEmpty
                                ? NetworkImage(controller.fotoUrl.value!)
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                color: controller.fotoUrl.value != null
                                    ? Colors.black26
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: IconButton(
                                icon: Icon(
                                  controller.fotoUrl.value == null
                                      ? RemixIcons.camera_line
                                      : RemixIcons.edit_line,
                                  color: controller.fotoUrl.value == null
                                      ? Colors.grey.shade700
                                      : Colors.white,
                                  size: 28,
                                ),
                                onPressed:
                                    controller.selecionarEFazerUploadFoto,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
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
                        _buildDropdown(context, controller),
                      ],
                      _buildTextField(
                        context,
                        label: 'lg_email'.tr,
                        icon: RemixIcons.mail_line,
                        controller: controller.emailController,
                      ),
                      if (!controller.isForgotPassword.value) ...[
                        _buildTextField(
                          context,
                          label: 'lg_senha'.tr,
                          icon: RemixIcons.lock_password_line,
                          controller: controller.senhaController,
                          isPassword: true,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Obx(
                  () => ElevatedButton(
                    onPressed: () {
                      if (controller.isForgotPassword.value) {
                        controller.forgotPassword();
                      } else {
                        controller.realizarAuth();
                      }
                    },

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
                            controller.isForgotPassword.value
                                ? "ENVIAR E-MAIL DE RECUPERAÇÃO"
                                : controller.isLogin.value
                                ? "lg_entrar".tr
                                : "lg_cadastrar".tr,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
                TextButton(
                  onPressed: controller.alternarEsqueciSenha,
                  child: Obx(
                    () => Text(
                      controller.isForgotPassword.value
                          ? "lg_voltar_login".tr
                          : "lg_forgot_password".tr,
                      style: TextStyle(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
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
      c.lookupController.veiculosDrop.map((VehicleModel veiculo) {
        return DropdownMenuItem<String>(
          value: veiculo.id,
          child: Text(veiculo.nickname),
        );
      }).toList(),
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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? this.controller.obscureText.value : false,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        readOnly: readOnly,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        validator: (value) => value!.isEmpty ? "lg_erro_campo".tr : null,
        onTap: onTap,
        decoration: _inputDecoration(
          context,
          label,
          icon,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    this.controller.obscureText.value
                        ? RemixIcons.eye_off_line
                        : RemixIcons.eye_line,
                    color: theme.iconTheme.color,
                  ),
                  onPressed: this.controller.toggleObscure,
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
