import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/loading/loading_controller.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class LoadingPage extends GetView<LoadingController> {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
            SliverToBoxAdapter(
              child: Center(
                child: Column(
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
                    const SizedBox(height: 20),
                    Text(
                      'lg_welcome'.tr,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'lg_titulo'.tr.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontFamily: 'Montserrat',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    Text(
                      'lg_subtitulo'.tr.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => Icon(
                        controller.temErro.value
                            ? RemixIcons.error_warning_fill
                            : RemixIcons.gas_station_fill,
                        size: 72,
                        color: controller.temErro.value
                            ? Colors.redAccent
                            : Colors.blueAccent.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Obx(() {
                      if (controller.temErro.value) {
                        return const SizedBox.shrink();
                      }

                      return Text(
                        "${controller.progresso.value}%",
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      );
                    }),

                    Obx(
                      () => SizedBox(height: controller.temErro.value ? 0 : 15),
                    ),

                    Obx(() {
                      return Text(
                        controller.statusMensagem.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: controller.temErro.value
                              ? Colors.redAccent.withOpacity(0.9)
                              : Colors.white.withOpacity(0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    }),
                    const SizedBox(height: 35),
                    Obx(() {
                      if (controller.temErro.value) {
                        return ElevatedButton.icon(
                          onPressed: () => controller.tentarNovamente(),
                          icon: Icon(RemixIcons.refresh_line, size: 18),
                          label: const Text('TENTAR NOVAMENTE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                        );
                      }
                      return _buildProgressBar(Colors.blueAccent);
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(Color primaryColor) {
    return Container(
      width: double.infinity,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Obx(
                () => AnimatedContainer(
                  duration: const Duration(milliseconds: 50),
                  width: constraints.maxWidth * (controller.progresso.value / 100),
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF22D3EE)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
