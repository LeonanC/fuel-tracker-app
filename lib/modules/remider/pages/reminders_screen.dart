import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/reminder_model.dart';
import 'package:fuel_tracker_app/modules/remider/controller/reminder_controller.dart';
import 'package:fuel_tracker_app/data/global/unit_nums.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class RemindersPages extends GetView<ReminderController> {
  const RemindersPages({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ReminderController>()) {
      Get.put(ReminderController());
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(() {
        final isEnabled = controller.isReminderEnabled.value;
        final selectedFreq = controller.selectedFrequency.value;
        final selectedTime = controller.selectedReminderTime.value;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 120.0,
              pinned: true,
              stretch: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(RemixIcons.arrow_left_s_line),
                onPressed: () => Get.back(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  'rem_titulo'.tr,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildCard(
                    theme: theme,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      title: Text(
                        'rem_enable_titulo'.tr,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'rem_enable_desc'.tr,
                        style: GoogleFonts.montserrat(fontSize: 12),
                      ),
                      value: isEnabled,
                      onChanged: (value) => controller.toggleReminder(value),
                      secondary: Icon(
                        isEnabled
                            ? RemixIcons.notification_3_fill
                            : RemixIcons.notification_3_line,
                        color: isEnabled ? colorScheme.primary : Colors.grey,
                      ),
                      activeColor: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildSectionHeader(
                    'rem_frequency_titulo'.tr,
                    colorScheme.primary,
                    isEnabled,
                  ),

                  _buildCard(
                    theme: theme,
                    child: Column(
                      children: availableFrequencies.map((option) {
                        return RadioListTile<ReminderFrequency>(
                          value: option.frequency,
                          groupValue: selectedFreq,
                          title: Text(
                            option.title,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            option.subtitle,
                            style: GoogleFonts.montserrat(fontSize: 11),
                          ),
                          onChanged: isEnabled
                              ? (val) => controller.setFrequency(val!)
                              : null,
                          activeColor: colorScheme.primary,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 25),
                  _buildSectionHeader(
                    'rem_time_titulo'.tr,
                    colorScheme.primary,
                    isEnabled,
                  ),

                  _buildCard(
                    theme: theme,
                    child: ListTile(
                      enabled: isEnabled,
                      leading: Icon(RemixIcons.time_line, color: isEnabled ? colorScheme.primary : Colors.grey),
                      title: Text(
                        '${'rem_time_subtitulo'.tr}${selectedTime.format(context)}',
                        style: GoogleFonts.firaCode(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      trailing: Icon(
                        RemixIcons.edit_2_line,
                        size: 18,
                        color: isEnabled ? colorScheme.primary : Colors.transparent,
                      ),
                      onTap: isEnabled ? () => _selectTime(context) : null,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isEnabled
                          ? colorScheme.primary.withOpacity(0.05)
                          : Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isEnabled ? colorScheme.primary.withOpacity(0.1) : Colors.white10,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(RemixIcons.information_line,
                          size: 20,
                          color: isEnabled ? colorScheme.primary : Colors.grey,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            'rem_battery_info'.tr,
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, Color primary, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          color: isEnabled ? primary : Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildCard({required ThemeData theme, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(24), child: child),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: controller.selectedReminderTime.value,
    );

    if (newTime != null) {
      controller.setReminderTime(newTime);
    }
  }
}
