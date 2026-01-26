import 'package:fish_freshness_detection/screens/history/widgets/history_card.dart';
import 'package:fish_freshness_detection/screens/history/widgets/history_filter.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../models/scan_history_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String selectedFilter = "All";

  final List<ScanHistory> history = [
    ScanHistory(
      dateTime: DateTime(2026, 1, 24, 9, 30),
      status: ScanStatus.fresh,
      image: "",
      fishName: 'AHHDSBD',
      source: 'saddar',
    ),
    ScanHistory(
      dateTime: DateTime(2026, 1, 24, 8, 15),
      status: ScanStatus.fresh,
      image: "",
      fishName: 'DSJHDHD',
      source: 'boltan',
    ),
    ScanHistory(
      dateTime: DateTime(2026, 1, 23, 16, 45),
      status: ScanStatus.moderate,
      image: "",
      fishName: 'DJDHWS',
      source: 'kemari',
    ),
    ScanHistory(
      dateTime: DateTime(2026, 1, 23, 14, 20),
      status: ScanStatus.fair,
      image: "",
      fishName: 'swhdjbd',
      source: 'clifton',
    ),
  ];

  List<ScanHistory> get filteredHistory {
    if (selectedFilter == "Fresh") {
      return history.where((e) => e.status == ScanStatus.fresh).toList();
    }
    if (selectedFilter == "Moderate") {
      return history.where((e) => e.status == ScanStatus.moderate).toList();
    }
    if (selectedFilter == "Fair") {
      return history.where((e) => e.status == ScanStatus.fair).toList();
    }
    return history;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: AppColors.textDark,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detection History",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Column(
          children: [
            HistoryFilter(
              selected: selectedFilter,
              onChanged: (val) => setState(() => selectedFilter = val),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                itemCount: filteredHistory.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return HistoryCard(data: filteredHistory[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
