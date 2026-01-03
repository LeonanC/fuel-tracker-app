import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/controllers/language_controller.dart';
import 'package:get/get.dart';

class AppLocalizations {
  static LanguageController get _controller => Get.find<LanguageController>();

  static String translate(String key, {Map<String, String>? parameters}) {
    return _controller.translate(key, parameters: parameters);
  }

  static String tr(String key, {Map<String, String>? parameters}) {
    return translate(key, parameters: parameters);
  }

  static String get currentLanguageCode => _controller.currentLanguage.code;
  static String get currentLanguageName => _controller.currentLanguage.name;
  static bool get isRtl => _controller.isRtl;
  static TextDirection get textDirection => _controller.textDirection;
  static Locale get locale => _controller.locale;

  static AppLocalizations of(BuildContext? context) {
    return AppLocalizations();
  }

  static bool hasTranslation(String key) {
    return _controller.hasTranslation(key);
  }
}

extension LocalizationExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);

  String tr(String key, {Map<String, String>? parameters}) {
    return AppLocalizations.tr(key, parameters: parameters);
  }

  bool hasTranslation(String key) {
    return AppLocalizations.hasTranslation(key);
  }

  String get currentLanguageCode => AppLocalizations.currentLanguageCode;
  bool get isRtl => AppLocalizations.isRtl;
  TextDirection get textDirection => AppLocalizations.textDirection;
}

extension LocalizedStateMixin<T extends StatefulWidget> on State<T> {
  AppLocalizations get loc => AppLocalizations.of(context);

  String tr(String key, {Map<String, String>? parameters}) {
    return AppLocalizations.tr(key, parameters: parameters);
  }

  bool hasTranslation(String key) {
    return AppLocalizations.hasTranslation(key);
  }

  String get currentLanguageCode => AppLocalizations.currentLanguageCode;
  bool get isRtl => AppLocalizations.isRtl;
  TextDirection get textDirection => AppLocalizations.textDirection;
}

