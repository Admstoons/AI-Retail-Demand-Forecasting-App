import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retail_demand/app_colors.dart';
import 'package:retail_demand/provider/currency_provider.dart';
import 'package:retail_demand/provider/prediction_notifier.dart';
import 'package:share_plus/share_plus.dart';

class PredictionAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Function(List<Map<String, dynamic>>) generateCsv;

  const PredictionAppBar({super.key, required this.generateCsv});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predictionState = ref.watch(predictionNotifierProvider);
    ref.watch(currencySymbolProvider);

    return AppBar(
      title: const Text('📈 Prediction Result'),
      centerTitle: true,
      backgroundColor: AppColors.appBarColor,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: () {
            ref.invalidate(predictionNotifierProvider);
          },
        ),
        IconButton(
          icon: const Icon(Icons.download),
          tooltip: 'Export as CSV',
          onPressed:
              predictionState.displayedData.isEmpty
                  ? null
                  : () async {
                      final csv = generateCsv(predictionState.displayedData);
                      await Share.share(csv, subject: 'Forecast Table');
                    },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.attach_money),
          onSelected: (symbol) {
            ref.read(currencySymbolProvider.notifier).state = symbol;
          },
          itemBuilder:
              (context) => const [
                    PopupMenuItem(value: '₦', child: Text('Naira (₦)')),
                    PopupMenuItem(value: '\$', child: Text('USD (\$)')),
                    PopupMenuItem(value: '€', child: Text('Euro (€)')),
                    PopupMenuItem(value: '£', child: Text('Pound (£)')),
                  ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
