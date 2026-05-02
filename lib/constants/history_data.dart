import '../models/scan_history_model.dart';

final historyData = [
  ScanHistory(
    fishName: "Rohu",
    source: "Market A",
    dateTime: DateTime.now(),
    status: ScanStatus.fresh,
    image: "assets/images/rohu.jpeg",
    confidence: 98,
  ),
  ScanHistory(
    fishName: "Paplet",
    source: "Market B",
    dateTime: DateTime.now(),
    status: ScanStatus.fresh,
    image: "assets/images/paplet.jpeg",
    confidence: 98,
  ),
  ScanHistory(
    fishName: "Mushka",
    source: "Market B",
    dateTime: DateTime.now(),
    status: ScanStatus.moderate,
    image: "assets/images/mushka.jpeg",
    confidence: 98,
  ),
  ScanHistory(
    fishName: "Palla",
    source: "Market A",
    dateTime: DateTime.now(),
    status: ScanStatus.fresh,
    image: "assets/images/palla.jpeg",
    confidence: 98,
  ),
  ScanHistory(
    fishName: "Surmai",
    source: "Market A",
    dateTime: DateTime.now(),
    status: ScanStatus.spoiled,
    image: "assets/images/surmai.jpeg",
    confidence: 98,
  ),
  ScanHistory(
    fishName: "Heera",
    source: "Market A",
    dateTime: DateTime.now(),
    status: ScanStatus.fresh,
    image: "assets/images/heera.jpeg",
    confidence: 98,
  ),
];
