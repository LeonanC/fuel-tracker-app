import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/provider/currency_provider.dart';
import 'package:fuel_tracker_app/provider/fuel_entry_provider.dart';
import 'package:fuel_tracker_app/provider/language_provider.dart';
import 'package:fuel_tracker_app/provider/unit_provider.dart';
import 'package:fuel_tracker_app/screens/about_screen.dart';
import 'package:fuel_tracker_app/screens/fuel_entry_screen.dart';
import 'package:fuel_tracker_app/services/application.dart';
import 'package:fuel_tracker_app/services/update_service.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

class FuelListScreen extends StatefulWidget {
  const FuelListScreen({super.key});

  @override
  State<FuelListScreen> createState() => _FuelListScreenState();
}

class _FuelListScreenState extends State<FuelListScreen> {
  static const double _alertThresholdKm = 100.0;
  static const double _kmToMileFactor = 0.621371;
  static const double _kmPerLiterToMPGFactor = 2.3521458;

  String? _selectedFuelTypeFilter;
  String? _selectedStationFilter;

  final List<String> _mockStations = [
    'Posto 66 - Ipiranga',
    'Posto Itaipuaçu AmPm',
    'Posto Bragas (BR)',
    'Posto Petrobras',
    'Posto Amrx',
    'Posto Ale',
    'Auto Gas GNV',
    'Posto Gasolina'
  ];

  late final Map<String, String> _fuelTypeMap;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FuelEntryProvider>().loadFuelEntries();

      UpdateService().checkForUpdate(context);

