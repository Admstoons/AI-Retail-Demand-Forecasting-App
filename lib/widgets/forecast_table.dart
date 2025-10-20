import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:retail_demand/provider/currency_provider.dart';
import 'package:retail_demand/provider/loading_provider.dart';

class ForecastTable extends ConsumerWidget {
  final List<Map<String, dynamic>> tableData;
  final String Function(double, String) formatCurrency;
  final DateTime? Function(String?) parseFlexibleDate;
  final int? peakActualIndex;
  final int? peakPredictedIndex;

  const ForecastTable({
    super.key,
    required this.tableData,
    required this.formatCurrency,
    required this.parseFlexibleDate,
    this.peakActualIndex,
    this.peakPredictedIndex,
  });

  // Date display
  String _displayDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    final dt =
        parseFlexibleDate(raw) ?? DateTime.tryParse(raw.split('T').first);
    return dt != null ? DateFormat('yyyy-MM-dd').format(dt) : raw;
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCurrency = ref.watch(currencySymbolProvider);
    final isLoadingMore = ref.watch(isLoadingMoreProvider);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📋 Detailed Forecast Table',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // ✅ Don’t re-sort here. Use processed order.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 28,
                headingRowColor: MaterialStateProperty.resolveWith(
                  (_) => Colors.grey.shade200,
                ),
                border: TableBorder.all(
                  color: Colors.grey.shade300,
                  width: 0.5,
                ),
                columns: const [
                  DataColumn(label: Text('📅 Date')),
                  DataColumn(label: Text('Actual')),
                  DataColumn(label: Text('Predicted')),
                ],
                rows: List.generate(tableData.length, (index) {
                  final e = tableData[index];
                  final dateText = _displayDate(e['date']?.toString());

                  final actualDouble = _toDouble(e['actual']);
                  final predictedDouble = _toDouble(
                    e['predicted'] ?? e['predicted_value'] ?? e['prediction'],
                  );

                  final isPeakActual = index == peakActualIndex;
                  final isPeakPredicted = index == peakPredictedIndex;

                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>((_) {
                      if (isPeakActual) return Colors.red.withOpacity(0.15);
                      if (isPeakPredicted)
                        return Colors.orange.withOpacity(0.15);
                      return null;
                    }),
                    cells: [
                      DataCell(Text(dateText)),
                      DataCell(
                        Text(
                          actualDouble != null
                              ? formatCurrency(actualDouble, selectedCurrency)
                              : 'N/A',
                          style: TextStyle(
                            fontWeight: isPeakActual ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          predictedDouble != null
                              ? formatCurrency(
                                predictedDouble,
                                selectedCurrency,
                              )
                              : 'N/A',
                          style: TextStyle(
                            fontWeight:
                                isPeakPredicted ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),

            if (isLoadingMore)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Opacity(
                    opacity: 0.5,
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
