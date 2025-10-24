// import 'package:flutter/material.dart';
// import 'package:flutter_masked_text2/flutter_masked_text2.dart';
// import 'package:fuel_tracker_app/models/fuelentry_model.dart';
// import 'package:fuel_tracker_app/provider/fuel_entry_provider.dart';
// import 'package:fuel_tracker_app/services/application.dart';
// import 'package:fuel_tracker_app/theme/app_theme.dart';
// import 'package:fuel_tracker_app/utils/app_localizations.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:remixicon/remixicon.dart';

// class FuelEditEntryScreen extends StatefulWidget {
//   final Map<String, dynamic> entryToEdit;
//   final double? lastOdometer;
//   const FuelEditEntryScreen({super.key, required this.entryToEdit, required this.lastOdometer});

//   @override
//   State<FuelEditEntryScreen> createState() => _FuelEditEntryScreenState();
// }

// class _FuelEditEntryScreenState extends State<FuelEditEntryScreen> {
//   final _formKey = GlobalKey<FormState>();

//   DateTime _selectedDate = DateTime.now();
//   final TextEditingController _odometerController = TextEditingController();
//   final MoneyMaskedTextController _litersController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');

//   final MoneyMaskedTextController _pricePerLiterController = MoneyMaskedTextController(leftSymbol: 'R\$ ', decimalSeparator: ',', thousandSeparator: '.');
//   final MoneyMaskedTextController _totalPriceController = MoneyMaskedTextController(leftSymbol: 'R\$ ', decimalSeparator: ',', thousandSeparator: '.');

//   final TextEditingController _postoController = TextEditingController();
//   bool _tanqueCheio = true;
//   String? _selectedFuelType;
//   String? _comprovantePath;
//   final ImagePicker _picker = ImagePicker();

//   String _getFuelTypeName(int id) {
//     return tipoCombustivel.entries.firstWhere((entry) => entry.value == id, orElse: () => const MapEntry('Gasolina Comum', 1)).key;
//   }

//   @override
//   void initState() {
//     super.initState();
//     final item = widget.entryToEdit;
//     _selectedDate = DateTime.parse(item['data_abastecimento']);
//     _odometerController.text = item['quilometragem'].toStringAsFixed(0);
//     _litersController.updateValue(item['litros']);
//     _pricePerLiterController.updateValue(item['valor_litro']);
//     _totalPriceController.updateValue(item['valor_total']);
//     _postoController.text = item['posto'] ?? '';
//     _tanqueCheio = item['tanque_cheio'] == 1;
//     _selectedFuelType = _getFuelTypeName(item['tipo_combustivel']);
//     _comprovantePath = item['comprovante_path'] ?? '';

//     _selectedFuelType = tipoCombustivel.keys.first;
//   }

//   @override
//   void dispose() {
//     _odometerController.dispose();
//     _litersController.dispose();
//     _pricePerLiterController.dispose();
//     _totalPriceController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2023, 1), lastDate: DateTime(2030, 12));
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   double? _getOdometerValue() => double.tryParse(_odometerController.text.replaceAll(',', '.'));
//   double? _getLitersValue() => _litersController.numberValue;
//   double? _getPricePerLiterValue() => _pricePerLiterController.numberValue;
//   double? _getTotalPriceValue() => _totalPriceController.numberValue;

//   void _calculatePrice() {
//     final double? liters = _getLitersValue();
//     final double? pricePerLiter = _getPricePerLiterValue();
//     final double? totalPriceEntered = _getTotalPriceValue();

//     if (liters != null && pricePerLiter != null) {
//       final double calculatedTotal = liters * pricePerLiter;
//       _totalPriceController.updateValue(calculatedTotal);
//     } else if (liters != null && totalPriceEntered != null && liters > 0) {
//       final calculatedPricePerLiter = totalPriceEntered / liters;
//       _pricePerLiterController.updateValue(calculatedPricePerLiter);
//     } else if (pricePerLiter != null && totalPriceEntered != null && pricePerLiter > 0) {
//       final calculatedLiters = totalPriceEntered / pricePerLiter;
//       _litersController.updateValue(calculatedLiters);
//     }
//   }

//   bool _validatePriceConsistency(BuildContext context) {
//     final double? liters = currencyToDouble(_litersController.text);
//     final double? pricePerLiter = currencyToDouble(_pricePerLiterController.text);
//     final double? totalPriceEntered = currencyToDouble(_totalPriceController.text);

