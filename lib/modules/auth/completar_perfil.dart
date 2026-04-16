import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/auth/completar_perfil_controller.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class CompletarPerfilPage extends GetView<CompletarPerfilController> {
  const CompletarPerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Icon(
                RemixIcons.user_settings_line,
                size: 80,
                color: theme.primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                "Quase lá!",
                style: theme.textTheme.bodyMedium!.copyWith(
                  fontFamily: 'Montserrat',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Complete seus dados para começar a rastrear seu consumo.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              _buildFieldContainer(
                child: TextFormField(
                  controller: controller.telefoneController,
                  inputFormatters: [controller.maskTelefone],
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration(
                    context,
                    "lg_telefone".tr,
                    RemixIcons.cellphone_line,
                  ),
                ),
              ),
              Obx(
                () => _buildFieldContainer(
                  child: DropdownButtonFormField<String>(
                    value: controller.selectedVeiculo.value,
                    dropdownColor: Theme.of(context).cardColor,
                    style: const TextStyle(color: Colors.white),
                    items: controller.lookupController.veiculosDrop
                        .map(
                          (v) => DropdownMenuItem(
                            value: v.id.toString(),
                            child: Text(v.nickname),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => controller.selectedVeiculo.value = v,
                    decoration: _inputDecoration(
                      context,
                      "lg_selecione_veiculo".tr,
                      RemixIcons.car_line,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.finalizarCadastro,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const LinearProgressIndicator(color: Colors.white)
                      : Text(
                          "lg_finalizar".tr,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldContainer({required Widget child}) {
    return Padding(padding: const EdgeInsets.only(bottom: 15), child: child);
  }

  InputDecoration _inputDecoration(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.blueAccent, size: 20),
      filled: true,
      fillColor: Theme.of(
        context,
      ).colorScheme.onSurfaceVariant.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }
}
