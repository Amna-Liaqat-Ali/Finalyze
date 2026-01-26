enum ScanStatus { fresh, moderate, fair }

class ScanHistory {
  final String location;
  final DateTime dateTime;
  final ScanStatus status;
  final int freshness;
  final int confidence;
  final String image;

  ScanHistory({
    required this.location,
    required this.dateTime,
    required this.status,
    required this.freshness,
    required this.confidence,
    required this.image,
  });
}
