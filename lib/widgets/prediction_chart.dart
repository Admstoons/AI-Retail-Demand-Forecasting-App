import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:retail_demand/provider/currency_provider.dart';

class PredictionChart extends ConsumerWidget {
  final List<FlSpot> actualSpots;
  final List<FlSpot> predictedSpots;
  final List<DateTime> dates;
  final String Function(double, String) formatCurrency;
  final int? peakActualIndex;
  final int? peakPredictedIndex;

  const PredictionChart({
    super.key,
    required this.actualSpots,
    required this.predictedSpots,
    required this.dates,
    required this.formatCurrency,
    this.peakActualIndex,
    this.peakPredictedIndex,
    required List<int> years,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCurrency = ref.watch(currencySymbolProvider);

    final maxY =
        (actualSpots + predictedSpots)
            .map((s) => s.y)
            .fold<double>(0, (prev, y) => y > prev ? y : prev) *
        1.1;

    final chartWidth = (dates.isNotEmpty ? dates.length : 1) * 50.0;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            '📊 Actual vs Predicted Sales',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Scrollable chart container
          SizedBox(
            height: 450,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: chartWidth,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: maxY > 0 ? maxY : null,
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 56,
                          getTitlesWidget:
                              (value, meta) => Text(
                                formatCurrency(value, selectedCurrency),
                                style: const TextStyle(fontSize: 10),
                              ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= dates.length) {
                              return const SizedBox.shrink();
                            }

                            final date = dates[i];
                            final prevDate = i > 0 ? dates[i - 1] : null;

                            if (prevDate == null ||
                                prevDate.month != date.month ||
                                prevDate.year != date.year) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  DateFormat('MMM yyyy').format(date),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  DateFormat('dd').format(date),
                                  style: const TextStyle(fontSize: 9),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    lineBarsData: [
                      if (actualSpots.isNotEmpty)
                        LineChartBarData(
                          spots: actualSpots,
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 2,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) {
                              if (index == peakActualIndex) {
                                return FlDotCirclePainter(
                                  radius: 6,
                                  color: Colors.red,
                                  strokeWidth: 2,
                                  strokeColor: Colors.black,
                                );
                              }
                              return FlDotCirclePainter(
                                radius: 3,
                                color: Colors.green,
                              );
                            },
                          ),
                        ),
                      if (predictedSpots.isNotEmpty)
                        LineChartBarData(
                          spots: predictedSpots,
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 2,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) {
                              if (index == peakPredictedIndex) {
                                return FlDotCirclePainter(
                                  radius: 6,
                                  color: Colors.orange,
                                  strokeWidth: 2,
                                  strokeColor: Colors.black,
                                );
                              }
                              return FlDotCirclePainter(
                                radius: 3,
                                color: Colors.red,
                              );
                            },
                          ),
                        ),
                    ],
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        tooltipBorderRadius: BorderRadius.circular(8),
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 12,
                        getTooltipColor: (_) => Colors.black87,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final i = spot.x.toInt();
                            final dateLabel =
                                i < dates.length
                                    ? DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(dates[i])
                                    : '';
                            final label =
                                spot.barIndex == 0 ? 'Actual' : 'Predicted';
                            return LineTooltipItem(
                              "$label\n$dateLabel\n${formatCurrency(spot.y, selectedCurrency)}",
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: const [
              Icon(Icons.circle, color: Colors.green, size: 12),
              SizedBox(width: 4),
              Text('Actual', style: TextStyle(fontSize: 12)),
              SizedBox(width: 12),
              Icon(Icons.circle, color: Colors.red, size: 12),
              SizedBox(width: 4),
              Text('Predicted', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
