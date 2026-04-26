import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/welcome/welcome_controller.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class WelcomePage extends GetView<WelcomeController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
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
              ElevatedButton(
                onPressed: () => Get.toNamed('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "COMEÇAR AGORA",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(RemixIcons.arrow_right_line),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
