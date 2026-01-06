enum ScanStatus { fresh, spoiled }

class ScanHistory {
  final String fishName;
  final String source;
  final DateTime dateTime;
  final ScanStatus status;
  final String image;

  ScanHistory({
    required this.fishName,
    required this.source,
    required this.dateTime,
    required this.status,
    required this.image,
  });
}