mixin LocalizedStatelessMixin {
  AppLocalizations loc(BuildContext? context) => AppLocalizations.of(context);

  String tr(String key, {Map<String, String>? parameters}) {
    return AppLocalizations.tr(key, parameters: parameters);
  }

  bool hasTranslation(String key) {
    return AppLocalizations.hasTranslation(key);
  }

  String get currentLanguageCode => AppLocalizations.currentLanguageCode;
  bool get isRtl => AppLocalizations.isRtl;
  TextDirection get textDirection => AppLocalizations.textDirection;
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
  static const String aboutCurrentVersion = 'about.currentVersion';
  static const String aboutTagline = 'about.tagline';
  static const String aboutDevelopedBy = 'about.developed_by';
  static const String aboutDeveloper = 'about.developer';
  static const String aboutDescription = 'about.description';
  static const String aboutGithubSource = 'about.githubSource';
  static const String aboutPrivacyPolicy = 'about.privacyPolicy';
  static const String aboutTermsOfService = 'about.termsOfService';
  static const String aboutCopyright = 'about.copyright';
  static const String aboutUpdateService = 'about.updateServiceCheckForUpdates';
  static const String aboutErrorTitle = 'about.errorTitle';
  static const String aboutFailedToLaunchUrl = 'about.errorFailedToLaunchUrl';

  // Navigation
  static const String navigation = 'navigation';
  static const String navigationFuelEntries = 'navigation.fuel_entries';
  static const String navigationMaintenance = 'navigation.fuel_maintenance';
  static const String navigationMap = 'navigation.fuel_maps';
  static const String navigationFuelTools = 'navigation.fuel_tools';

  // List Screen
  static const String listScreen = 'list_screen';
  static const String listScreenAppBarTitle = 'list_screen.app_bar_title';
  static const String listScreenRefresh = 'list_screen.refresh';
  static const String listScreenRefreshing = 'list_screen.refreshing';
  static const String listScreenSnackbarEntryAdded = 'list_screen.snackbar_entry_added';
  static const String listScreenSnackbarEntryUpdated = 'list_screen.snackbar_entry_updated';
  static const String listScreenSnackbarEntryRemoved = 'list_screen.snackbar_entry_removed';

  static const String mapPlaceholder = 'map_screen.map_placeholder';
  static const String mapPlaceholderTip = 'map_screen.map_placeholder_tip';
  static const String mapSearchAction = 'map_screen.map_search_action';
  static const String mapLoadingLocation = 'map_screen.map_loading_location';
  static const String mapSearchError = 'map_screen.map_search_error';
  static const String mapSearchNoResults = 'map_screen.map_search_no_results';
  static const String mapSearchCheapestGasStation = 'map_screen.map_search_cheapest_gas_station';
  static const String mapLocationServiceDisabled = 'map_screen.map_location_service_disabled';
  static const String mapPermissionDenied = 'map_screen.map_permission_denied';
  static const String mapPermissionDeniedForever = 'map_screen.map_permission_denied_forever';

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
  static const String consumptionCardsOverallCostPerDistance =
      'consumption_cards.overall_cost_per_distance';
  static const String consumptionCardsOverallAverage = 'consumption_cards.overall_average';
  static const String consumptionCardsNotAvailableShort = 'consumption_cards.not_available_short';
  static const String consumptionCardsUnitKmPerLiter = 'consumption_cards.unit_km_l';
  static const String consumptionCardsConsumptionPeriod = 'consumption_cards.consumption_period';

  static const String alerts = 'alerts';
  static const String alertsThresholdMsg1 = 'alerts.alert_threshold_msg_1';
  static const String alertsThresholdMsg2 = 'alerts.alert_threshold_msg_2';

  static const String emptyState = 'empty_state';
  static const String emptyStateMainMessage = 'empty_state.main_message';

  static const String dialogDelete = 'dialog_delete';
  static const String dialogDeleteTitle = 'dialog_delete.title';
  static const String dialogDeleteContent = 'dialog_delete.content';
  static const String dialogDeleteButtonCancel = 'dialog_delete.button_cancel';
  static const String dialogDeleteButtonDelete = 'dialog_delete.button_delete';

  // ENTRY SCREEN
  static const String entryScreen = 'entry_screen';
  static const String entryScreenTitleEdit = 'entry_screen.title_edit';
  static const String entryScreenTitleNew = 'entry_screen.title_new';
  static const String entryScreenButtonSave = 'entry_screen.button_save';
  static const String entryScreenButtonEdit = 'entry_screen.button_edit';
  static const String entryScreenLabelDate = 'entry_screen.label_date';
  static const String entryScreenLabelOdometer = 'entry_screen.label_odometer';
  static const String entryScreenLabelFuelType = 'entry_screen.label_fuel_type';
  static const String entryScreenLabelLiters = 'entry_screen.label_liters';
  static const String entryScreenLabelPricePerLiter = 'entry_screen.label_price_per_liter';
  static const String entryScreenLabelTotalPrice = 'entry_screen.label_total_price';
  static const String entryScreenLabelVeiculos = 'entry_screen.label_veiculos';
  static const String entryScreenLabelGasStation = 'entry_screen.label_gas_station';
  static const String entryScreenLabelFullTank = 'entry_screen.label_full_tank';
  static const String entryScreenInfoLastOdometerPrefix = 'entry_screen.info_last_odometer_prefix';
  static const String entryScreenInfoLastOdometerPrefix2 =
      'entry_screen.info_last_odometer_prefix_2';
  static const String entryScreenReceiptAddOptional = 'entry_screen.receipt_add_optional';
  static const String entryScreenReceiptSelected = 'entry_screen.receipt_selected';
  static const String entryScreenReceiptPathPrefix = 'entry_screen.receipt_path_prefix';
  static const String entryScreenSnackbarReceiptSelectedPrefix =
      'entry_screen.snackbar_receipt_selected_prefix';
  static const String entryScreenSnackbarReceiptErrorPrefix =
      'entry_screen.snackbar_receipt_error_prefix';
  static const String entryScreenDialogReceiptTitle = 'entry_screen.dialog_receipt_title';
  static const String entryScreenDialogReceiptOptionCamera =
      'entry_screen.dialog_receipt_option_camera';
  static const String entryScreenDialogReceiptOptionGallery =
      'entry_screen.dialog_receipt_option_gallery';
  static const String entryScreenValidadeOdometerMustBeGreater =
      'entry_screen.validade_odometer_greater';
  static const String entryScreenErrorOdometerTitle = 'entry_screen.error_odometer_title';
  static const String entryScreenErrorOdometerMessage = 'entry_screen.error_odometer_message';

  static const String validation = 'validation';
  static const String validationRequiredOdometer = 'validation.required_odometer';
  static const String validationOdometerMustBeGreater = 'validation.odometer_must_be_greater';
  static const String validationRequiredVeiculos = 'validation.required_veiculos';
  static const String validationRequiredFuelType = 'validation.required_fuel_type';
  static const String validationRequiredValidLiters = 'validation.required_valid_liters';
  static const String validationRequiredValidPricePerLiter =
      'validation.required_valid_price_per_liter';
  static const String validationRequiredValidTotalPrice = 'validation.required_valid_total_price';
  static const String validationPriceInconsistencyAlert = 'validation.price_inconsistency_alert';

  static const String toolsScreen = 'tools_screen';
  static const String toolsScreenAppBarTitle = 'tools_screen.app_bar_title';
  static const String toolsScreenSectionTitle = 'tools_screen.section_title';
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
  static const String toolsScreenNotificationCardDescription =
      'tools_screen.notification_card_description';
  static const String toolsScreenExportReportCardTitle = 'tools_screen.export_report_card_title';
  static const String toolsScreenExportReportCardDescription =
      'tools_screen.export_report_card_description';
  static const String toolsScreenClearAllDataCardTitle = 'tools_screen.clear_all_data_card_title';
  static const String toolsScreenClearAllDataCardDescription =
      'tools_screen.clear_all_data_card_description';
  static const String toolsScreenBackupCardTitle = 'tools_screen.backup_card_title';
  static const String toolsScreenBackupCardDescription = 'tools_screen.backup_card_description';
  static const String toolsScreenStatisticsTitle = 'tools_screen.statistics_title';
  static const String toolsScreenStatisticsDescription = 'tools_screen.statistics_description';
  static const String toolsScreenFeedbackTitle = 'tools_screen.feedback_title';
  static const String toolsScreenFeedbackDescription = 'tools_screen.feedback_description';
  static const String toolsScreenSummaryTitle = 'tools_screen.summary_title';
  static const String toolsScreenConsumptionTitle =
      'tools_screen.statistics_monthly_consumption_title';
  static const String toolsScreenAvgPriceTitle = 'tools_screen.statistics_monthly_avg_price_title';
  static const String toolsScreenTotalDistancia = 'tools_screen.total_distance';
  static const String toolsScreenTotalVolume = 'tools_screen.total_volume';
  static const String toolsScreenTotalCost = 'tools_screen.total_cost';
  static const String toolsScreenAverageConsumption = 'tools_screen.average_consumption';
  static const String toolsScreenAveragePricePerLiter = 'tools_screen.average_price_per_liter';

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
  static const String unitSettingsScreenBRL = 'unit_settings.brl';
  static const String unitSettingsScreenUSD = 'unit_settings.usd';
  static const String unitSettingsScreenEUR = 'unit_settings.eur';

  static const String maintenanceScreenTitle = "maintenance.title";
  static const String maintenanceAlertTitle = "maintenance.alert_title";
  static const String maintenanceAlertByKm = "maintenance.alert_by_km";
  static const String maintenanceAlertByDate = "maintenance.alert_by_date";
  static const String maintenanceRefresh = "maintenance.refresh";
  static const String maintenanceRefreshing = "maintenance.refreshing";
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

  static const String postoTypePosto66 = 'maintenance.posto_66';
  static const String postoTypePostoIA = 'maintenance.posto_IA';
  static const String postoTypePostoBR = 'maintenance.posto_Bragas';
  static const String postoTypePostoPE = 'maintenance.posto_Petrobras';
  static const String postoTypePostoAX = 'maintenance.posto_AMRX';
  static const String postoTypePostoAL = 'maintenance.posto_Ale';
  static const String postoTypePostoGNV = 'maintenance.posto_GNV';
  static const String postoTypePostoGA = 'maintenance.posto_Gasolina';

  static const String updateServiceUpdateAvailable = "update_service.update_available";
  static const String updateServiceCheckForUpdates = "update_service.check_for_updates";
  static const String updateServiceCurrentVersion = "update_service.current_version";
  static const String updateServiceNewVersion = "update_service.new_version";
  static const String updateServiceLater = "update_service.later";
  static const String updateServiceDownload = "update_service.download";
  static const String updateServiceNoUpdate = "update_service.service_no_update";
  static const String updateServiceUrlError = "update_service.url_error";
  static const String updateServiceCheckFailed = "update_service.check_failed";

  static const String errorCouldNotOpenUrl = 'error.could_not_open_url';
  static const String dialogFilterTitle = "dialog_filter.filter_title";
  static const String dialogFilterSelectFilters = "dialog_filter.select_filters";
  static const String dialogFilterChartStructureTitle = "dialog_filter.chart_structure_title";
  static const String dialogFilterChartStructureBody = "dialog_filter.chart_structure_body";
  static const String dialogFilterChartPlaceholder = "dialog_filter.chart_placeholder";
  static const String dialogFilterOptionsTitle = "dialog_filter.options_title";
  static const String dialogFilterFuelTypeSuffix = "dialog_filter.fuel_type_suffix";
  static const String dialogFilterFilterClearFilter = "dialog_filter.filter_clear_filter";
  static const String dialogFilterFilterApply = "dialog_filter.filter_apply";

  

  static const String gasStationScreenTitle = 'gasstation.title';
  static const String gasStationUpdateTitle = 'gasstation.title_edit';
  static const String gasStationAddTitle = 'gasstation.title_new';
  static const String gasStationLabelName = 'gasstation.label_name';
  static const String gasStationLabelAddress = 'gasstation.label_address';
  static const String gasStationLabelBrand = 'gasstation.label_brand';
  static const String gasStationLabelLatitude = 'gasstation.label_latitude';
  static const String gasStationLabelLongitude = 'gasstation.label_longitude';
  static const String gasStationLabelPriceGasoline = 'gasstation.label_price_gasoline';
  static const String gasStationLabelPriceEthanol = 'gasstation.label_price_ethanol';
  static const String gasStationLabelConvenienceStore = 'gasstation.label_convenience_store';
  static const String gasStationLabel24Hours = 'gasstation.label_24hours';
  static const String gasStationRequiredFieldName = 'gasstation.required_name';
  static const String gasStationRequiredFieldBrand = 'gasstation.required_brand';
  static const String gasStationRequiredValidLatitude = 'gasstation.required_valid_latitude';
  static const String gasStationRequiredValidLongitude = 'gasstation.required_valid_longitude';
  static const String gasStationRequiredValidPrice = 'gasstation.required_valid_price';
  static const String gasStationButtonDelete = 'gasstation.button_delete';
  static const String gasStationButtonDeleteSubtitle = 'gasstation.button_delete_subtitle';
  static const String gasStationButtonDeleteConfirm = 'gasstation.button_delete_confirm';
  static const String gasStationButtonDeleteCancel = 'gasstation.button_delete_cancel';
  static const String gasStationButtonCancel = 'gasstation.button_cancel';
  static const String gasStationButtonSave = 'gasstation.button_save';

  static const String onboardingsTitle1 = 'onboardings.onboarding_title_1';
  static const String onboardingsDesc1 = 'onboardings.onboarding_desc_1';
  static const String onboardingsTitle2 = 'onboardings.onboarding_title_2';
  static const String onboardingsDesc2 = 'onboardings.onboarding_desc_2';
  static const String onboardingsTitle3 = 'onboardings.onboarding_title_3';
  static const String onboardingsDesc3 = 'onboardings.onboarding_desc_3';
  static const String onboardingsButtonStart = 'onboardings.onboarding_button_start';
  static const String onboardingsButtonNext = 'onboardings.onboarding_button_next';
  static const String onboardingsButtonSkip = 'onboardings.onboarding_button_skip';
}

class TrHelper {
  static final LanguageController _languageController = Get.find<LanguageController>();

  static String tr(String key, {Map<String, String>? parameters}) {
    return _languageController.translate(key, parameters: parameters);
  }

  static String errorUrlFormat(String url) {
    return tr(TranslationKeys.errorCouldNotOpenUrl, parameters: {'url': url});
  }

  static String versionFormat(String version, {bool isNew = false}) {
    final key = isNew ? 'tools_screen.new_version' : 'tools_screen.current_version';
    return tr(key, parameters: {'version': version});
  }
}
