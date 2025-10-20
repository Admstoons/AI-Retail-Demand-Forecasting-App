// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';
import 'package:retail_demand/models/prediction_state_data.dart';

class PredictionNotifier extends StateNotifier<PredictionStateData> {
  PredictionNotifier() : super(PredictionStateData.initial());

  bool _isPredicting = false;

  /// Trigger prediction from Supabase file URL
  Future<void> predictFromFileURL(String fileUrl) async {
    if (_isPredicting) return;

    final uri = Uri.tryParse(fileUrl);
    if (uri == null || !uri.isAbsolute || fileUrl.contains(' ')) {
      _setError("❌ Invalid file URL");
      return;
    }

    _isPredicting = true;
    state = state.copyWith(status: PredictionState.loading);

    try {
      final response = await retry(
        () => http
            .post(
              Uri.parse('https://retaildemand.onrender.com/predict/url'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'csv_url': fileUrl}),
            )
            .timeout(const Duration(seconds: 600)),
        maxAttempts: 3,
        delayFactor: const Duration(seconds: 3),
        onRetry: (e) => print('🔁 Retrying due to: $e'),
      );

      print("📡 API Status: ${response.statusCode}");
      print("📦 Body length: ${response.body.length}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final predictions = decoded['predictions'] as List? ?? [];
        final totalRows = predictions.length;

        final firstChunk = _processChunk(decoded, 0, state.pageSize);
        final apiMape =
            (decoded['performance_metrics']?['mape'] as num?)?.toDouble() ??
            0.0;

        state = state.copyWith(
          status: PredictionState.success,
          result: response.body,
          displayedData: firstChunk,
          totalRows: totalRows,
          currentOffset: firstChunk.length,
          mape: apiMape,
        );
      } else if (response.statusCode == 429) {
        _setError("⚠️ Too many requests. Please wait.");
      } else {
        _setError("❌ Prediction failed (${response.statusCode})");
      }
    } on TimeoutException {
      _setError("⏳ Timeout. Try again later.");
    } catch (e) {
      _setError("❌ Unexpected error: $e");
    } finally {
      _isPredicting = false;
    }
  }

  /// Internal helper to parse predictions in chunks
  List<Map<String, dynamic>> _processChunk(
    Map<String, dynamic> decoded,
    int offset,
    int limit,
  ) {
    final predictionsRaw = decoded['predictions'] as List?;
    if (predictionsRaw == null) return [];

    final endIndex = (offset + limit).clamp(0, predictionsRaw.length);
    final chunk = <Map<String, dynamic>>[];

    for (int i = offset; i < endIndex; i++) {
      final row = predictionsRaw[i];
      chunk.add({
        'date': row['Date'],
        'actual': (row['Actual_Weekly_Sales'] as num?)?.toDouble(),
        'predicted': (row['Predicted_Weekly_Sales'] as num?)?.toDouble(),
      });
    }

    print('📊 Processed ${chunk.length} rows (offset: $offset, limit: $limit)');
    return chunk;
  }

  /// Load next set of predictions (pagination)
  Future<void> fetchNextPage() async {
    if (state.currentOffset >= state.totalRows || state.result.isEmpty) return;

    try {
      final decoded = jsonDecode(state.result);
      final nextChunk = _processChunk(
        decoded,
        state.currentOffset,
        state.pageSize,
      );

      state = state.copyWith(
        status: PredictionState.success,
        displayedData: [...state.displayedData, ...nextChunk],
        currentOffset: state.currentOffset + nextChunk.length,
      );
    } catch (e) {
      _setError("❌ Error processing next page: $e");
    }
  }

  /// Centralized error handling
  void _setError(String message) {
    state = state.copyWith(result: message, status: PredictionState.error);
  }
}

final predictionNotifierProvider =
    StateNotifierProvider<PredictionNotifier, PredictionStateData>(
      (ref) => PredictionNotifier(),
    );
