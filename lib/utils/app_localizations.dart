import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/provider/language_provider.dart';
import 'package:provider/provider.dart';

class AppLocalizations {
  final LanguageProvider _languageProvider;
  AppLocalizations(this._languageProvider);

  String translate(String key, {Map<String, String>? parameters}) {
    return _languageProvider.translate(key, parameters: parameters);
  }

  String tr(String key, {Map<String, String>? parameters}) {
    return translate(key, parameters: parameters);
  }

  String get currentLanguageCode => _languageProvider.currentLanguage.code;
  String get currentLanguageName => _languageProvider.currentLanguage.name;
  bool get isRtl => _languageProvider.isRtl;
  TextDirection get textDirection => _languageProvider.textDirection;
  Locale get locale => _languageProvider.locale;

  static AppLocalizations of(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    return AppLocalizations(languageProvider);
  }

  static AppLocalizations watch(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: true);
    return AppLocalizations(languageProvider);
  }

  bool hasTranslation(String key) {
    return _languageProvider.hasTranslation(key);
  }
}

extension LocalizationExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
  AppLocalizations get locWatch => AppLocalizations.watch(this);

  String tr(String key, {Map<String, String>? parameters}) {
    return loc.translate(key, parameters: parameters);
  }

  bool hasTranslation(String key) {
    return loc.hasTranslation(key);
  }

  String get currentLanguageCode => loc.currentLanguageCode;
  bool get isRtl => loc.isRtl;
  TextDirection get textDirection => loc.textDirection;
}

extension LocalizedStateMixin<T extends StatefulWidget> on State<T> {
  AppLocalizations get loc => AppLocalizations.of(context);

  String tr(String key, {Map<String, String>? parameters}) {
    return loc.translate(key, parameters: parameters);
  }

  bool hasTranslation(String key) {
    return loc.hasTranslation(key);
  }
}

mixin LocalizedStatelessMixin {
  AppLocalizations loc(BuildContext context) => AppLocalizations.of(context);

  String tr(BuildContext context, String key, {Map<String, String>? parameters}) {
    return loc(context).translate(key, parameters: parameters);
  }

  bool hasTranslation(BuildContext context, String key) {
    return loc(context).hasTranslation(key);
  }
}

class TranslationKeys {
  // Language
  static const String language = 'language';
  static const String languageName = 'language.name';
  static const String languageCode = 'language.code';
  static const String languageFlag = 'language.flag';
  static const String languageDirection = 'language.direction';

  // App
  static const String app = 'app';
  static const String appTitle = 'app.title';
  static const String appSubtitle = 'app.subtitle';

  // About Screen
  static const String aboutTitle = 'about.title';
  static const String aboutVersion = 'about.version';
  static const String aboutTagline = 'about.tagline';
  static const String aboutDevelopedBy = 'about.developed_by';
  static const String aboutDeveloper = 'about.developer';
  static const String aboutDescription = 'about.description';
  static const String aboutTelegramChannel = 'about.telegram_channel';
  static const String aboutGithubSource = 'about.github_source';
  static const String aboutPrivacyPolicy = 'about.privacy_policy';
  static const String aboutTermsOfService = 'about.terms_of_service';
  static const String aboutCopyright = 'about.copyright';

  // Navigation
  static const String navigation = 'navigation';
  static const String navigationFuelEntries = 'navigation.fuel_entries';
  static const String navigationMaintenance = 'navigation.fuel_maintenance';
  static const String navigationFuelTools = 'navigation.fuel_tools';

  // List Screen
  static const String listScreen = 'list_screen';
  static const String listScreenAppBarTitle = 'list_screen.app_bar_title';
  static const String listScreenTooltipRefresh = 'list_screen.tooltip_refresh';
  static const String listScreenSnackbarRefreshing = 'list_screen.snackbar_refreshing';
  static const String listScreenSnackbarEntryAdded = 'list_screen.snackbar_entry_added';
  static const String listScreenSnackbarEntryUpdated = 'list_screen.snackbar_entry_updated';
  static const String listScreenSnackbarEntryRemoved = 'list_screen.snackbar_entry_removed';

