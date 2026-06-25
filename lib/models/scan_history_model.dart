enum ScanStatus { fresh, spoiled, moderate, fair }

class ScanHistory {
  final String id;
  final String fishName;
  final String source;
  final DateTime dateTime;
  final ScanStatus status;
  final String image;
  final int confidence;

  ScanHistory({
    required this.id,
    required this.fishName,
    required this.source,
    required this.dateTime,
    required this.status,
    required this.image,
    required this.confidence,
  });
}
