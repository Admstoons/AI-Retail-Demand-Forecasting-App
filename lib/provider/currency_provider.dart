import 'package:flutter_riverpod/flutter_riverpod.dart';

final currencySymbolProvider = StateProvider<String>(
  (ref) => '₦',
); // Default to Naira
