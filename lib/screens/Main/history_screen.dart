import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../models/scan_history_model.dart';
import '../../widgets/history_card.dart';
import 'history_filter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String selectedFilter = "All";

  final List<ScanHistory> history = [
    ScanHistory(
      fishName: "Salmon Fillet",
      source: "Sune Creek",
      dateTime: DateTime.now(),
      status: ScanStatus.fresh,
      image: "",
    ),
    ScanHistory(
      fishName: "Tuna Steak",
      source: "Sune Creek",
      dateTime: DateTime.now(),
      status: ScanStatus.spoiled,
      image: "",
    ),
  ];

  List<ScanHistory> get filteredHistory {
    if (selectedFilter == "Fresh") {
      return history.where((e) => e.status == ScanStatus.fresh).toList();
    }
    if (selectedFilter == "Spoiled") {
      return history.where((e) => e.status == ScanStatus.spoiled).toList();
    }
    return history;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Scan History",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            HistoryFilter(
              selected: selectedFilter,
              onChanged: (val) => setState(() => selectedFilter = val),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredHistory.isEmpty
                  ? Center(
                      child: Text(
                        "No records found.",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textLight,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredHistory.length,
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
