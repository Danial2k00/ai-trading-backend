class SignalModel {
  const SignalModel({
    required this.pair,
    required this.signal,
    required this.confidence,
    required this.timeframe,
    required this.reason,
  });

  factory SignalModel.fromJson(Map<String, dynamic> json) {
    return SignalModel(
      pair: json['pair'] as String,
      signal: json['signal'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      timeframe: json['timeframe'] as String,
      reason: json['reason'] as String,
    );
  }

  final String pair;
  final String signal;
  final double confidence;
  final String timeframe;
  final String reason;
}

class SignalHistoryItem {
  const SignalHistoryItem({
    required this.id,
    required this.pair,
    required this.signal,
    required this.confidence,
    required this.timeframe,
    required this.reason,
    required this.createdAt,
  });

  factory SignalHistoryItem.fromJson(Map<String, dynamic> json) {
    return SignalHistoryItem(
      id: json['id'] as int,
      pair: json['pair'] as String,
      signal: json['signal'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      timeframe: json['timeframe'] as String,
      reason: json['reason'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  final int id;
  final String pair;
  final String signal;
  final double confidence;
  final String timeframe;
  final String reason;
  final String createdAt;
}
