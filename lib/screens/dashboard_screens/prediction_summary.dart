import 'package:flutter/material.dart';

class PredictionSummaryCard extends StatelessWidget {
  final int totalPredictions;
  final String dateRange;
  final double mape;

  const PredictionSummaryCard({
    super.key,
    required this.totalPredictions,
    required this.dateRange,
    required this.mape,
  });

  Color _accuracyColor(double accuracy) {
    if (accuracy >= 90) return Colors.green;
    if (accuracy >= 75) return Colors.orange;
    return Colors.red;
  }

  String _accuracyLabel(double accuracy) {
    if (accuracy >= 90) return "Excellent 🎉";
    if (accuracy >= 75) return "Moderate 👍";
    return "Needs Improvement ⚠️";
  }

  @override
  Widget build(BuildContext context) {
    final safeMape = (mape.isNaN || !mape.isFinite || mape < 0) ? 0.0 : mape;
    final accuracy = (100.0 - safeMape).clamp(0.0, 100.0);
    final color = _accuracyColor(accuracy);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "📊 Prediction Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("✅ Total Predictions: $totalPredictions"),
            Text("📅 Date Range: $dateRange"),
            const SizedBox(height: 8),
            Text("📐 MAPE: ${safeMape.toStringAsFixed(2)}%"),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.circle, color: color, size: 14),
                const SizedBox(width: 6),
                Text(
                  "Accuracy: ${accuracy.toStringAsFixed(2)}% (${_accuracyLabel(accuracy)})",
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