  // Common Labels
  static const String commonLabels = 'common_labels';
  static const String commonLabelsType = 'common_labels.type';
  static const String commonLabelsOdometer = 'common_labels.odometer';
  static const String commonLabelsDate = 'common_labels.date';
  static const String commonLabelsLiters = 'common_labels.liters';
  static const String commonLabelsPricePerLiter = 'common_labels.price_per_liter';
  static const String commonLabelsGasStation = 'common_labels.gas_station';
  static const String commonLabelsCurrencySymbol = 'common_labels.currency_symbol';
  static const String commonLabelsSelect = 'common_labels.select';
  static const String commonLabelsDelete = "common_labels.delete";
  static const String commonLabelsCancel = "common_labels.cancel";
  static const String commonLabelsDeleteConfirmation = "common_labels.confirmation";
  static const String commonLabelsDeleteConfirmMessage = "common_labels.confirm_message";

  static const String consumptionCards = 'consumption_cards';
  static const String consumptionCardsOverallAverage = 'consumption_cards.overall_average';
  static const String consumptionCardsNotAvailableShort = 'consumption_cards.not_available_short';
  static const String consumptionCardsUnitKmPerLiter = 'consumption_cards.unit_km_l';
  static const String consumptionCardsConsumptionPeriod = 'consumption_cards.consumption_period';

  static const String alerts = 'alerts';
  static const String alertsThresholdMsg = 'alerts.alert_threshold_msg';

  static const String emptyState = 'empty_state';
  static const String emptyStateMainMessage = 'empty_state.main_message';

  static const String dialogDelete = 'dialog_delete';
  static const String dialogDeleteTitle = 'dialog_delete.title';
  static const String dialogDeleteContent = 'dialog_delete.content';
  static const String dialogDeleteButtonCancel = 'dialog_delete.button_cancel';
  static const String dialogDeleteButtonDelete = 'dialog_delete.button_delete';

  // ENTRY SCREEN
  static const String entryScreen = 'entry_screen';
  static const String entryScreenAppBarTitle = 'entry_screen.app_bar_title';
  static const String entryScreenAddAppBarTitle = 'entry_screen.add_app_bar_title';
  static const String entryScreenUpdateAppBarTitle = 'entry_screen.update_app_bar_title';
  static const String entryScreenButtonSave = 'entry_screen.button_save';
  static const String entryScreenButtonEdit = 'entry_screen.button_edit';
  static const String entryScreenLabelDate = 'entry_screen.label_date';
  static const String entryScreenLabelOdometer = 'entry_screen.label_odometer';
  static const String entryScreenLabelFuelType = 'entry_screen.label_fuel_type';
  static const String entryScreenLabelLiters = 'entry_screen.label_liters';
  static const String entryScreenLabelPricePerLiter = 'entry_screen.label_price_per_liter';
  static const String entryScreenLabelTotalPrice = 'entry_screen.label_total_price';
  static const String entryScreenLabelGasStationOptional = 'entry_screen.label_gas_station_optional';
  static const String entryScreenLabelFullTank = 'entry_screen.label_full_tank';
  static const String entryScreenInfoLastOdometerPrefix = 'entry_screen.info_last_odometer_prefix';
  static const String entryScreenReceiptAddOptional = 'entry_screen.receipt_add_optional';
  static const String entryScreenReceiptSelected = 'entry_screen.receipt_selected';
  static const String entryScreenReceiptPathPrefix = 'entry_screen.receipt_path_prefix';
  static const String entryScreenSnackbarReceiptSelectedPrefix = 'entry_screen.snackbar_receipt_selected_prefix';
  static const String entryScreenSnackbarReceiptErrorPrefix = 'entry_screen.snackbar_receipt_error_prefix';
  static const String entryScreenDialogReceiptTitle = 'entry_screen.dialog_receipt_title';
  static const String entryScreenDialogReceiptOptionCamera = 'entry_screen.dialog_receipt_option_camera';
  static const String entryScreenDialogReceiptOptionGallery = 'entry_screen.dialog_receipt_option_gallery';

