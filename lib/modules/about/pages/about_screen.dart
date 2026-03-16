import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/about/controller/about_controller.dart';
import 'package:fuel_tracker_app/modules/backup/controller/update_controller.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  AboutScreen({super.key});

  final UpdateController updateController = Get.put(UpdateController());
  final AboutController aboutController = Get.put(AboutController());

  Future<void> _checkForUpdate() async {
    aboutController.setChecking(true);
    try {
      await updateController.checkForUpdate();
    } finally {
      aboutController.setChecking(false);
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        'ab_error_title'.tr,
        'ab_error_title_desc'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('ab_about'.tr),
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: Obx(() {
        final isChecking = aboutController.isCheckingForUpdate.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/app_icon/icon.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'ab_title'.tr,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${'ab_currentVersion'.tr} ${aboutController.appVersion.value}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'ab_tagline'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Text(
                'ab_developed_by'.tr,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'ab_developer'.tr,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  'ab_description'.tr,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
              const SizedBox(height: 40),
              _buildActionButton(
                label: 'up_check_for_updates'.tr,
                icon: isChecking ? null : RemixIcons.download_line,
                color: Colors.orange,
                isLoading: isChecking,
                onPressed: isChecking ? null : _checkForUpdate,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                label: 'ab_githubSource'.tr,
                icon: RemixIcons.code_line,
                color: Colors.blueAccent,
                onPressed: () =>
                    _launchUrl('https://github.com/LeonanC/fuel-tracker-app'),
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                label: 'ab_privacyPolicy'.tr,
                icon: RemixIcons.chat_private_line,
                color: Colors.teal,
                onPressed: () => _launchUrl(
                  'https://github.com/LeonanC/fuel-tracker-app/blob/main/privacy.md',
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'ab_copyright'.tr,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionButton({
    required String label,
    IconData? icon,
    required Color color,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
