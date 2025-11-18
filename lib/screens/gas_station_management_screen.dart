import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/models/gas_station_model.dart';
import 'package:fuel_tracker_app/provider/currency_provider.dart';
import 'package:fuel_tracker_app/provider/gas_station_provider.dart';
import 'package:fuel_tracker_app/screens/gas_station_entry_screen.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

class GasStationManagementScreen extends StatefulWidget {
  const GasStationManagementScreen({super.key});

  @override
  State<GasStationManagementScreen> createState() => _GasStationManagementScreenState();
}

class _GasStationManagementScreenState extends State<GasStationManagementScreen> {
  void _navigateAndRefresh(BuildContext context, [GasStationModel? station]) async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => GasStationEntryScreen(station: station)));
    if (result == true) {
      Provider.of<GasStationProvider>(context, listen: false).loadGasStation();
    }
  }

  void _confirmDelete(BuildContext context, GasStationProvider provider, GasStationModel station) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.tr(TranslationKeys.gasStationButtonDelete)),
          content: Text(context.tr(TranslationKeys.gasStationButtonDeleteConfirm)),
          actions: [
            TextButton(
              child: Text(context.tr(TranslationKeys.gasStationButtonCancel)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryFuelColor,
                foregroundColor: AppTheme.primaryFuelAccent,
              ),
              child: Text(context.tr(TranslationKeys.gasStationButtonDelete)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                try {
                  await provider.deleteGasStation(station.id!);

                  if (mounted) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(content: Text(context.tr(TranslationKeys.gasStationDeleteSuccess))),
                    // );
                  }
                } catch (e) {
                  if (mounted) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(content: Text(context.tr(TranslationKeys.gasStationDeleteError))),
                    // );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){ 
      context.read<GasStationProvider>().loadGasStation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final GasStationProvider gasProvider = context.watch<GasStationProvider>();
    final currencySymbol = context.watch<CurrencyProvider>().currencySymbol;
    final allGas = gasProvider.postos;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
      appBar: AppBar(
        title: Text(context.tr(TranslationKeys.gasStationScreenTitle)),
        backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
        elevation: theme.appBarTheme.elevation,
        centerTitle: theme.appBarTheme.centerTitle,
      ),
      body: Consumer<GasStationProvider>(
        builder: (context, provider, child) {
          if(provider.isLoading){
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.postos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(RemixIcons.gas_station_line, size: 64, color: AppTheme.textGrey),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum Posto cadastrado.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium!.copyWith(color: AppTheme.textGrey),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: provider.postos.length,
            itemBuilder: (context, index) {
              final gasStation = provider.postos[index];
              return PostoCard(
                key: ValueKey(gasStation.id),
                gasStation: gasStation,
                onEdit: () => _navigateAndRefresh(context, gasStation),
                onDelete: () => _confirmDelete(context, provider, gasStation),
                currencySymbol: currencySymbol,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'gas_station_tag',
        onPressed: () => _navigateAndRefresh(context),
        backgroundColor: AppTheme.primaryFuelColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class PostoCard extends StatelessWidget {
  final GasStationModel gasStation;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String currencySymbol;
  const PostoCard({
    super.key,
    required this.gasStation,
    required this.onEdit,
    required this.onDelete,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    String formatPrice(double price) {
      return '$currencySymbol ${price.toStringAsFixed(2).replaceAll('.', ',')}';
    }

    return Card(
      color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(RemixIcons.gas_station_fill, color: AppTheme.primaryFuelColor, size: 32),
        title: Text(gasStation.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bandeira: ${gasStation.brand}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(RemixIcons.gas_station_fill, size: 16, color: AppTheme.primaryFuelColor),
                const SizedBox(width: 4),
                Flexible(child: Text('G: ${formatPrice(gasStation.priceGasoline)}')),
                const SizedBox(width: 12),
                Icon(RemixIcons.flask_fill, size: 16, color: AppTheme.primaryFuelColor),
                const SizedBox(width: 4),
                Flexible(child: Text('E: ${formatPrice(gasStation.priceEthanol)}')),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (String result) {
            if (result == 'edit') {
              onEdit();
            } else if (result == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(value: 'edit', child: Text('Editar')),
            const PopupMenuItem<String>(value: 'delete', child: Text('Excluir')),
          ],
        ),
      ),
    );
  }
}