  static const String validation = 'validation';
  static const String validationRequiredOdometer = 'validation.required_odometer';
  static const String validationOdometerMustBeGreater = 'validation.odometer_must_be_greater';
  static const String validationRequiredFuelType = 'validation.required_fuel_type';
  static const String validationRequiredValidLiters = 'validation.required_valid_liters';
  static const String validationRequiredValidPricePerLiter = 'validation.required_valid_price_per_liter';
  static const String validationRequiredValidTotalPrice = 'validation.required_valid_total_price';
  static const String validationPriceInconsistencyAlert = 'validation.price_inconsistency_alert';

  static const String backupRestoreAppBarTitle = 'backup_restore.app_bar_title';
  static const String backupRestoreErrorDbNotOpen = 'backup_restore.error_db_not_error';
  static const String backupRestoreErrorDbNotInitialized = 'backup_restore.error_db_not_initialized';
  static const String backupRestoreExportCardTitle = 'backup_restore.export_card_title';
  static const String backupRestoreExportCardDescription = 'backup_restore.export_card_description';
  static const String backupRestoreExportButton = 'backup_restore.export_button';
  static const String backupRestoreExportSuccessPrefix = 'backup_restore.export_success_prefix';
  static const String backupRestoreErrorExport = 'backup_restore.error_export';
  static const String backupRestoreImportCardTitle = 'backup_restore.import_card_title';
  static const String backupRestoreImportCardDescription = 'backup_restore.import_card_description';
  static const String backupRestoreImportButton = 'backup_restore.import_button';
  static const String backupRestoreImportNoFileSelected = 'backup_restore.import_no_file_selected';
  static const String backupRestoreImportSuccess = 'backup_restore.import_success';
  static const String backupRestoreErrorImport = 'backup_restore.error_import';
  static const String backupRestoreLoadingExport = 'backup_restore.loading_export';
  static const String backupRestoreLoadingImport = 'backup_restore.loading_import';
  static const String backupRestoreDbNotReady = 'backup_restore.db_not_ready';
  static const String backupRestoreErrorInitializeDb = 'backup_restore.error_initialize_db';

  static const String toolsScreen = 'tools_screen';
  static const String toolsScreenAppBarTitle = 'tools_screen.app_bar_title';
  static const String toolsScreenAppearanceTitle = 'tools_screen.appearance_title';
  static const String toolsScreenAppearanceDescription = 'tools_screen.appearance_description';
  static const String appearanceSettingsTitle = 'tools_screen.appearance_settings_title';
  static const String themeSectionTitle = 'tools_screen.theme_section_title';
  static const String themeOptionLight = 'tools_screen.theme_option_light';
  static const String themeOptionDark = 'tools_screen.theme_option_dark';
  static const String themeOptionSystem = 'tools_screen.theme_option_system';
  static const String fontSizeSectionTitle = 'tools_screen.fontSize_section_title';
  static const String fontSizeSmall = 'tools_screen.fontSize_small';
  static const String fontSizeMedium = 'tools_screen.fontSize_medium';
  static const String fontSizeLarge = 'tools_screen.fontSize_large';
  static const String toolsScreenLanguageCardTitle = 'tools_screen.language_card_title';
  static const String toolsScreenLanguageCardDescription = 'tools_screen.language_card_description';
  static const String toolsScreenLanguageSnackbarMessage = 'tools_screen.language_snackbar_message';
  static const String toolsScreenUnitCardTitle = 'tools_screen.unit_card_title';
  static const String toolsScreenUnitCardDescription = 'tools_screen.unit_card_description';
  static const String toolsScreenCurrencyCardTitle = 'tools_screen.currency_card_title';
  static const String toolsScreenCurrencyCardDescription = 'tools_screen.currency_card_description';
  static const String toolsScreenNotificationCardTitle = 'tools_screen.notification_card_title';
  static const String toolsScreenNotificationCardDescription = 'tools_screen.notification_card_description';
  static const String toolsScreenExportReportCardTitle = 'tools_screen.export_report_card_title';
  static const String toolsScreenExportReportCardDescription = 'tools_screen.export_report_card_description';
  static const String toolsScreenClearAllDataCardTitle = 'tools_screen.clear_all_data_card_title';
  static const String toolsScreenClearAllDataCardDescription = 'tools_screen.clear_all_data_card_description';
  static const String toolsScreenBackupCardTitle = 'tools_screen.backup_card_title';
  static const String toolsScreenBackupCardDescription = 'tools_screen.backup_card_description';

