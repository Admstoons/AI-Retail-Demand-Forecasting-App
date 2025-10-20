import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages the hover state of the button
final isHoveredProvider = StateProvider<bool>((ref) => false);

/// Manages the loading state when the button is clicked
final isLoadingProvider = StateProvider<bool>((ref) => false);