//     if (liters != null && pricePerLiter != null && totalPriceEntered != null) {
//       final double calculatedValue = liters * pricePerLiter;
//       const double epsilon = 0.01;

//       if ((calculatedValue - totalPriceEntered).abs() > epsilon) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(context.tr(TranslationKeys.validationPriceInconsistencyAlert, parameters: {'0': totalPriceEntered.toStringAsFixed(2), '1': calculatedValue.toStringAsFixed(2)})),
//             backgroundColor: Colors.orange,
//             duration: const Duration(seconds: 5),
//           ),
//         );
//         return false;
//       }
//     }
//     return true;
//   }

//   Future<void> _pickComprovante() async {
//     final source = await showDialog<ImageSource>(
//       context: context,
//       builder: (BuildContext context) {
//         return SimpleDialog(
//           title: Text(context.tr(TranslationKeys.entryScreenDialogReceiptTitle)),
//           children: [
//             SimpleDialogOption(onPressed: () => Navigator.pop(context, ImageSource.camera), child: Text(context.tr(TranslationKeys.entryScreenDialogReceiptOptionCamera))),
//             SimpleDialogOption(onPressed: () => Navigator.pop(context, ImageSource.gallery), child: Text(context.tr(TranslationKeys.entryScreenDialogReceiptOptionGallery))),
//           ],
//         );
//       },
//     );

//     if (source != null) {
//       try {
//         final XFile? pickedFile = await _picker.pickImage(source: source);
//         if (pickedFile != null) {
//           setState(() {
//             _comprovantePath = pickedFile.path;
//           });
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr(TranslationKeys.entryScreenSnackbarReceiptSelectedPrefix, parameters: {'name': pickedFile.name}))));
//           }
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr(TranslationKeys.entryScreenSnackbarReceiptSelectedPrefix, parameters: {'error': e.toString()}))));
//         }
//       }
//     }
//   }

//   void _saveEntry() {
//     if (_formKey.currentState!.validate()) {
//       if (_validatePriceConsistency(context)) {
//         final int fuelTypeId = tipoCombustivel[_selectedFuelType] ?? 0;
//         final savedEntry = FuelEntry(
//           id: widget.entryToEdit['id'],
//           date_abastecimento: _selectedDate,
//           quilometragem: _getOdometerValue()!,
//           litros: _getLitersValue()!,
//           pricePerLiter: _getPricePerLiterValue()!,
//           totalPrice: _getTotalPriceValue()!,
//           comprovantePath: _comprovantePath,
//           tipoCombustivel: fuelTypeId,
//           posto: _postoController.text.trim().isNotEmpty ? _postoController.text : null,
//           tanqueCheio: _tanqueCheio ? 1 : 0,
//         );
//         Navigator.of(context).pop(savedEntry);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentEntryOdometer = (widget.entryToEdit['quilometragem'] as num).toDouble();
//     final previousOdometer = widget.lastOdometer;
//     final isLastOdometerDisplayable = previousOdometer != null && previousOdometer != currentEntryOdometer;
//     final displayOdometer = isLastOdometerDisplayable ? previousOdometer : null;

