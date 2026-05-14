import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/welcome/loading_controller.dart';
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
                    Obx(() {
                      if (controller.temErro.value) {
                        return Icon(
                          RemixIcons.error_warning_line,
                          color: Colors.redAccent,
                          size: 64,
                        );
                      }
                      return Text(
                        "${(controller.progresso.value * 100).toInt()}%",
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
                    _buildProgressBar(context),
                    const SizedBox(height: 30),

                    Obx(
                      () => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          controller.statusMensagem.value,
                          key: ValueKey(controller.statusMensagem.value),
                          style: TextStyle(
                            color: controller.temErro.value
                                ? Colors.redAccent
                                : theme.colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    if (controller.temErro.value) ...[
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => controller.tentarNovamente(),
                        icon: Icon(RemixIcons.refresh_line, size: 18),
                        label: const Text('TENTAR NOVAMENTE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: 8,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Obx(
                () => AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: constraints.maxWidth * controller.progresso.value,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: controller.temErro.value
                          ? [Colors.redAccent, Colors.orangeAccent]
                          : [Color(0xFF3B82F6), Color(0xFF22D3EE)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (controller.temErro.value
                                    ? Colors.redAccent
                                    : Colors.blueAccent)
                                .withOpacity(0.3),
                        blurRadius: 8,
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
