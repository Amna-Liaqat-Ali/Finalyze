import 'package:fish_freshness_detection/screens/guide/guide_screen.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../models/scan_history_model.dart';
import 'widgets/history_card.dart';
import 'widgets/history_filter.dart';

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
      fishName: 'Tuna',
      source: 'Saddar',
    ),
    ScanHistory(
      dateTime: DateTime(2026, 1, 24, 8, 15),
      status: ScanStatus.fresh,
      image: "",
      fishName: 'Salmon',
      source: 'Bolton Market',
    ),
    ScanHistory(
      dateTime: DateTime(2026, 1, 23, 16, 45),
      status: ScanStatus.moderate,
      image: "",
      fishName: 'Pomfret',
      source: 'Kemari',
    ),
    ScanHistory(
      dateTime: DateTime(2026, 1, 23, 14, 20),
      status: ScanStatus.fair,
      image: "",
      fishName: 'Rohu',
      source: 'Clifton',
    ),
  ];

  List<ScanHistory> get filteredHistory {
    switch (selectedFilter) {
      case "Fresh":
        return history.where((e) => e.status == ScanStatus.fresh).toList();
      case "Moderate":
        return history.where((e) => e.status == ScanStatus.moderate).toList();
      case "Fair":
        return history.where((e) => e.status == ScanStatus.fair).toList();
      default:
        return history;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: _HistoryAppBar(),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Scan Records",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Review previous fish freshness detections",
              style: TextStyle(fontSize: 13, color: AppColors.textLight),
            ),

            const SizedBox(height: 16),

            HistoryFilter(
              selected: selectedFilter,
              onChanged: (val) => setState(() => selectedFilter = val),
            ),

            const SizedBox(height: 18),

            Expanded(
              child: filteredHistory.isEmpty
                  ? _EmptyHistory()
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
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

class _HistoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        color: AppColors.textDark,
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline_rounded),
          color: AppColors.textLight,
          onPressed: () {
            GuideScreen();
          },
        ),
        const SizedBox(width: 6),
      ],
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.history_rounded, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "No scans yet",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Your fish freshness scans will appear here",
            style: TextStyle(fontSize: 13, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}
