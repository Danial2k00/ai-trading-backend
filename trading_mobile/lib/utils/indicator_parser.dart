/// Extracts human-readable indicator snippets from backend `reason` text.
class ParsedIndicators {
  const ParsedIndicators({this.rsi, this.macd, this.movingAverages});

  final String? rsi;
  final String? macd;
  final String? movingAverages;

  static ParsedIndicators fromReason(String reason) {
    String? rsi;
    String? macd;
    String? ma;

    final rsiMatch = RegExp(r'RSI\([^)]*\)=([\d.]+)').firstMatch(reason);
    if (rsiMatch != null) rsi = rsiMatch.group(1);

    final macdMatch = RegExp(r'MACD vs signal:\s*([\d.]+)\s*/\s*([\d.]+)').firstMatch(reason);
    if (macdMatch != null) {
      macd = '${macdMatch.group(1)} / ${macdMatch.group(2)}';
    }

    final maMatch = RegExp(r'MA20/MA50:\s*([\d.]+)\s*/\s*([\d.]+)').firstMatch(reason);
    if (maMatch != null) {
      ma = '${maMatch.group(1)} / ${maMatch.group(2)}';
    }

    return ParsedIndicators(rsi: rsi, macd: macd, movingAverages: ma);
  }
}
