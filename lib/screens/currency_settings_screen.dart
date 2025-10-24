import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/models/currency_model.dart';
import 'package:fuel_tracker_app/provider/currency_provider.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

class CurrencySettingsScreen extends StatelessWidget {
  const CurrencySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentCurrency = context.watch<CurrencyProvider>().selectedCurrency;
    final currencyProvider = context.read<CurrencyProvider>();

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: const Text('Configuração de Moeda'),
        backgroundColor: AppTheme.primaryDark,
        centerTitle: false,
        elevation: 0,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Selecione a moeda utilizada para registrar seus abastecimentos:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ...availableCurrencies.map((currency){
            return RadioListTile<String>(
              value: currency.code,
              groupValue: currentCurrency.code,
              title: Text(currency.name),
              subtitle: Text('${currency.symbol} (${currency.code})'),
              onChanged: (String? value){
                if(value != null){
                  final newCurrency = availableCurrencies.firstWhere((c) => c.code == value);
                  currencyProvider.setCurrency(newCurrency);
                }
              },
              selected: currency.code == currentCurrency.code,
              activeColor: Theme.of(context).colorScheme.primary,
            );
          }).toList(),

          const Divider(height: 1, thickness: 1),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Atenção'),
            subtitle: Text('Alterar a moeda não converte registros antigos, apenas altera o símbolo para novos abastecimentos.'),
          ),
        ],
      ),
    );
  }
}