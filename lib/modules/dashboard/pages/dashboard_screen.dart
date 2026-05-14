import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class DashboardPage extends GetView<HomeController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    controller.gastosPorMes;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(theme, colorScheme),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Gastos Mensais (R\$)", colorScheme),
                  const SizedBox(height: 16),
                  _buildMainChart(theme, colorScheme),
                  const SizedBox(height: 28),
                  _buildSectionTitle("Estatísticas Rápidas", colorScheme),
                  const SizedBox(height: 16),
                  _buildQuickStats(theme, colorScheme),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15, top: 8, bottom: 8),
          child: Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedVehicleID.value,
                  hint: Text(
                    'Todos Veículos',
                    style: GoogleFonts.montserrat(fontSize: 12),
                  ),
                  onChanged: (String? newValue) =>
                      controller.onVehicleChanged(newValue),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text('Todos os Carros'),
                    ),
                    ...controller.veiculosMap.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(
                          entry.value['nickname'] ?? "Veículo",
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsetsDirectional.only(start: 16, bottom: 16),
        title: Text(
          'DASHBOARD'.toUpperCase(),
          style: GoogleFonts.montserrat(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMainChart(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(12, 24, 20, 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.withOpacity(0.08), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        final dados = controller.ultimosSeisMeses;

        return LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: _buildChartTitles(),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: dados
                    .asMap()
                    .entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value))
                    .toList(),
                isCurved: true,
                color: colorScheme.primary,
                barWidth: 4,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: colorScheme.primary.withOpacity(0.12),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  FlTitlesData _buildChartTitles() {
    return FlTitlesData(
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            const months = [
              'Jan',
              'Fev',
              'Mar',
              'Abr',
              'Mai',
              'Jun',
              'Jul',
              'Ago',
              'Set',
              'Out',
              'Nov',
              'Dez',
            ];
            DateTime date = DateTime.now().subtract(
              Duration(days: (5 - value.toInt()) * 30),
            );
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                months[date.month - 1],
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickStats(ThemeData theme, ColorScheme colorScheme) {
    return Obx(
      () => GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
        children: [
          _statCard(
            "Total Gasto",
            controller.settings.formatarCurrency(controller.totalGastoFiltrado),
            RemixIcons.money_dollar_circle_line,
            Colors.green,
          ),
          _statCard(
            "KM Rodados",
            controller.settings.formatarDistancia(controller.kmRodadoTotal),
            RemixIcons.roadster_line,
            Colors.orange,
          ),
          _statCard(
            "Registros",
            "${controller.filteredFuelEntries.length}",
            RemixIcons.gas_station_line,
            Colors.blue,
          ),
          _statCard(
            "Média KM/L",
            controller.settings.formatarConsumo(controller.consumoMediaGeral),
            RemixIcons.pulse_line,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.firaCode(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
