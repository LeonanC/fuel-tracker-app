import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/about/controller/about_controller.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  AboutScreen({super.key});

  final AboutController aboutController = Get.put(AboutController());

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        'ab_error_title'.tr,
        'ab_error_title_desc'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            expandedHeight: 120,
            stretch: true,
            title: Text(
              'ab_about'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildHeaderCard(theme),
                  const SizedBox(height: 32),
                  _buildDescriptionSection(theme),
                  const SizedBox(height: 32),

                  Obx(() {
                    final isChecking =
                        aboutController.isCheckingForUpdate.value;
                    return Column(
                      children: [
                        _buildActionButton(
                          label: 'up_check_for_updates'.tr,
                          icon: RemixIcons.refresh_line,
                          color: Colors.orange,
                          isLoading: isChecking,
                          onPressed: isChecking
                              ? null
                              : () => aboutController.checkForUpdate(),
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          label: 'ab_githubSource'.tr,
                          icon: RemixIcons.github_fill,
                          color: colorScheme.primary,
                          onPressed: () => _launchUrl(
                            'https://github.com/LeonanC/fuel-tracker-app',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          label: 'ab_privacyPolicy'.tr,
                          icon: RemixIcons.shield_user_line,
                          color: Colors.teal,
                          onPressed: () => _launchUrl(
                            'https://github.com/LeonanC/fuel-tracker-app/blob/main/privacy.md',
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 48),
                  Text(
                    'ab_copyright'.tr,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Hero(
            tag: 'app_logo',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: 100,
                height: 100,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'ab_title'.tr,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${'ab_currentVersion'.tr} ${aboutController.appVersion.value}',
            style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            'ab_tagline'.tr,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.primary.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ab_description'.tr,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.6,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Divider(color: theme.colorScheme.outlineVariant),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(RemixIcons.user_settings_line, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${'ab_developed_by'.tr} ${'ab_developer'.tr}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, size: 20),
        label: Text(label),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: color.withValues(alpha: 0.15),
          foregroundColor: color,
        ),
      ),
    );
  }
}
