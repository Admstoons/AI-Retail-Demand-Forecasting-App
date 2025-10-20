import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MapeCard extends ConsumerWidget {
  final double mape;

  const MapeCard({super.key, required this.mape});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        leading: const Icon(
          Icons.bar_chart,
          color: Colors.blue,
        ),
        title: const Text('Prediction Accuracy (MAPE)'),
        subtitle: Text('${mape.toStringAsFixed(2)}%'),
      ),
    );
  }
}
