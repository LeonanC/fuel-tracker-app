import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/models/currency_model.dart';

class CurrencyProvider  extends ChangeNotifier {
  Currency _selectedCurrency = availableCurrencies.first;
  Currency get selectedCurrency => _selectedCurrency;

  void setCurrency(Currency newCurrency){
    if(_selectedCurrency.code != newCurrency.code){
      _selectedCurrency = newCurrency;
      notifyListeners();
    }
  }
}