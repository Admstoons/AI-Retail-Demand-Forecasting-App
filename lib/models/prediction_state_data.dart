enum PredictionState { idle, loading, success, error }

class PredictionStateData {
  final PredictionState status;
  final String result; // Raw JSON response
  final List<Map<String, dynamic>> displayedData; // For UI
  final int totalRows;
  final int currentOffset;
  final int pageSize;
  final double mape; // From API

  PredictionStateData({
    required this.status,
    required this.result,
    this.displayedData = const [],
    this.totalRows = 0,
    this.currentOffset = 0,
    this.pageSize = 100,
    this.mape = 0.0,
  });

  PredictionStateData copyWith({
    PredictionState? status,
    String? result,
    List<Map<String, dynamic>>? displayedData,
    int? totalRows,
    int? currentOffset,
    int? pageSize,
    double? mape,
  }) {
    return PredictionStateData(
      status: status ?? this.status,
      result: result ?? this.result,
      displayedData: displayedData ?? this.displayedData,
      totalRows: totalRows ?? this.totalRows,
      currentOffset: currentOffset ?? this.currentOffset,
      pageSize: pageSize ?? this.pageSize,
      mape: mape ?? this.mape,
    );
  }

  factory PredictionStateData.initial() {
    return PredictionStateData(status: PredictionState.idle, result: '');
  }
}
