import 'package:intl/intl.dart';

String formatCurrency(double amount, String symbol) {
  final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
  return formatter.format(amount);
}
