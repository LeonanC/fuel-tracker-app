import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuel_tracker_app/data/fuelentry_db.dart';
import 'package:fuel_tracker_app/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/provider/currency_provider.dart';
import 'package:fuel_tracker_app/provider/fuel_entry_provider.dart';
import 'package:fuel_tracker_app/provider/language_provider.dart';
import 'package:fuel_tracker_app/provider/unit_provider.dart';
import 'package:fuel_tracker_app/screens/fuel_entry_screen.dart';
import 'package:fuel_tracker_app/screens/fuel_edit_entry_screen.dart';
import 'package:fuel_tracker_app/services/application.dart';
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
  static const double _literToGallonFactor = 0.264172;
  static const double _kmPerLiterToMPGFactor = 2.3521458;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FuelEntryProvider>().loadFuelEntries();
    });
  }

  void _navigateAndSaveEntry(BuildContext context) async {
    final FuelEntryProvider provider = context.read<FuelEntryProvider>();
    final currentOdometer = context.read<FuelEntryProvider>().lastOdometer;

    final entry = await Navigator.of(context).push<FuelEntry>(MaterialPageRoute(builder: (context) => FuelEntryScreen(lastOdometer: currentOdometer)));

    if (entry != null) {
      await provider.insertEntry(entry);
    }
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

    return '${formattedValue.toStringAsFixed(2)}';
  }

  Widget _buildOverallConsumptionCard(BuildContext context, double overallConsumption) {
    final unitProvider = context.read<UnitProvider>();
    final isZero = overallConsumption <= 0;

    final String formattedValue = _formatConsumption(context, overallConsumption, unitProvider.consumptionUnit);
    final String unitString = context
        .tr(
          unitProvider.consumptionUnit == ConsumptionUnit.kmPerLiter
              ? TranslationKeys.unitSettingsScreenKmPerLiter
              : unitProvider.consumptionUnit == ConsumptionUnit.litersPer100km
              ? TranslationKeys.unitSettingsScreenLitersPer100km
              : TranslationKeys.unitSettingsScreenMpg,
        )
        .replaceAll(RegExp(r'\(.*\)'), '');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(RemixIcons.dashboard_line, color: Theme.of(context).colorScheme.primary, size: 30),
            const SizedBox(width: 16),
            Flexible(child: Text(context.tr(TranslationKeys.consumptionCardsOverallAverage), style: Theme.of(context).textTheme.titleMedium)),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                isZero ? context.tr(TranslationKeys.consumptionCardsNotAvailableShort) : '$formattedValue $unitString',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: isZero ? Colors.grey : Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFuelAlertCard(BuildContext context, List<FuelEntry> entries, double overallConsumption) {
    final unitProvider = context.read<UnitProvider>();

    if (entries.length < 2 || overallConsumption <= 0) {
      return null;
    }

    final lastEntry = entries.first;
    final previousEntry = entries[1];

    final distanceSinceLastFill = (lastEntry.quilometragem).toDouble() - (previousEntry.quilometragem).toDouble();

    final double litersFilled = (lastEntry.litros).toDouble();

    final double trajetConsumption = (litersFilled > 0 && distanceSinceLastFill >= 0) ? distanceSinceLastFill / litersFilled : 0.0;

    final double estimatedTankSize = 44.0;

    final double totalEstimatedRange = estimatedTankSize * overallConsumption;

    final double estimatedRange = totalEstimatedRange - distanceSinceLastFill;

    if (estimatedRange < _alertThresholdKm) {
      final String displayRange = unitProvider.distanceUnit == DistanceUnit.miles ? (estimatedRange * _kmToMileFactor).toStringAsFixed(0) : estimatedRange.toStringAsFixed(0);

      final String displayTrajetConsumption = trajetConsumption.toStringAsFixed(2);

      final String distanceUnitStr = context
          .tr(unitProvider.distanceUnit == DistanceUnit.miles ? TranslationKeys.unitSettingsScreenMiles : TranslationKeys.unitSettingsScreenKilometers)
          .replaceAll(RegExp(r'\(.*\)'), '')
          .trim();

      final String consumptionUnitStr = unitProvider.distanceUnit == DistanceUnit.miles ? 'mi/gal' : 'km/L';

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
                    context.tr(TranslationKeys.alertsThresholdMsg, parameters: {'0': '$displayRange $distanceUnitStr', '1': '$displayTrajetConsumption $consumptionUnitStr'}),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.orange[900], fontWeight: FontWeight.bold),
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
    final FuelEntryProvider fuelEntryProvider = context.watch<FuelEntryProvider>();
    final overallConsumption = fuelEntryProvider.calculateOverallAverageConsumption();
    final entries = fuelEntryProvider.fuelEntries;

    final fuelAlertCard = _buildFuelAlertCard(context, entries, overallConsumption);
    final unitProvider = context.watch<UnitProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(context.tr(TranslationKeys.listScreenAppBarTitle)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(RemixIcons.refresh_line),
            tooltip: context.tr(TranslationKeys.listScreenTooltipRefresh),
            onPressed: () async {
              context.read<FuelEntryProvider>().loadFuelEntries();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr(TranslationKeys.listScreenSnackbarRefreshing))));
            },
          ),
        ],
      ),
      body: fuelEntryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildOverallConsumptionCard(context, overallConsumption),
                if (fuelAlertCard != null) fuelAlertCard,
                Expanded(
                  child: fuelEntryProvider.fuelEntries.isEmpty
                      ? Center(child: Text('Ainda não Abasteceu'))
                      : ListView.builder(
                          itemCount: fuelEntryProvider.fuelEntries.length,
                          itemBuilder: (context, index) {
                            final entry = fuelEntryProvider.fuelEntries[index];
                            final FuelEntry? previousEntryMap = (index + 1 < entries.length) ? entries[index + 1] : null;

                            final FuelEntry currentEntry = FuelEntry.fromMap(entry.toMap());

                            double consumptionForThisPeriod = 0.0;

                            if (previousEntryMap != null && previousEntryMap.tanqueCheio == 1) {
                              final FuelEntry previousEntry = FuelEntry.fromMap(previousEntryMap.toMap());
                              consumptionForThisPeriod = currentEntry.calculateConsumption(previousEntry);
                            }

                            return _buildFuelEntryListItem(entry, context, consumptionForThisPeriod);
                          },
                        ),
                ),
              ],
            ),

      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_fuelentry_list',
        onPressed: () => _navigateAndSaveEntry(context),
        child: Icon(RemixIcons.gas_station_line, color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
      ),
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
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.tr(TranslationKeys.dialogDeleteButtonCancel))),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: Text(context.tr(TranslationKeys.dialogDeleteButtonDelete)),
            ),
          ],
        );
      },
    );
  }

  Dismissible _buildFuelEntryListItem(FuelEntry entry, BuildContext context, double consumptionForThisPeriod) {
    final unitProvider = context.read<UnitProvider>();
    String getFuelType(int type) {
      switch (type) {
        case 1:
          return context.tr(TranslationKeys.fuelTypeGasolineComum);
        case 2:
          return context.tr(TranslationKeys.fuelTypeGasolineAditivada);
        case 3:
          return context.tr(TranslationKeys.fuelTypeEthanolAlcool);
        case 4:
          return context.tr(TranslationKeys.fuelTypeGasolinePremium);
        default:
          return context.tr(TranslationKeys.fuelTypeOther);
      }
    }

    final currencySymbol = context.watch<CurrencyProvider>().selectedCurrency.symbol;

    // String titleText = getFuelType(entry.tipo);
    // if (entry.posto != null && entry.posto!.isNotEmpty) {
    //   titleText += ' @ ${entry.posto}';
    // }

    final String consumptionUnitStr = context
        .tr(
          unitProvider.consumptionUnit == ConsumptionUnit.kmPerLiter
              ? TranslationKeys.unitSettingsScreenKmPerLiter
              : unitProvider.consumptionUnit == ConsumptionUnit.litersPer100km
              ? TranslationKeys.unitSettingsScreenKmPerLiter
              : TranslationKeys.unitSettingsScreenMpg,
        )
        .replaceAll(RegExp(r'\(.*\)'), '')
        .trim();

    String subtitleText =
        '${context.tr(TranslationKeys.commonLabelsDate)}: ${DateFormat('dd/MM/yyyy').format(entry.dataAbastecimento)}\n${context.tr(TranslationKeys.commonLabelsOdometer)}: ${entry.quilometragem.toStringAsFixed(0)} $consumptionUnitStr\n${context.tr(TranslationKeys.commonLabelsLiters)}: ${entry.litros.toStringAsFixed(2)} L';

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
      onDismissed: (direction) {},
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: ListTile(
          leading: Icon(entry.tanqueCheio == 1 ? RemixIcons.gas_station_fill : RemixIcons.gas_station_line),
          // title: Text(titleText),
          subtitle: Text(subtitleText),
          trailing: Text(
            '$currencySymbol ${entry.totalPrice!.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
          ),
          onTap: (){
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => FuelEntryScreen(entry: entry, lastOdometer: entry.quilometragem))
            );
          },
        ),
      ),
    );
  }

  // Widget _buildFuelEntryCard(BuildContext context, Map entry, double consumption) {

  //   final bool isFullTank = entry['tanque_cheio'] == 1;
  //   String itemTipo = tipoCombustivel.keys.first;
  //   tipoCombustivel.forEach((nome, tipo) {
  //     if (tipo == entry['tipo_combustivel']) {
  //       itemTipo = nome;
  //     }
  //   });

  //   return InkWell(
  //     onTap: () => _navigateAndSaveEntry(context, entry),
  //     child: Card(
  //       margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
  //       elevation: 2,
  //       child: Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   DateFormat('dd/MM/yyyy').format(DateTime.parse(entry['data_abastecimento'])),
  //                   style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
  //                 ),
  //                 const SizedBox(width: 8),
  //                 if (isFullTank) Icon(RemixIcons.check_fill, size: 18, color: Theme.of(context).colorScheme.primary),
  //               ],
  //             ),
  //             Text(
  //               doubleToCurrency(entry['valor_total'], symbol: currencySymbol),
  //               style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
  //             ),
  //             const Divider(height: 16),
  //             _buildDetailRow(context, context.tr(TranslationKeys.commonLabelsType), itemTipo),
  //             _buildDetailRow(context, context.tr(TranslationKeys.commonLabelsOdometer), "${entry['quilometragem'].toStringAsFixed(0)} km"),
  //             _buildDetailRow(context, context.tr(TranslationKeys.commonLabelsLiters), "${entry['litros'].toStringAsFixed(2)} L"),
  //             _buildDetailRow(context, context.tr(TranslationKeys.commonLabelsPricePerLiter), doubleToCurrency(entry['valor_litro'])),
  //             if (entry['posto'] != null) _buildDetailRow(context, context.tr(TranslationKeys.commonLabelsGasStation), entry['posto']),

  //             if (consumption > 0 && !isFullTank) ...[
  //               const Divider(height: 16),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Flexible(
  //                     child: Text(context.tr(TranslationKeys.consumptionCardsConsumptionPeriod), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
  //                   ),
  //                   Text(
  //                     "${_formatConsumption(context, consumption, unitProvider.consumptionUnit)} ${consumptionUnitStr}",
  //                     style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.green[700]),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label:", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
