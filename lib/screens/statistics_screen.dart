import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/provider/fuel_entry_provider.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<BarChartGroupData> _monthlyConsumptionData = [];
  List<FlSpot> _monthlyAvgPriceData = [];
  List<String> _monthKeys = [];

  double _totalDistance = 0.0;
  double _totalVolume = 0.0;
  double _totalCost = 0.0;
  double _averageConsumption = 0.0;
  double _averagePrice = 0.0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final fuelProvider = Provider.of<FuelEntryProvider>(context, listen: false);
    final List<FuelEntry> entries = await fuelProvider.getAllEntriesForExport();

    _calculateSummaryMetrics(entries);

    _monthlyConsumptionData = _generateMonthlyConsumptionData(entries);
    _monthlyAvgPriceData = _generateMonthlyAvgPriceData(entries);

    setState(() {});
  }

  void _calculateSummaryMetrics(List<FuelEntry> entries) {
    if (entries.isEmpty) {
      _totalDistance = 0;
      _totalVolume = 0;
      _totalCost = 0;
      _averageConsumption = 0;
      _averagePrice = 0;
      return;
    }

    _totalVolume = entries.fold(0.0, (sum, item) => sum + item.litros);
    _totalCost = entries.fold(0.0, (sum, item) => sum + (item.totalPrice ?? 0.0));

    final fullTankEntries = entries.where((e) => e.tanqueCheio).toList();

    if (fullTankEntries.length >= 2) {
      final double initialOdometer = fullTankEntries.first.quilometragem;
      final double finalOdometer = fullTankEntries.last.quilometragem;

      _totalDistance = finalOdometer - initialOdometer;
    } else {
      _totalDistance = 0;
    }

    _averageConsumption = _totalVolume > 0 ? _totalDistance / _totalVolume : 0.0;
    _averagePrice = _totalVolume > 0 ? _totalCost / _totalVolume : 0.0;
  }

  List<BarChartGroupData> _generateMonthlyConsumptionData(List<FuelEntry> entries) {
    if (entries.isEmpty) return [];

    final Map<String, List<FuelEntry>> entriesByMonth = {};
    for (var entry in entries) {
      final monthKey = DateFormat('yyyy-MM').format(entry.dataAbastecimento);
      entriesByMonth.putIfAbsent(monthKey, () => []).add(entry);
    }

    final sortedMonthKeys = entriesByMonth.keys.toList()..sort();
    _monthKeys = sortedMonthKeys;
    List<BarChartGroupData> data = [];

    for (int i = 0; i < sortedMonthKeys.length; i++) {
      final monthEntries = entriesByMonth[sortedMonthKeys[i]]!;

      double totalGasolinaComum = 0;
      double totalGasolinaAditivada = 0;
      double totalGasolinaPremium = 0;
      double totalEthanol = 0;
      double totalOutra = 0;

      for (var entry in monthEntries) {
        if (entry.tipo.contains('Gasolina Comum')) {
          totalGasolinaComum += entry.litros;
        } else if (entry.tipo.contains('Etanol (Álcool)')) {
          totalEthanol += entry.litros;
        } else if (entry.tipo.contains('Gasolina Aditivada')) {
          totalGasolinaAditivada += entry.litros;
        } else if (entry.tipo.contains('Gasolina Premium')) {
          totalGasolinaPremium += entry.litros;
        } else if (entry.tipo.contains('Outro')) {
          totalOutra += entry.litros;
        }
      }

      data.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: totalEthanol,
              color: Colors.green.shade500,
              width: 8,
              borderRadius: BorderRadius.circular(2),
            ),
            BarChartRodData(
              toY: totalGasolinaComum,
              color: Colors.amber.shade600,
              width: 8,
              borderRadius: BorderRadius.circular(2),
            ),

            BarChartRodData(
              toY: totalGasolinaAditivada,
              color: Colors.orange.shade700,
              width: 8,
              borderRadius: BorderRadius.circular(2),
            ),
            BarChartRodData(
              toY: totalGasolinaPremium,
              color: Colors.red.shade600,
              width: 8,
              borderRadius: BorderRadius.circular(2),
            ),
            BarChartRodData(
              toY: totalOutra,
              color: Colors.grey.shade500,
              width: 8,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      );
    }

    return data;
  }

  List<FlSpot> _generateMonthlyAvgPriceData(List<FuelEntry> entries) {
    if (entries.isEmpty) return [];

    final Map<String, List<FuelEntry>> entriesByMonth = {};
    for (var entry in entries) {
      final monthKey = DateFormat('yyyy-MM').format(entry.dataAbastecimento);
      entriesByMonth.putIfAbsent(monthKey, () => []).add(entry);
    }

    final sortedMonthKeys = entriesByMonth.keys.toList()..sort();
    List<FlSpot> data = [];

    for (int i = 0; i < sortedMonthKeys.length; i++) {
      final monthEntries = entriesByMonth[sortedMonthKeys[i]]!;
      double totalCost = 0;
      double totalVolume = 0;

      for (var entry in monthEntries) {
        totalCost += (entry.totalPrice ?? 0.0);
        totalVolume += entry.litros;
      }

      final avgPrice = totalVolume > 0 ? totalCost / totalVolume : 0.0;
      data.add(FlSpot(i.toDouble(), avgPrice));
    }

    return data;
  }

  BarChartGroupData _makeBarChartGroupData(int x, double y1, double y2, String label) {
    return BarChartGroupData(x: x, barRods: []);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
      appBar: AppBar(
        title: Text(context.tr(TranslationKeys.toolsScreenStatisticsTitle)),
        backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
        elevation: theme.appBarTheme.elevation,
        centerTitle: theme.appBarTheme.centerTitle,
      ),
      body: _monthlyConsumptionData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSummaryCard(context, currencyFormatter),
                const SizedBox(height: 16),
                _buildChartCard(
                  context,
                  title: context.tr(TranslationKeys.toolsScreenConsumptionTitle),
                  chart: AspectRatio(
                    aspectRatio: 1.7,
                    child: BarChart(
                      BarChartData(
                        barGroups: _monthlyConsumptionData,
                        titlesData: FlTitlesData(
                          show: true,
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                String label = 'Mês';

                                if (index >= 0 && index < _monthKeys.length) {
                                  final monthKey = _monthKeys[index];
                                  final date = DateFormat('yyyy-MM').parse(monthKey);

                                  label = DateFormat('MMM', 'pt_BR').format(DateTime.parse(date.toIso8601String()));
                                }

                                return SideTitleWidget(
                                  meta: meta,
                                  child: Text(label, style: const TextStyle(fontSize: 10)),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: true, drawVerticalLine: false),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final index = group.x.toInt();
                              String month = 'Mês';

                              if(index >= 0 && index < _monthKeys.length){
                                final monthKey = _monthKeys[index];
                                final date = DateFormat('yyyy-MM').parse(monthKey);
                                month = DateFormat('MMMM', 'pt_BR').format(DateTime.parse(date.toIso8601String()));
                              }

                              final String type = rodIndex == 0
                                  ? 'Etanol (Álcool)'
                                  : rodIndex == 1
                                  ? 'Gasolina Comum'
                                  : rodIndex == 2
                                  ? 'Gasolina Aditivada'
                                  : rodIndex == 3
                                  ? 'Gasolina Premium'
                                  : 'Outro';

                              return BarTooltipItem(
                                '$month\n$type: ${rod.toY.toStringAsFixed(1)}L',
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildChartCard(
                  context,
                  title: context.tr(TranslationKeys.toolsScreenAvgPriceTitle),
                  chart: AspectRatio(
                    aspectRatio: 1.7,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: _monthlyAvgPriceData,
                            isCurved: true,
                            color: AppTheme.primaryFuelColor,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: true, color: AppTheme.primaryFuelColor),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          show: true,
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  meta: meta,
                                  child: Text(
                                    currencyFormatter.format(value),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1.0,
                              getTitlesWidget: (value, meta) {
                                if(value % 1 != 0){
                                  return Container();
                                }
                                
                                final index = value.toInt();
                                String label = 'Mês';

                                if(index >= 0 && index < _monthKeys.length){
                                  final monthKey = _monthKeys[index];
                                  final date = DateFormat('yyyy-MM').parse(monthKey);
                                  label = DateFormat('MMM', 'pt_BR').format(DateTime.parse(date.toIso8601String()));
                                }

                                return SideTitleWidget(
                                  meta: meta,
                                  child: Text(
                                    label,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((LineBarSpot touchedSpot) {
                                String month = [
                                  'Jan',
                                  'Fev',
                                  'Mar',
                                  'Abr',
                                  'Mai',
                                  'Jun',
                                ][touchedSpot.x.toInt()];
                                return LineTooltipItem(
                                  '$month: ${currencyFormatter.format(touchedSpot.y)}/L',
                                  const TextStyle(color: Colors.white),
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildChartCard(BuildContext context, {required String title, required Widget chart}) {
    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.cardDark
          : AppTheme.cardLight,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Divider(height: 24, thickness: 1),
            chart,
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, NumberFormat currencyFormatter) {
    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.cardDark
          : AppTheme.cardLight,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr(TranslationKeys.toolsScreenSummaryTitle),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Divider(height: 24, thickness: 1),
            _buildMetricRow(
              context,
              context.tr(TranslationKeys.toolsScreenTotalDistancia),
              '${_totalDistance.toStringAsFixed(0)} km',
            ),
            _buildMetricRow(
              context,
              context.tr(TranslationKeys.toolsScreenTotalVolume),
              '${_totalVolume.toStringAsFixed(2)} L',
            ),
            _buildMetricRow(
              context,
              context.tr(TranslationKeys.toolsScreenTotalCost),
              currencyFormatter.format(_totalCost),
            ),
            _buildMetricRow(
              context,
              context.tr(TranslationKeys.toolsScreenAverageConsumption),
              '${_averageConsumption.toStringAsFixed(2)} km/L',
            ),
            _buildMetricRow(
              context,
              context.tr(TranslationKeys.toolsScreenAveragePricePerLiter),
              currencyFormatter.format(_averagePrice),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