      _fuelTypeMap = {
        'Gasolina Comum': context.tr(TranslationKeys.fuelTypeGasolineComum),
        'Gasolina Aditivada': context.tr(TranslationKeys.fuelTypeGasolineAditivada),
        'Etanol (Álcool)': context.tr(TranslationKeys.fuelTypeEthanolAlcool),
        'Gasolina Premium': context.tr(TranslationKeys.fuelTypeGasolinePremium),
        'Outro': context.tr(TranslationKeys.fuelTypeOther),
      };
    });
  }

  void _navigateAndSaveEntry(BuildContext context) async {
    final FuelEntryProvider provider = context.read<FuelEntryProvider>();
    final currentOdometer = provider.lastOdometer;

    final entry = await Navigator.of(context).push<FuelEntry>(
      MaterialPageRoute(builder: (context) => FuelEntryScreen(lastOdometer: currentOdometer)),
    );

    if (entry != null) {
      await provider.insertEntry(entry);
    }
  }

  double _calculateOverallTotalDistance(List<FuelEntry> entries) {
    if (entries.length < 2) return 0.0;
    return entries.first.quilometragem.toDouble() - entries.last.quilometragem.toDouble();
  }

  double _calculateOverallTotalCost(List<FuelEntry> entries) {
    double totalCost = 0.0;
    for (final entry in entries) {
      totalCost += entry.totalPrice ?? 0.0;
    }
    return totalCost;
  }

  double _calculateOverallCostPerDistance(List<FuelEntry> entries) {
    final totalDistanceKm = _calculateOverallTotalDistance(entries);
    if (totalDistanceKm <= 0) return 0.0;
    final totalCost = _calculateOverallTotalCost(entries);
    return totalCost / totalDistanceKm;
  }

  String _formatConsumption(BuildContext context, double kmPerLiterValue, ConsumptionUnit unit) {
    String unitStr;
    double formattedValue;

    switch (unit) {
      case ConsumptionUnit.kmPerLiter:
        unitStr = context.tr(TranslationKeys.unitSettingsScreenKmPerLiter);
        formattedValue = kmPerLiterValue;
        break;
      case ConsumptionUnit.litersPer100km:
        unitStr = context.tr(TranslationKeys.unitSettingsScreenLitersPer100km);
        formattedValue = kmPerLiterValue > 0 ? (100 / kmPerLiterValue) : 0;
        break;
      case ConsumptionUnit.milesPerGallon:
        unitStr = context.tr(TranslationKeys.unitSettingsScreenMpg);
        formattedValue = kmPerLiterValue * _kmPerLiterToMPGFactor;
        break;
    }

    return formattedValue.toStringAsFixed(2);
  }

  String _getConsumptionUnitString(BuildContext context, ConsumptionUnit unit) {
    String key;
    switch (unit) {
      case ConsumptionUnit.kmPerLiter:
        key = TranslationKeys.unitSettingsScreenKmPerLiter;
        break;
      case ConsumptionUnit.litersPer100km:
        key = TranslationKeys.unitSettingsScreenLitersPer100km;
        break;
      case ConsumptionUnit.milesPerGallon:
        key = TranslationKeys.unitSettingsScreenMpg;
        break;
    }

    return context.tr(key).replaceAll(RegExp(r'\(.*\)'), '').trim();
  }

  Widget _buildOverallConsumptionCard(
    BuildContext context,
    List<FuelEntry> entries,
    double overallConsumption,
    double overallCostPerDistance,
  ) {
    final unitProvider = context.read<UnitProvider>();
    final currencyProvider = context.read<CurrencyProvider>();
    final isZero = overallConsumption <= 0;
    final isCostZero = overallCostPerDistance <= 0;

    final ConsumptionUnit selectedUnit = unitProvider.consumptionUnit;
    final String formattedValue = _formatConsumption(context, overallConsumption, selectedUnit);
    final String unitString = _getConsumptionUnitString(context, selectedUnit);

    final bool isMiles = unitProvider.distanceUnit == DistanceUnit.miles;
    final double costPerDistanceToDisplay = isMiles
        ? (overallCostPerDistance / _kmToMileFactor)
        : overallCostPerDistance;
    final String distanceUnitStr = context
        .tr(
          isMiles
              ? TranslationKeys.unitSettingsScreenMiles
              : TranslationKeys.unitSettingsScreenKilometers,
        )
        .replaceAll(RegExp(r'\(.*\)'), '')
        .trim();
    final String costPerDistanceUnit =
        '${currencyProvider.selectedCurrency.symbol}/$distanceUnitStr';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  RemixIcons.dashboard_line,
                  color: Theme.of(context).colorScheme.primary,
                  size: 30,
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    context.tr(TranslationKeys.consumptionCardsOverallAverage),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    isZero
                        ? context.tr(TranslationKeys.consumptionCardsNotAvailableShort)
                        : '$formattedValue $unitString',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isZero ? Colors.grey : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            if (!isZero && !isCostZero) const Divider(height: 24),

            Row(
              children: [
                Icon(
                  RemixIcons.money_dollar_box_line,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 30,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(TranslationKeys.consumptionCardsOverallCostPerDistance),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCostZero
                            ? context.tr(TranslationKeys.consumptionCardsNotAvailableShort)
                            : '${costPerDistanceToDisplay.toStringAsFixed(3)} $costPerDistanceUnit',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFuelAlertCard(
    BuildContext context,
    List<FuelEntry> entries,
    double overallConsumption,
  ) {
    final unitProvider = context.read<UnitProvider>();

    if (entries.length < 2 || overallConsumption <= 0) {
      return null;
    }

    final lastEntry = entries.first;
    final previousEntry = entries[1];

    final double estimatedTankSize = 44.0;

    final distanceSinceLastFill =
        (lastEntry.quilometragem).toDouble() - (previousEntry.quilometragem).toDouble();
    final double totalEstimatedRange = estimatedTankSize * overallConsumption;
    final double estimatedRange = totalEstimatedRange - distanceSinceLastFill;

    if (estimatedRange < _alertThresholdKm) {
      final bool isMiles = unitProvider.distanceUnit == DistanceUnit.miles;
      final double rangeToDisplay = isMiles ? (estimatedRange * _kmToMileFactor) : estimatedRange;
      final String displayRange = rangeToDisplay.toStringAsFixed(0);

      final String distanceUnitStr = context
          .tr(
            isMiles
                ? TranslationKeys.unitSettingsScreenMiles
                : TranslationKeys.unitSettingsScreenKilometers,
          )
          .replaceAll(RegExp(r'\(.*\)'), '')
          .trim();

      final double litersFilled = (lastEntry.litros).toDouble();
      final double trajetConsumptionKmPerLiter = (litersFilled > 0 && distanceSinceLastFill >= 0)
          ? distanceSinceLastFill / litersFilled
          : 0.0;

      final String displayTrajetConsumption = _formatConsumption(
        context,
        trajetConsumptionKmPerLiter,
        unitProvider.consumptionUnit,
      );
      final String consumptionUnitStr = _getConsumptionUnitString(
        context,
        unitProvider.consumptionUnit,
      );

      final versionLabel1 = context.tr(TranslationKeys.alertsThresholdMsg1);
      final versionLabel2 = context.tr(TranslationKeys.alertsThresholdMsg2);
      final alertText0 = '$displayRange $distanceUnitStr';
      final alertText1 = '$displayTrajetConsumption $consumptionUnitStr';

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Card(
          color: Colors.orange[50],
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.local_gas_station, color: Colors.orange[800]),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    '$versionLabel1 $alertText0 $versionLabel2 $alertText1',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.orange[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final FuelEntryProvider fuelEntryProvider = context.watch<FuelEntryProvider>();
    final allEntries = fuelEntryProvider.fuelEntries;

    final filteredEntries = allEntries.where((entry) {
      bool matchesFuelType =
          _selectedFuelTypeFilter == null || entry.tipo == _selectedFuelTypeFilter;
      bool matchesStation = _selectedStationFilter == null || entry.posto == _selectedStationFilter;
      return matchesFuelType && matchesStation;
    }).toList();

    final overallConsumption = fuelEntryProvider.calculateOverallAverageConsumption(
      entries: filteredEntries,
    );
    final entries = fuelEntryProvider.fuelEntries;
    final overallCostPerDistance = _calculateOverallCostPerDistance(entries);

    final fuelAlertCard = _buildFuelAlertCard(context, filteredEntries, overallConsumption);

    PopupMenuItem<String> buildFuelTypeItem(String key, String value, bool isSelected) {
      return PopupMenuItem<String>(
        value: 'SetFuel:$key',
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 20,
              color: isSelected ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        ),
      );
    }

    PopupMenuItem<String> buildStationItem(String station, bool isSelected) {
      return PopupMenuItem<String>(
        value: 'SetStation:$station',
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 20,
              color: isSelected ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              station,
              style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        ),
      );
    }

    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            backgroundColor: theme.brightness == Brightness.dark
                ? AppTheme.backgroundColorDark
                : AppTheme.backgroundColorLight,
            appBar: AppBar(
              title: Text(context.tr(TranslationKeys.listScreenAppBarTitle)),
              backgroundColor: theme.brightness == Brightness.dark
                  ? AppTheme.backgroundColorDark
                  : AppTheme.backgroundColorLight,
              elevation: 0,
              centerTitle: false,
              actions: [
                IconButton(
                  icon: Icon(RemixIcons.refresh_line),
                  tooltip: context.tr(TranslationKeys.listScreenTooltipRefresh),
                  onPressed: () async {
                    context.read<FuelEntryProvider>().loadFuelEntries();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr(TranslationKeys.listScreenSnackbarRefreshing)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.info_outline),
                  tooltip: context.tr(TranslationKeys.aboutTitle),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutScreen()),
                    );
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      if (value == 'ClearFuel') {
                        _selectedFuelTypeFilter = null;
                      } else if (value.startsWith('SetFuel:')) {
                        final type = value.substring(8);
                        _selectedFuelTypeFilter = type;
                      } else if (value == 'ClearStation') {
                        _selectedStationFilter = null;
                      } else if (value.startsWith('SetStation:')) {
                        final station = value.substring(11);
                        _selectedStationFilter = station;
                      }
                    });
                  },
                  icon: Icon(RemixIcons.filter_line),
                  tooltip: context.tr(TranslationKeys.dialogFilterTitle),
                  itemBuilder: (BuildContext context) {
                    final List<PopupMenuEntry<String>> items = [];

                    items.add(
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Text(
                          context.tr(TranslationKeys.dialogFilterTitle),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                    items.add(const PopupMenuDivider());
                    items.add(
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Text(
                          'Filtro por Tipo de Combustível:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                    items.addAll(
                      _fuelTypeMap.entries.map((entry) {
                        return buildFuelTypeItem(
                          entry.key,
                          entry.value,
                          _selectedFuelTypeFilter == entry.key,
                        );
                      }),
                    );
                    items.add(
                      PopupMenuItem<String>(
                        value: 'ClearFuel',
                        child: Text('Limpar Filtro', style: const TextStyle(color: Colors.red)),
                      ),
                    );
                    items.add(const PopupMenuDivider());
                    items.add(
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Text(
                          'Filtro por Posto:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                    items.addAll(
                      _mockStations.map((station) {
                        return buildStationItem(station, _selectedStationFilter == station);
                      }),
                    );
                    items.add(
                      PopupMenuItem<String>(
                        value: 'ClearStation',
                        child: Text('Limpar Filtro', style: const TextStyle(color: Colors.red)),
                      ),
                    );
                    items.add(const PopupMenuDivider());
                    items.add(
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Text(
                          'Filtro por Período: (Em Breve)',
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                      ),
                    );
                    return items;
                  },
                ),
              ],
            ),
            body: fuelEntryProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      _buildOverallConsumptionCard(
                        context,
                        filteredEntries,
                        overallConsumption,
                        overallCostPerDistance,
                      ),
                      if (fuelAlertCard != null) fuelAlertCard,
                      Expanded(
                        child: fuelEntryProvider.fuelEntries.isEmpty
                            ? Center(
                                child: Text(
                                  _selectedFuelTypeFilter != null || _selectedStationFilter != null
                                      ? 'Nenhum item encontrado com os filtros aplicados.'
                                      : 'Ainda não Abasteceu',
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredEntries.length,
                                itemBuilder: (context, index) {
                                  final FuelEntry currentEntry = filteredEntries[index];
                                  final FuelEntry? previousEntry =
                                      (index + 1 < filteredEntries.length)
                                      ? filteredEntries[index + 1]
                                      : null;

                                  double consumptionForThisPeriod = 0.0;

                                  if (previousEntry != null && previousEntry.tanqueCheio != 0) {
                                    consumptionForThisPeriod = currentEntry.calculateConsumption(
                                      previousEntry,
                                    );
                                  }

                                  return _buildFuelEntryListItem(
                                    currentEntry,
                                    context,
                                    consumptionForThisPeriod,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),

            floatingActionButton: FloatingActionButton(
              heroTag: 'fab_fuelentry_list',
              onPressed: () => _navigateAndSaveEntry(context),
              child: Icon(RemixIcons.gas_station_line, color: Colors.white),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _deleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr(TranslationKeys.dialogDeleteTitle)),
          content: Text(context.tr(TranslationKeys.dialogDeleteContent)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.tr(TranslationKeys.dialogDeleteButtonCancel)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(context.tr(TranslationKeys.dialogDeleteButtonDelete)),
            ),
          ],
        );
      },
    );
  }

  Dismissible _buildFuelEntryListItem(
    FuelEntry entry,
    BuildContext context,
    double consumptionForThisPeriod,
  ) {
    final unitProvider = context.read<UnitProvider>();
    final currencySymbol = context.watch<CurrencyProvider>().selectedCurrency.symbol;

    String getFuelType(String type) {
      switch (type) {
        case 'Gasolina Comum':
          return context.tr(TranslationKeys.fuelTypeGasolineComum);
        case 'Gasoline Aditivada':
          return context.tr(TranslationKeys.fuelTypeGasolineAditivada);
        case 'Etanol (Álcool)':
          return context.tr(TranslationKeys.fuelTypeEthanolAlcool);
        case 'Gasolina Premium':
          return context.tr(TranslationKeys.fuelTypeGasolinePremium);
        default:
          return context.tr(TranslationKeys.fuelTypeOther);
      }
    }

    String titleText = getFuelType(entry.tipo);
    if (entry.posto != null && entry.posto!.isNotEmpty) {
      titleText += ' @ ${entry.posto}';
    }

    final bool isMiles = unitProvider.distanceUnit == DistanceUnit.miles;

    final String distanceUnitStr = context
        .tr(
          isMiles
              ? TranslationKeys.unitSettingsScreenMiles
              : TranslationKeys.unitSettingsScreenKilometers,
        )
        .replaceAll(RegExp(r'\(.*\)'), '')
        .trim();

    final double odometerDisplay = isMiles
        ? entry.quilometragem * _kmToMileFactor
        : entry.quilometragem.toDouble();
    final String consumptionDisplay = _formatConsumption(
      context,
      consumptionForThisPeriod,
      unitProvider.consumptionUnit,
    );
    final String consumptionUnitStr = _getConsumptionUnitString(
      context,
      unitProvider.consumptionUnit,
    );

    String subtitleText =
        '${context.tr(TranslationKeys.commonLabelsDate)}: ${DateFormat('dd/MM/yyyy').format(entry.dataAbastecimento)}\n'
        '${context.tr(TranslationKeys.commonLabelsOdometer)}: ${odometerDisplay.toStringAsFixed(0)} $distanceUnitStr\n'
        '${context.tr(TranslationKeys.commonLabelsLiters)}: ${entry.litros.toStringAsFixed(2)} L\n'
        '${context.tr(TranslationKeys.consumptionCardsConsumptionPeriod)}: $consumptionDisplay $consumptionUnitStr';

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(RemixIcons.delete_bin_line, color: Colors.white),
      ),
      confirmDismiss: (direction) => _deleteConfirmation(context),
      onDismissed: (direction) async {
        final provider = context.read<FuelEntryProvider>();
        if (entry.id != null) {
          await provider.deleteEntry(entry.id!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr(TranslationKeys.commonLabelsDeleteConfirmation)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: ListTile(
          leading: Icon(
            entry.tanqueCheio == 1 ? RemixIcons.gas_station_fill : RemixIcons.gas_station_line,
            color: Theme.of(context).colorScheme.secondary,
          ),
          title: Text(
            titleText,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitleText),
          trailing: Text(
            '$currencySymbol ${entry.totalPrice!.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          onTap: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) =>
                        FuelEntryScreen(entry: entry, lastOdometer: entry.quilometragem),
                  ),
                )
                .then((_) {
                  context.read<FuelEntryProvider>().loadFuelEntries();
                });
          },
        ),
      ),
    );
  }
}
