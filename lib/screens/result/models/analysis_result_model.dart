class AnalysisResult {
  final bool isFresh;
  final int freshnessScore;
  final int confidence;
  final String location;
  final String estimatedAge;
  final DateTime dateTime;

  AnalysisResult({
    required this.isFresh,
    required this.freshnessScore,
    required this.confidence,
    required this.location,
    required this.estimatedAge,
    required this.dateTime,
  });
}
