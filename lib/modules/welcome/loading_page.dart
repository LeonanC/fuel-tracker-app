import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/welcome/loading_controller.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class LoadingPage extends GetView<LoadingController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
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
            const Spacer(),
            Obx(
              () => Text(
                '${(controller.progresso.value * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Obx(
                  () => AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: MediaQuery.of(context).size.width * 0.8 * controller.progresso.value,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.cyanAccent],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Obx(
              () => Text(
                controller.statusMensagem.value,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
