import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:retail_demand/provider/prediction_notifier.dart';
import 'package:retail_demand/provider/currency_provider.dart';
import 'package:retail_demand/provider/loading_provider.dart';
import 'package:retail_demand/widgets/prediction_app_bar.dart';
import 'package:retail_demand/widgets/mape_card.dart';
import 'package:retail_demand/widgets/prediction_chart.dart';
import 'package:retail_demand/widgets/forecast_table.dart';
import 'package:retail_demand/models/prediction_state_data.dart';

class PricePredictorScreen extends ConsumerStatefulWidget {
  const PricePredictorScreen({super.key});

  @override
  ConsumerState<PricePredictorScreen> createState() =>
      _PricePredictorScreenState();
}

class _PricePredictorScreenState extends ConsumerState<PricePredictorScreen> {
  final ScrollController _scrollController = ScrollController();
  NumberFormat? _currencyFormatter;

  String formatCurrency(double value, String symbol) {
    _currencyFormatter ??= NumberFormat.currency(
      symbol: symbol.isEmpty ? '\$' : symbol,
      decimalDigits: 2,
      locale: 'en_US',
    );
    return _currencyFormatter!.format(value);
  }

  String generateCsv(List<Map<String, dynamic>> tableData) {
    final buffer = StringBuffer();
    buffer.writeln('Date,Actual,Predicted');
    for (final row in tableData) {
      buffer.writeln(
        '${row['date']},${row['actual'] ?? 'N/A'},${row['predicted'] ?? 'N/A'}',
      );
    }
    return buffer.toString();
  }

  DateTime? parseFlexibleDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    String normalized = raw.replaceAll('/', '-');

    final formats = [
      DateFormat('d-M-yyyy'),
      DateFormat('dd-M-yyyy'),
      DateFormat('d-MM-yyyy'),
      DateFormat('dd-MM-yyyy'),
      DateFormat('yyyy-MM-dd'),
    ];

    for (var format in formats) {
      try {
        return format.parseStrict(normalized);
      } catch (_) {}
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() async {
      final predictionState = ref.read(predictionNotifierProvider);

      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !ref.read(isLoadingMoreProvider) &&
          predictionState.currentOffset < predictionState.totalRows &&
          predictionState.status == PredictionState.success) {
        ref.read(isLoadingMoreProvider.notifier).state = true;
        await ref.read(predictionNotifierProvider.notifier).fetchNextPage();
        ref.read(isLoadingMoreProvider.notifier).state = false;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> processData(
    List<Map<String, dynamic>> allData,
  ) async {
    return await compute(_processData, allData);
  }

  static Map<String, dynamic> _processData(List<Map<String, dynamic>> allData) {
    final aggregatedData = <String, Map<String, double>>{};

    for (var row in allData) {
      final date = row['date'];
      if (date == null) continue;

      if (!aggregatedData.containsKey(date)) {
        aggregatedData[date] = {
          'actual': row['actual'] ?? 0,
          'predicted': row['predicted'] ?? 0,
          'count': 1,
        };
      } else {
        aggregatedData[date]!['actual'] =
            (aggregatedData[date]!['actual']! + (row['actual'] ?? 0));
        aggregatedData[date]!['predicted'] =
            (aggregatedData[date]!['predicted']! + (row['predicted'] ?? 0));
        aggregatedData[date]!['count'] = (aggregatedData[date]!['count']! + 1);
      }
    }

    final List<FlSpot> actualSpots = [];
    final List<FlSpot> predictedSpots = [];
    final List<String> xLabels = [];
    final List<int> years = [];
    final List<DateTime> dates = []; // ✅ FIX: store actual parsed dates

    int i = 0;
    double peakActual = 0, peakPredicted = 0;
    int peakActualIndex = 0, peakPredictedIndex = 0;

    aggregatedData.forEach((date, values) {
      final count = values['count']!;
      final actual = values['actual']! / count;
      final predicted = values['predicted']! / count;

      actualSpots.add(FlSpot(i.toDouble(), actual));
      predictedSpots.add(FlSpot(i.toDouble(), predicted));
      xLabels.add(date);

      try {
        final parsedDate = DateTime.parse(date);
        dates.add(parsedDate);
        years.add(parsedDate.year);
      } catch (_) {
        dates.add(DateTime(1900)); // fallback
        years.add(i);
      }

      if (actual > peakActual) {
        peakActual = actual;
        peakActualIndex = i;
      }
      if (predicted > peakPredicted) {
        peakPredicted = predicted;
        peakPredictedIndex = i;
      }
      i++;
    });

    dates.sort(); // ✅ Sort by date

    double totalError = 0;
    int countError = 0;
    for (final row in allData) {
      if (row['actual'] != null &&
          row['actual'] != 0 &&
          row['predicted'] != null) {
        totalError += (row['actual'] - row['predicted']).abs() / row['actual'];
        countError++;
      }
    }
    final mape = countError > 0 ? (totalError / countError) * 100 : 0;

    return {
      'actualSpots': actualSpots,
      'predictedSpots': predictedSpots,
      'tableData': allData,
      'mape': mape,
      'xLabels': xLabels,
      'years': years,
      'dates': dates, // ✅ Pass parsed dates
      'peakActualIndex': peakActualIndex,
      'peakPredictedIndex': peakPredictedIndex,
    };
  }

  @override
  Widget build(BuildContext context) {
    final predictionState = ref.watch(predictionNotifierProvider);
    ref.watch(currencySymbolProvider);
    _currencyFormatter = null;

    return Scaffold(
      appBar: PredictionAppBar(generateCsv: generateCsv),
      body: Builder(
        builder: (context) {
          if (predictionState.status == PredictionState.loading &&
              predictionState.displayedData.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (predictionState.status == PredictionState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    predictionState.result,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (predictionState.displayedData.isEmpty) {
            return const Center(child: Text('No prediction data available.'));
          }

          return FutureBuilder<Map<String, dynamic>>(
            future: processData(predictionState.displayedData),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data ?? {};
              final actualSpots = data['actualSpots'] as List<FlSpot>? ?? [];
              final predictedSpots =
                  data['predictedSpots'] as List<FlSpot>? ?? [];
              final tableData =
                  data['tableData'] as List<Map<String, dynamic>>? ?? [];
              final mape = data['mape'] as double? ?? 0;
              final peakActualIndex = data['peakActualIndex'] as int? ?? 0;
              final peakPredictedIndex =
                  data['peakPredictedIndex'] as int? ?? 0;
              final years = data['years'] as List<int>? ?? [];
              final dates = data['dates'] as List<DateTime>? ?? [];

              final isLoadingMore = ref.watch(isLoadingMoreProvider);

              return SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Opacity(
                  opacity: isLoadingMore ? 0.5 : 1.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MapeCard(mape: mape),
                      PredictionChart(
                        actualSpots: actualSpots,
                        predictedSpots: predictedSpots,
                        formatCurrency: formatCurrency,
                        peakActualIndex: peakActualIndex,
                        peakPredictedIndex: peakPredictedIndex,
                        years: years,
                        dates: dates, // ✅ FIX: now it’s defined
                      ),
                      const SizedBox(height: 30),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ForecastTable(
                          tableData: tableData,
                          formatCurrency: formatCurrency,
                          parseFlexibleDate: parseFlexibleDate,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