  static const String unitSettingsScreenTitle = 'unit_settings.title';
  static const String unitSettingsScreenSubtitle = 'unit_settings.subtitle';
  static const String unitSettingsScreenDistance = 'unit_settings.distance_unit';
  static const String unitSettingsScreenVolume = 'unit_settings.volume_unit';
  static const String unitSettingsScreenConsumption = 'unit_settings.consumption_unit';
  static const String unitSettingsScreenKilometers = 'unit_settings.kilometers';
  static const String unitSettingsScreenMiles = 'unit_settings.miles';
  static const String unitSettingsScreenLiters = 'unit_settings.liters';
  static const String unitSettingsScreenGallons = 'unit_settings.gallons';
  static const String unitSettingsScreenKmPerLiter = 'unit_settings.km_per_liter';
  static const String unitSettingsScreenLitersPer100km = 'unit_settings.liters_per_100km';
  static const String unitSettingsScreenMpg = 'unit_settings.mpg';

  static const String maintenanceScreenTitle = "maintenance.title";
  static const String maintenanceAlertTitle = "maintenance.alert_title";
  static const String maintenanceAlertByKm = "maintenance.alert_by_km";
  static const String maintenanceAlertByDate = "maintenance.alert_by_date";
  static const String maintenanceSnackbarAdded = "maintenance.snackbar_added";
  static const String emptyStateMaintenanceMessage = "maintenance.empty_message";

  static const String maintenanceFormServiceType = "maintenance.form_service_type";
  static const String maintenanceFormCost = "maintenance.form_cost";
  static const String maintenanceFormNotes = "maintenance.form_notes";
  static const String maintenanceFormReminderSection = "maintenance.form_reminder_section";
  static const String maintenanceFormEnableReminder = "maintenance.form_enable_reminder";
  static const String maintenanceFormReminderKm = "maintenance.form_reminder_km";
  static const String maintenanceFormReminderDate = "maintenance.form_reminder_date";
  static const String maintenanceFormSaveButton = "maintenance.form_save_button";

  static const String maintenanceServiceAddNew = 'maintenance.service_add_new';
  static const String maintenanceDialogAddServiceTitle = 'maintenance.add_service_title';
  static const String maintenanceDialogAddServiceLabel = 'maintenance.add_service_label';
  static const String maintenanceDialogAddServiceHint = 'maintenance.add_service_hint';
  static const String maintenanceDialogButtonAdd = 'maintenance.dialog_button_add';
  static const String maintenanceDialogButtonCancel = 'maintenance.dialog_button_cancel';
  static const String validationRequiredServiceType = 'maintenance.validation_required_service';
  static const String maintenanceServiceOilChange = "maintenance.service_oil_change";
  static const String maintenanceServiceTireRotation = "maintenance.service_tire_rotation";
  static const String maintenanceServiceBrakePads = "maintenance.service_brake_pads";
  static const String maintenanceServiceGeneralInspect = "maintenance.service_general_inspection";

  static const String fuelTypeGasolineComum = "maintenance.gasoline_comum";
  static const String fuelTypeGasolineAditivada = "maintenance.gasoline_aditivada";
  static const String fuelTypeEthanolAlcool = "maintenance.etanol_alcool";
  static const String fuelTypeGasolinePremium = "maintenance.gasoline_premium";
  static const String fuelTypeOther = "maintenance.other";

  static const String updateServiceUpdateAvailable = "update_service.update_available";
  static const String updateServiceCurrentVersion = "update_service.current_version";
  static const String updateServiceNewVersion = "update_service.new_version";
  static const String updateServiceLater = "update_service.later";
  static const String updateServiceDownload = "update_service.download";

  static const String errorCouldNotOpenUrl = 'error.could_not_open_url';
}

class TrHelper {
  static String errorUrlFormat(BuildContext context, String url){
    return context.tr(
      TranslationKeys.errorCouldNotOpenUrl,
      parameters: {'url': url},
    );
  }

  static String versionFormat(BuildContext context, String version, {bool isNew = false}) {
    final key = isNew ? 'tools.new_version': 'tools.current_version';
    return context.tr(key, parameters: {'version': version});
  }
}