//     return Scaffold(
//       appBar: AppBar(title: Text(context.tr(TranslationKeys.entryScreenAppBarTitle)), centerTitle: false, elevation: 0),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 leading: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
//                 title: Text(context.tr(TranslationKeys.entryScreenLabelDate), style: Theme.of(context).textTheme.bodyMedium),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
//                     const SizedBox(width: 8),
//                     Icon(Icons.edit_calendar, color: Theme.of(context).colorScheme.secondary),
//                   ],
//                 ),
//                 onTap: () => _selectDate(context),
//               ),
//               const SizedBox(height: 20),
//               if (displayOdometer != null)
//                 Container(
//                   padding: const EdgeInsets.all(12.0),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8.0),
//                     border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.5), width: 1),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.info_outline, color: Theme.of(context).colorScheme.secondary, size: 20),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Text(
//                           context.tr(TranslationKeys.entryScreenInfoLastOdometerPrefix, parameters: {'lastOdo': _odometerController.text}),
//                           style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _odometerController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(labelText: context.tr(TranslationKeys.entryScreenLabelOdometer)),
//                 validator: (value) {
//                   final double? odometer = _getOdometerValue();
//                   if (odometer == null || odometer <= 0) {
//                     return context.tr(TranslationKeys.validationRequiredOdometer);
//                   }
//                   if (displayOdometer != null && odometer < displayOdometer) {
//                     return context.tr(TranslationKeys.validationOdometerMustBeGreater, parameters: {'name': displayOdometer.toStringAsFixed(0)});
//                   }
//                   return null;
//                 },
//                 onChanged: (_) => _calculatePrice(),
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 decoration: InputDecoration(labelText: context.tr(TranslationKeys.entryScreenLabelFuelType), border: OutlineInputBorder()),
//                 value: _selectedFuelType,
//                 items: tipoCombustivel.keys.map((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value, style: TextStyle(color: AppTheme.textGrey)),
//                   );
//                 }).toList(),
//                 onChanged: (String? newValue) {
//                   if (newValue != null) {
//                     setState(() {
//                       _selectedFuelType = newValue;
//                     });
//                   }
//                 },
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return context.tr(TranslationKeys.validationRequiredFuelType);
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _litersController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(labelText: context.tr(TranslationKeys.entryScreenLabelLiters)),
//                 validator: (value) {
//                   if (_getLitersValue() == null || _getLitersValue()! <= 0) {
//                     return context.tr(TranslationKeys.validationRequiredValidLiters);
//                   }
//                   return null;
//                 },
//                 onChanged: (_) => _calculatePrice(),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _pricePerLiterController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(labelText: context.tr(TranslationKeys.entryScreenLabelPricePerLiter)),
//                 validator: (value) {
//                   if (_getPricePerLiterValue() == null || _getPricePerLiterValue()! <= 0) {
//                     return context.tr(TranslationKeys.validationRequiredValidPricePerLiter);
//                   }
//                   return null;
//                 },
//                 onChanged: (_) => _calculatePrice(),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _totalPriceController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(labelText: context.tr(TranslationKeys.entryScreenLabelTotalPrice)),
//                 validator: (value) {
//                   if (_getTotalPriceValue() == null || _getTotalPriceValue()! <= 0) {
//                     return context.tr(TranslationKeys.validationRequiredValidTotalPrice);
//                   }
//                   return null;
//                 },
//                 onChanged: (_) => _calculatePrice(),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _postoController,
//                 keyboardType: TextInputType.text,
//                 decoration: InputDecoration(labelText: context.tr(TranslationKeys.entryScreenLabelGasStationOptional)),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(_tanqueCheio ? RemixIcons.gas_station_fill : RemixIcons.gas_station_line, color: _tanqueCheio ? Theme.of(context).colorScheme.primary : AppTheme.textGrey, size: 40),
//                       const SizedBox(width: 16),
//                       Text(
//                         context.tr(TranslationKeys.entryScreenLabelFullTank),
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _tanqueCheio ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyLarge?.color),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(width: 12),
//                   Switch(
//                     value: _tanqueCheio,
//                     onChanged: (bool? newValue) {
//                       setState(() {
//                         _tanqueCheio = newValue ?? false;
//                       });
//                     },
//                     activeColor: Theme.of(context).colorScheme.primary,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               ListTile(
//                 title: Text(
//                   _comprovantePath == null ? context.tr(TranslationKeys.entryScreenReceiptAddOptional) : context.tr(TranslationKeys.entryScreenReceiptSelected),
//                   style: TextStyle(color: _comprovantePath == null ? Colors.grey[700] : Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
//                 ),
//                 subtitle: _comprovantePath != null ? Text(context.tr(TranslationKeys.entryScreenReceiptPathPrefix, parameters: {'name': _comprovantePath!.split('/').last})) : null,
//                 leading: Icon(_comprovantePath == null ? Icons.camera_alt_outlined : Icons.check_circle, color: _comprovantePath == null ? Colors.grey : Theme.of(context).colorScheme.primary),
//                 trailing: _comprovantePath != null
//                     ? IconButton(
//                         icon: const Icon(Icons.close),
//                         onPressed: () {
//                           setState(() {
//                             _comprovantePath = null;
//                           });
//                         },
//                       )
//                     : null,
//                 onTap: _pickComprovante,
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(onPressed: _saveEntry, child: Text(context.tr(TranslationKeys.entryScreenButtonSave))),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
